# Docker images for GHCJS
The purpose of this repository is to manage the `Dockerfile`s to build the images at [tehnix/ghcjs-docker](https://hub.docker.com/r/tehnix/ghcjs-docker). This is set up as an automated build repository, so changes here will trigger builds on docker hub.

To use these images, first set up GHCJS in your `stack.yaml`,

```yaml
resolver: lts-9.21
compiler: ghcjs-0.2.1.9009021_ghc-8.0.2
compiler-check: match-exact
setup-info:
  ghcjs:
    source:
      ghcjs-0.2.1.9009021_ghc-8.0.2:
        url: https://github.com/matchwood/ghcjs-stack-dist/raw/master/ghcjs-0.2.1.9009021.tar.gz
        sha1: b1740c3c99e5039ac306702894cd6e58283f4d31

extra-deps: []
```

Then add a `Dockerfile`,

```Dockerfile
FROM tehnix/ghcjs-docker:lts-9.21

RUN mkdir -p /src
VOLUME /src
WORKDIR /src
```

You can then use it by first building it (just has to be done once),

```bash
$ docker build .
Sending build context to Docker daemon    626MB
Step 1/4 : FROM tehnix/ghcjs-docker:lts-9.21
...
 ---> 6ef295b59aaf
Successfully built 6ef295b59aaf
```

and then you can run your commands like,

```bash
$ docker run -v $(pwd):/src -it 6ef295b59aaf stack build
```

Obviously substituting the image name for the one your build produces.

The LTS and GHCJS compiler information is located in the `stack.yaml` file, and the [fpco/stack-build](https://hub.docker.com/r/fpco/stack-build/) image is specified in the `Dockerfile`. The LTS in the `Dockerfile` is a newer one, than what we are actually building for. This is because we need a newer version of cabal, than what is supplied with the default corresponding LTS.


# TODO
It doesn't currently work perfectly. Ideally, you would make `stack` manage the docker, by having something like,

```yaml
resolver: lts-9.21
compiler: ghcjs-0.2.1.9009021_ghc-8.0.2
compiler-check: match-exact
setup-info:
  ghcjs:
    source:
      ghcjs-0.2.1.9009021_ghc-8.0.2:
        url: https://github.com/matchwood/ghcjs-stack-dist/raw/master/ghcjs-0.2.1.9009021.tar.gz
        sha1: b1740c3c99e5039ac306702894cd6e58283f4d31

docker:
    enable: true
    repo: "tehnix/ghcjs-docker" # It will automatically add :lts-x.xx
    auto-pull: true
system-ghc: false
```
