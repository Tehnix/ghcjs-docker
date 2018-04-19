FROM fpco/stack-build:lts-8.11

# COPY stack.yaml /tmp/setup-ghcjs/stack.yaml
# COPY stack-cabal.yaml /tmp/setup-cabal/stack.yaml

# Update cabal to version 2.0.0.1.
# COPY global-stack.yaml /root/.stack/global-project/stack.yaml
# RUN stack config set resolver lts-8.11 \

RUN stack upgrade
RUN /root/.local/bin/stack setup --system-ghc --install-cabal 2.0.0.1

# RUN cd /tmp/setup-cabal \
#  && stack install cabal-install

# RUN cd /tmp/setup-ghcjs && stack setup

ENTRYPOINT ["/bin/bash"]
