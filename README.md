# Docker images for GHCJS
The purpose of this repository is to manage the `Dockerfile`s to build the images at [tehnix/ghcjs-docker](https://hub.docker.com/r/tehnix/ghcjs-docker). This is set up as an automated build repository, so changes here will trigger builds on docker hub.

To use these images, simply specify the image in your `Dockerfile` to point here,

```Dockerfile
FROM tehnix/ghcjs-docker:latest
```

or in your `stack.yaml`,

```yaml
resolver: lts-8.11
compiler: ghcjs-0.2.1.9008011_ghc-8.0.2
compiler-check: match-exact
setup-info:
  ghcjs:
    source:
      ghcjs-0.2.1.9008011_ghc-8.0.2:
        url: https://github.com/matchwood/ghcjs-stack-dist/raw/master/ghcjs-0.2.1.9008011.tar.gz
        sha1: a72a5181124baf64bcd0e68a8726e65914473b3b
docker:
    enable: true
    repo: "tehnix/ghcjs-docker" # It will automatically add :lts-x.xx
    auto-pull: true
system-ghc: false

extra-deps: []
```

The LTS and GHCJS compiler information is located in the `stack.yaml` file, and the [fpco/stack-build](https://hub.docker.com/r/fpco/stack-build/) image is specified in the `Dockerfile`. The LTS in the `Dockerfile` is a newer one, than what we are actually building for. This is because we need a newer version of cabal, than what is supplied with the default corresponding LTS.
