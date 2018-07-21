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

The different versions are:

- [GHCJS with lts-8.11](https://github.com/Tehnix/ghcjs-docker/tree/lts-8.11)
- [GHCJS with lts-9.21](https://github.com/Tehnix/ghcjs-docker/tree/lts-9.21)

Now, there's a couple of ways to go around using this image. My main advice is to setup a build script, something like this [stack-build-docker.sh](https://github.com/Tehnix/miso-isomorphic-stack/blob/master/stack-build-docker.sh) script.

### Building with a Dockerfile

Add a `Dockerfile`,

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

Obviously substituting the image name for the one your build produces. Alternatively tag the ,

```bash
$ docker build -t ghcjs:lts-9.21 .
$ docker run -v $(pwd):/src -it $(docker images -q ghcjs:lts-9.21) stack build
```

#### Building straight with `tehnix/ghcjs-docker:lts-9.21`

```bash
$ docker run -v $(pwd):/src -it tehnix/ghcjs-docker:lts-9.21 stack build
```

### Persisting changes/builds

One thing to note is that you have to commit your image afterwards, to persist the build.

```bash
$ docker -ps a
CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS                         PORTS               NAMES
c59aca6d8672        a00a947b8fd2                   "/usr/local/sbin/pid…"   3 minutes ago       Exited (143) 9 seconds ago                         keen_agnesi
...
$ docker commit c59aca6d8672 ghcjs-lts-9.21
```

Or,

```bash
$ docker commit $(docker ps -l -q) ghcjs:lts-9.21
```

Where `docker ps -l -q` gives the latest built container ID.

# Custom GHCJS Dist
The GHCJS dist simply changes the install folder from `~/.ghcjs` to `~/.stack/ghcjs`. This is necessary, because stack will only copy over the `~/.stack` folder during docker image setup. This means that in `ghcjs-0.2.1.9009021/src/Compiler/Info.hs`, we've changed `getDefaultTopDir` and `getUserTopDir'` to prepend `stack`.

If you make changes and need to make a .tar.gz archive again, on macOS you need to use GNU tar, to get the structure that stack expects,

```bash
$ gtar -czf ghcjs-0.2.1.9009021.tar.gz ghcjs-0.2.1.9009021
```

# TODO
Ideally, you would make `stack` manage the docker image, by having something like,

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

Unfortunately, `stack` will start looking for GHCJS on the host system, and therefore will not catch that GHCJS has already been built in the container image it's using. I'm suspect this has something to do with `setup-info`, but it's not entirely clear to me how to resolve this issue.
