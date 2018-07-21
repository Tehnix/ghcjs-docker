FROM fpco/stack-build:lts-11.5 as builder

# Install node.js for GHCJS.
RUN curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash - \
 && apt-get update \
 && apt-get install -y nodejs \
 && rm -rf /var/lib/apt/lists/*

# Create a stack user, as per https://docs.haskellstack.org/en/stable/docker_integration/#custom-images
# to let stack find the build plans and caches, so it can copy it over.
RUN useradd --create-home --user-group --shell /bin/bash stack
RUN mkdir -p /src

# Change to the stack user.
USER stack

# Bootstrap GHC lts-9.21 and the libraries GHCJS needs to build.
RUN stack setup --resolver=lts-9.21 \
 && rm -rf /home/stack/.stack/programs/x86_64-linux/ghc-8.0.2.tar.xz
COPY --chown=stack:stack build-files/src-ghc /home/stack/src-ghc
RUN cd /home/stack/src-ghc && stack build \
 && rm -rf /home/stack/src-ghc

# Copy in GHCJS dist and test project.
COPY --chown=stack:stack build-files/ghcjs-0.2.1.9009021.tar.gz /home/stack/ghcjs-0.2.1.9009021.tar.gz
COPY --chown=stack:stack build-files/src-ghcjs /home/stack/src-ghcjs

# Set up GHCJS, by installing a minimal project that specifies it.
RUN cd /home/stack/src-ghcjs && stack setup \
 && rm -rf /home/stack/src-ghcjs

USER root
VOLUME /src
WORKDIR /src

ENTRYPOINT ["/usr/local/sbin/pid1"]
CMD ["bash"]

# Move .ghcjs into .stack so it will be copied over, and update the path of
# everything to reflect this move.
# RUN mv /home/stack/.ghcjs /home/stack/.stack/.ghcjs \
#  && sed -i 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/programs/x86_64-linux/ghcjs-0.2.1.9009021_ghc-8.0.2/bin/ghcjs-pkg \
#  && sed -i 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/programs/x86_64-linux/ghcjs-0.2.1.9009021_ghc-8.0.2/bin/ghcjs \
#  && sed -i 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/programs/x86_64-linux/ghcjs-0.2.1.9009021_ghc-8.0.2/bin/hsc2hs-ghcjs \
#  && sed -i 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/programs/x86_64-linux/ghcjs-0.2.1.9009021_ghc-8.0.2/bin/haddock-ghcjs \
#  && sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/programs/x86_64-linux/ghcjs-0.2.1.9009021_ghc-8.0.2/src/.stack-work/install/x86_64-linux/lts-9.21/8.0.2/bin/*

# Fixing packages.
# RUN sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/.ghcjs/x86_64-linux-0.2.1.9009021-8.0.2/ghcjs/package.conf.d/*.conf \
#  && /home/stack/.stack/programs/x86_64-linux/ghcjs-0.2.1.9009021_ghc-8.0.2/bin/ghcjs-pkg recache --user \
#  && sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/.ghcjs/x86_64-linux-0.2.1.9009021-8.0.2/ghcjs/ghcjs-boot/ghcjs/ghcjs-base/dist/package.conf.inplace/*.conf \
#  && sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/.ghcjs/x86_64-linux-0.2.1.9009021-8.0.2/ghcjs/ghcjs-boot/ghcjs/*/dist/build/autogen/*.hs \
#  && sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/.ghcjs/x86_64-linux-0.2.1.9009021-8.0.2/ghcjs/ghcjs-boot/boot/*/dist/package.conf.inplace/*.conf \
#  && sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/.ghcjs/x86_64-linux-0.2.1.9009021-8.0.2/ghcjs/ghcjs-boot/boot/*/dist/build/autogen/*.hs \
#  && sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/.ghcjs/x86_64-linux-0.2.1.9009021-8.0.2/ghcjs/ghcjs-boot/boot/*/*.log \
#  && sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/.ghcjs/x86_64-linux-0.2.1.9009021-8.0.2/ghcjs/ghcjs-boot/boot/*/*.status \
#  && sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/.ghcjs/x86_64-linux-0.2.1.9009021-8.0.2/ghcjs/ghcjs-prim/dist/package.conf.inplace/*.conf \
#  && sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/.ghcjs/x86_64-linux-0.2.1.9009021-8.0.2/ghcjs/ghcjs-prim/dist/build/autogen/*.hs \
#  && sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/.ghcjs/x86_64-linux-0.2.1.9009021-8.0.2/ghcjs/ghcjs-boot/boot/uuid/uuid-types/dist/build/autogen/*.hs \
#  && sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/.ghcjs/x86_64-linux-0.2.1.9009021-8.0.2/ghcjs/ghcjs-boot/boot/*/*/dist/package.conf.inplace/*.conf \
#  && sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/.ghcjs/x86_64-linux-0.2.1.9009021-8.0.2/ghcjs/ghcjs-boot/boot/*/*/dist/build/autogen/*.hs \
#  && sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/.ghcjs/x86_64-linux-0.2.1.9009021-8.0.2/ghcjs/ghcjs-th/dist/build/autogen/*.hs \
#  && sed -i -e 's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g' /home/stack/.stack/.ghcjs/x86_64-linux-0.2.1.9009021-8.0.2/ghcjs/ghcjs-th/dist/package.conf.inplace/*.conf

# (cd /src && stack --stack-yaml=frontend/stack.yaml build)

# RUN find /home/stack/.stack -type f -print0 | xargs -0 sed -i  's/\/home\/stack\/.ghcjs/\/home\/stack\/.stack\/.ghcjs/g'
# Overwrite the ghcjs, so it points to the moved .ghcjs directory,
# COPY --chown=stack:stack ghcjs-wrapper.sh /home/stack/.stack/programs/x86_64-linux/ghcjs-0.2.1.9009021_ghc-8.0.2/bin/ghcjs
# and make it executable.
# RUN chmod +x /home/stack/.stack/programs/x86_64-linux/ghcjs-0.2.1.9009021_ghc-8.0.2/bin/ghcjs

#
# Build the final image, copying over the tools from the builder.
#
# FROM fpco/stack-build:lts-9.21 as final
# # Create a stack user, as per https://docs.haskellstack.org/en/stable/docker_integration/#custom-images
# # to let stack find the build plans and caches, so it can copy it over.
# RUN useradd --create-home --user-group --shell /bin/bash stack

# # Copy over build artifacts from the builder image.
# COPY --from=builder /usr/bin/node /usr/bin/node
# COPY --chown=stack:stack --from=builder /home/stack/.stack /home/stack/.stack

# RUN mkdir -p /src
# USER stack
# VOLUME /src
# WORKDIR /src

# ENTRYPOINT ["/usr/local/sbin/pid1"]
# CMD ["bash"]
