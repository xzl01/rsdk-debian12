FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install minimal tools
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg \
  && rm -rf /var/lib/apt/lists/*

# Install Radxa archive keyring package (latest release) and add signed repo
RUN keyring="$(mktemp)" \
  && version="$(curl -fsSL https://github.com/radxa-pkg/radxa-archive-keyring/releases/latest/download/VERSION)" \
  && curl -fsSL -o "$keyring" "https://github.com/radxa-pkg/radxa-archive-keyring/releases/latest/download/radxa-archive-keyring_${version}_all.deb" \
  && dpkg -i "$keyring" \
  && rm -f "$keyring" \
  && echo "deb [signed-by=/usr/share/keyrings/radxa-archive-keyring.gpg] https://radxa-repo.github.io/bookworm/ bookworm main" > /etc/apt/sources.list.d/70-radxa.list

# Install rsdk from Radxa repo
RUN apt-get update \
  && apt-get install -y --no-install-recommends rsdk \
  && rm -rf /var/lib/apt/lists/*
