# Docker images for GHCJS
The purpose of this repository is to manage the `Dockerfile`s to build the images at https://hub.docker.com/r/tehnix/ghcjs-docker. This is set up as an automated build repository, so changes here will trigger builds on docker hub.

To use these images, simply specify the image in your `Dockerfile` to point here,

```Dockerfile
FROM tehnix/ghcjs-docker:latest
```

The LTS and GHCJS compiler information is located in the `stack.yaml` file, and the [fpco/stack-build](https://hub.docker.com/r/fpco/stack-build/) image is specified in the `Dockerfile`. The LTS in the `Dockerfile` is a newer one, than what we are actually building for. This is because we need a newer version of cabal, than what is supplied with the default corresponding LTS.
