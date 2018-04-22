FROM fpco/stack-build:lts-11.5

# Install node.js for GHCJS.
RUN curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash - \
 && apt-get update \
 && apt-get install -y nodejs \
 && rm -rf /var/lib/apt/lists/*

# Set up GHCJS.
COPY src /tmp/setup-ghcjs
RUN cd /tmp/setup-ghcjs \
 && stack setup --system-ghc \
 && rm -rf /tmp/setup-ghcjs

RUN mkdir -p /src
VOLUME /src
WORKDIR /src
