# Your data
Besides [your configuration](./04_advanced_config.md), it's your data that makes your instance unique. All instance data is stored in [Docker volumes](https://docs.docker.com/storage/volumes/).

 - `wikibase-image-data`: MediaWiki image and media file uploads
 - `mysql-data`: MediaWiki/Wikibase MariaDB raw database
 - `wdqs-data`: Wikidata Query Service raw database
 - `elasticsearch-data`: Elasticsearch raw database
 - `quickstatements-data`: generated Quickstatements OAuth binding for this MediaWiki instance
 - `traefik-letsencrypt-data`: SSL certificates

## Back up your data
To back up your data, shut down the instance and dump the contents of all Docker volumes into `.tar.gz` files.

```sh
docker compose down

for v in \
    wbs-deploy_elasticsearch-data \
    wbs-deploy_mysql-data \
    wbs-deploy_quickstatements-data \
    wbs-deploy_traefik-letsencrypt-data \
    wbs-deploy_wdqs-data \
    wbs-deploy_wikibase-image-data \
    ; do
  docker run --rm --volume $v:/backup debian:12-slim tar cz backup > $v.tar.gz
done
```

## Restore from a backup

To restore the volume backups, ensure your instance has been shut down by running `docker compose down` and populate the Docker volumes with data from your `.tar.gz` files.

```sh
docker compose down

for v in \
    wbs-deploy_elasticsearch-data \
    wbs-deploy_mysql-data \
    wbs-deploy_quickstatements-data \
    wbs-deploy_traefik-letsencrypt-data \
    wbs-deploy_wdqs-data \
    wbs-deploy_wikibase-image-data \
    ; do
  docker volume rm $v 2> /dev/null
  docker volume create $v
  docker run -i --rm --volume $v:/backup debian:12-slim tar xz < $v.tar.gz
done
```

