FROM fpco/stack-build:lts-11.5

# Upgrade stack to a much newer version.
RUN stack upgrade && mv /root/.local/bin/stack /usr/local/bin/stack

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

ENTRYPOINT ["/bin/bash"]
