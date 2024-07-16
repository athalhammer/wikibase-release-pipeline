# Wikibase Suite

Wikibase Suite (WBS) eases self-hosting [Wikibase](https://wikiba.se) in production, allowing you to maintain a knowledge graph similar to [Wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page).

If you want to host your own WBS instance, head over to the [WBS Deploy documentation](./deploy/README.md).

If you're looking for individual WBS images, head over to [hub.docker.com/u/wikibase](https://hub.docker.com/u/wikibase).

> 🔧 This document is intended for people developing WBS.  

## Overview

This repository contains the Wikibase Suite toolset used for: 

 - **Building** ([build.sh](./build.sh) and [build directory](./build))
 - **Testing** ([test.sh](./test.sh) and [test directory](./test))
 - **Publishing** ([.github/workflows](.github/workflows)) 
 - **Deploying** ([WBS Deploy](./deploy))

## Quick reference

### Build

```
# Build all Wikibase Suite images
$ ./build.sh

# Build only the MediaWiki/Wikibase containers
$ ./build.sh wikibase

# Build the WDQS container without using Docker's cache
$ ./build.sh --no-cache wdqs
```

### Test

```
# Show help for the test CLI, including the various options available. WDIO command line options are also supported (see https://webdriver.io/docs/testrunner/)
$ ./test.sh

# Runs all test suites (defined in `test/suites`)
$ ./test.sh all

# Runs the `repo` test suite
$ ./test.sh repo

# Runs the `repo` test suite with a specific spec file (paths to spec files are rooted in the `test` directory)
$ ./test.sh repo --spec specs/repo/special-item.ts

# Start and leave up the test environment for a given test suite without running tests
$ ./test.sh repo --setup
```

### Deploy

```
$ cd deploy
$ docker compose up --wait
```

Find more details in the [WBS Deploy documentation](./deploy/README.md).

## Development setup

To take advantage of the git hooks we've included, you'll need to configure git to use the `.githooks/` directory.

```
$ git config core.hooksPath .githooks
```

## Testing

Tests are organized in suites, which can be found in `test/suites`. Each suite runs a series of specs (tests) found in the `test/specs` directory. Which specs run by default in each suite are specified in the `.config.ts` file in each suite directory under the `specs` key.

All test suites are run against the most recently built local Docker images, those with the `:latest` tag, which are also selected when no tag is specified. The `deploy` test suite runs against the remote Docker images specified in the configuration in the `./deploy` directory.

You can run the tests in the Docker container locally exactly as they are run in CI by using `test.sh`.

## Examples usage of `./test.sh`:

```bash
# See all`./test.sh` CLI options
./test.sh --help

# Run all test suites
./test.sh all

# Only run a single suite (e.g., repo)
./test.sh repo

# Only run a specific file within the setup for any test suite (e.g., repo and the Babel extension)
./test.sh repo --spec specs/repo/extensions/babel.ts
```

There are also a few special options, useful when writing tests or in setting up and debugging the test runner:

```bash
# '--setup`: starts the test environment for the suite and leaves it running, but does not run any specs
./test.sh repo --setup

# `--command`, `--c`: Runs the given command on the test runner and doesn't execute any further commands
./test.sh --command npm install

# Sets test timeouts to 1 day so they don't time out while debugging with `await browser.debug()` calls
# However, this can have undesirable effects during normal test runs, so only use for actual debugging
# purposes.
./test.sh repo --debug

# `DEBUG`: Shows full Docker compose up/down progress logs for the test runner
# Note that the test service Docker logs can always be found in `test/suites/<suite>/results/wdio.log`
DEBUG=true ./test.sh repo
```

WDIO test runner CLI options are also supported. See https://webdriver.io/docs/testrunner .

## Variables for testing some other instance

In order to test your own instances of the services, make sure to change the following environment variables to point at the services that should be tested:

```bash
WIKIBASE_URL=http://wikibase
WIKIBASE_CLIENT_URL=http://wikibase-client
QUICKSTATEMENTS_URL=http://quickstatements
WDQS_FRONTEND_URL=http://wdqs-frontend
WDQS_URL=http://wdqs:9999
WDQS_PROXY_URL=http://wdqs-proxy
MW_ADMIN_NAME=
MW_ADMIN_PASS=
MW_SCRIPT_PATH=/w
```

For more information on testing, see the [README](./test/README.md).


## Making a new Release (Phabricator template)

**Versioning**

WBS Deploy and WBS images are released using this repository. The process involves updating all upstream component versions to be used, building images, testing all the images together and finally publishing them.

#### WBS releases triggered by new MediaWIki releases:

**For the latest minor or major MediaWiki release:**

- [ ] Update `variables.env`: Adjust WBS versions and upstream versions. You can find further instructions for this in the [variables.env](https://github.com/wmde/wikibase-release-pipeline/blob/main/variables.env) file itself.
- [ ] Update `CHANGES.md`: Reflect the new version/s in a new section in this file following the example of previous MediaWiki-triggered releases.
- [ ] Make sure tests are passing: Tests may need adjustments in order to pass for the new version. Minor releases are likely to pass without any adjustments. Try re-running tests on failure -- some specs may be flaky.
- [ ] Complete all steps from the "All releases" below
- [ ] Merge any non-version related changes from release branches back to `main`: Create a PR from `wbs-X` to `main` with any adjustments which should be brought back to the `main` branch from the release/s (e.g. `CHANGES.md`, etc). NOTE: Changes to `variables.env` should not be merged back, `main` should always reference the build of the latest components.

**For minor version updates to supported MediaWiki versions:** Currently we support the last version of MediaWiki and the LTS version:**

- [ ] Create a new `wbs-<major>.<minor>.0-prerelease` branch, with the major, minor versions reflecting the targeted new version.
- [ ] Create a PR on Github from that branch to the `wbs-X` branch
- [ ] Complete all steps from the "All releases" below
- [ ] Merge any non-version related changes from release branches back to `main`: Create a PR from `wbs-X` to `main` with any adjustments which should be brought back to the `main` branch from the release/s (e.g. `CHANGES.md`, etc). NOTE: Changes to `variables.env` should not be merged back, `main` should always reference the build of the latest components.

**Making a new release of WBS Images or WBS Deploy outside fo the MediaWiki release cycle:**

- [ ] Create a new `<image-name>-image-<major>.<minor>.<patch>` or `deploy-<major>.<minor>.<patch>` branch with the `major`, `minor`, and `patch` version numbers reflecting the targeted new version.
- [ ] Update the related version number in `variables.env` to the version to be released, according to [semver 2.0.0](https://semver.org/spec/v2.0.0.html)
- [ ] Create a PR on Github for that branch to the `main` branch.
- [ ] Continue with steps in "All Releases" below
- [ ] Delete the `<image-name>-image-<major>.<minor>.<patch>` or `deploy-<major>.<minor>.<patch>` branch
- [ ] Git tag the release with `<image-name>-image-<major>.<minor>.<patch>` or `deploy-<major>.<minor>.<patch>` and push the tag to Github

**All releases:**

- [ ] Create or update the related release tracking Phabricator ticket: Changes occurring in the release should be captured as subtasks of a ticket in Phabricator titled as "Release <major>.<minor>.0".
- [ ] "Smoke test" the release by running Deploy against the latest built images: This can be done locally on your machine or on a public server. You can find built images from your release PR on the [GitHub Container Registry](https://github.com/wmde/wikibase-release-pipeline/pkgs/container/wikibase%2Fwikibase) tagged with `dev-BRANCHNAME`, e.g., `dev-releaseprep`. This tag can be used to set up an instance running your release PR version.
- [ ] Update release branch according to input from PR review (do not merge branch)
- [ ] Prepare communication by creating a [release announcement](https://drive.google.com/drive/folders/1kHhKKwHlwq_P9x4j8-UnzV72yq0AYpsZ) using the linked template.
- [ ] Coordinate with ComCom on timing the publication of the release. Talk to SCoT (ComCom, technical writer) about this.
- [ ] Publish the release by merging the PR. **ATTENTION: In the case of `wbs-X` branches This will automatically push images to Docker Hub!**
- [ ] Put `main` branch into pre-release state:** Create a PR against `main` which change `VERSION` in `variables.env` to be `<current-major>.<current-minor+1>.0-alpha.0`

You`re done. **Congratulations!**
