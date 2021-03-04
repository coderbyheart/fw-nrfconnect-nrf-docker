# Building NCS applications with Docker

![Publish Docker](https://github.com/coderbyheart/fw-nrfconnect-nrf-docker/workflows/Publish%20Docker/badge.svg?branch=saga)
(_the [Docker image](https://hub.docker.com/r/coderbyheart/fw-nrfconnect-nrf-docker) is build against [NCS](https://github.com/nrfconnect/sdk-nrf) `master` every night._)

![Docker + Zephyr -> merged.hex](./diagram.png)

Install `docker` on your operating system. On Windows you might want to use the [WSL subsystem](https://docs.docker.com/docker-for-windows/wsl-tech-preview/).

Build the image (this is only needed once):

    docker build --no-cache=true -t fw-nrfconnect-nrf-docker .

Build the firmware for the `asset_tracker` application example:

    docker run --rm -v ${PWD}:/workdir fw-nrfconnect-nrf-docker \
      west build -p always -b nrf9160dk_nrf9160ns --build-dir /workdir/build/ /ncs/nrf/applications/asset_tracker

The firmware file will be in `./build/zephyr/merged.hex`.

You only need to run this command to build.

## Using pre-built image from Dockerhub

> _Note:_ This is a convenient way to quickly build your firmware but using images from untrusted third-parties poses the risk of exposing your source code.

You can use the pre-built image [`coderbyheart/fw-nrfconnect-nrf-docker:latest`](https://hub.docker.com/r/coderbyheart/fw-nrfconnect-nrf-docker).

    docker run --rm -v ${PWD}:/workdir coderbyheart/fw-nrfconnect-nrf-docker:latest \
      west build -p always -b nrf9160dk_nrf9160ns --build-dir /workdir/build/ /ncs/nrf/applications/asset_tracker
    ls -la ./build/zephyr/merged.hex

### Build a Zephyr sample

This builds the `hci_uart` sample and stores the `hci_uart.hex` file in the current directory:

    docker run --rm -v ${PWD}:/workdir coderbyheart/fw-nrfconnect-nrf-docker:latest \
        west build /ncs/zephyr/samples/bluetooth/hci_uart -p always -b nrf9160dk_nrf52840 --build-dir /workdir/build/
    ls -la build/zephyr && cp build/zephyr/zephyr.hex hci_uart.hex

## Flashing

    docker run --rm --device=/dev/ttyACM0 --privileged \
      coderbyheart/fw-nrfconnect-nrf-docker:latest \
      cd ncs/nrf/applications/asset_tracker && west flash

## ClangFormat

The image comes with [ClangFormat](https://clang.llvm.org/docs/ClangFormat.html) and the [nRF Connect SDK formatting rules](https://github.com/nrfconnect/sdk-nrf/blob/master/.clang-format) so you can run for example

    docker run --name fw-nrfconnect-nrf-docker -d coderbyheart/fw-nrfconnect-nrf-docker tail -f /dev/null
    find ./src -type f -iname \*.h -o -iname \*.c \
        | xargs -I@ /bin/bash -c "\
            tmpfile=\$(mktemp /tmp/clang-formatted.XXXXXX) && \
            docker exec -i fw-nrfconnect-nrf-docker clang-format < @ > \$tmpfile && \
            cmp --silent @ \$tmpfile || (mv \$tmpfile @ && echo @ formatted.)"
    docker kill fw-nrfconnect-nrf-docker
    docker rm fw-nrfconnect-nrf-docker

to format your sources.

> _Note:_ Instead of having `clang-format` overwrite the source code file itself, the above command passes the source code file on stdin to clang-format and then overwrites it outside of the container. Otherwise the overwritten file will be owner by the root user (because the Docker daemon is run as root).

## Interactive usage

    docker run -it --name fw-nrfconnect-nrf-docker --device=/dev/ttyACM0 --privileged \
    coderbyheart/fw-nrfconnect-nrf-docker:latest /bin/bash

Then, inside the container:

    cd /ncs/nrf/applications/asset_tracker
    west build -p always -b nrf9160_pca20035ns
    west flash
    west build
    ...

Meanwhile, inside or outside of the container, you may modify the code and repeat the build/flash cycle.

Later after closing the container you may re-open it by name to continue where you left off:

    docker start -i fw-nrfconnect-nrf-docker
