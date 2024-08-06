# Base image: Node.js LTS (20) on Debian Bookworm (12)
FROM node:20-bookworm-slim AS wbs-dev-runner-base

# WBS tests use the Selenium Standalone image, so no need for the embedded Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# hadolint global ignore=DL3059
SHELL [ "/bin/bash", "-o", "pipefail", "-c" ]

# Install necessary packages except Docker and PNPM
RUN apt-get update && \
    apt-get --no-install-recommends -y install \
        git \
        curl \
        jq \
        python3-pip \
        python3-venv \
        && ln -sf /usr/bin/python3 /usr/bin/python \
        && rm -rf /var/lib/apt/lists/*

# Set up Python virtual environment and install Python packages
RUN python3 -m venv /root/venv && \
    /root/venv/bin/pip install --no-cache-dir --upgrade \
        pip \
        setuptools \
        requests \
        bs4 \
        lxml \
        black

# Install Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    bash get-docker.sh && \
    rm get-docker.sh

WORKDIR /workspace

# Setup Git
RUN git config --global --add safe.directory /workspace

# Install PNPM
RUN curl -fsSL https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" PNPM_VERSION=9.6.0 bash -
ENV PATH="/root/.local/share/pnpm:${PATH}"
# Fixes issue that was only happening on Github CI
# ref. https://github.com/nrwl/nx/issues/27040
ENV NX_ISOLATE_PLUGINS=false

# Stage to get the hadolint binary (which will be plaform sensitive)
FROM ghcr.io/hadolint/hadolint:latest-debian AS hadolint

# Final stage: Build on top of the base image
FROM wbs-dev-runner-base

# Copy the Dockerfile linter hadolint binary from the hadolint image
COPY --from=hadolint /bin/hadolint /usr/local/bin/hadolint

# Add npm bins and activate Python venv virtual environment
ENV PATH="/workspace/node_modules/.bin:/root/venv/bin:$PATH"

ENTRYPOINT [ "./entrypoint.sh" ]
