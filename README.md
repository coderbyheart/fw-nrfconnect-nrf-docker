# Building NCS applications with Docker

![Publish Docker](https://github.com/coderbyheart/fw-nrfconnect-nrf-docker/workflows/Publish%20Docker/badge.svg?branch=saga)
(_the [Docker image](https://hub.docker.com/r/coderbyheart/fw-nrfconnect-nrf-docker) is build against [NCS](https://github.com/nrfconnect/sdk-nrf) `master` every night._)

![Docker + Zephyr -> merged.hex](./diagram.png)

Install `docker` on your operating system. On Windows you might want to use the [WSL subsystem](https://docs.docker.com/docker-for-windows/wsl-tech-preview/).

Clone the repo: `git clone https://github.com/nrfconnect/sdk-nrf`

Copy the Dockerfile to e.g. `/tmp/Dockerfile`, you might need to adapt the installation of [the requirements](./Dockerfile#L48-L51).

Build the image (this is only needed once):

    cd sdk-nrf
    docker build --no-cache=true -t fw-nrfconnect-nrf-docker -f /tmp/Dockerfile .

Build the firmware for the `asset_tracker` application example:

    docker run --rm -v ${PWD}:/workdir/ncs/nrf fw-nrfconnect-nrf-docker \
      /bin/bash -c 'cd ncs/nrf/applications/asset_tracker; west build -p always -b nrf9160_pca20035ns'

The firmware file will be in `applications/asset_tracker/build/zephyr/merged.hex`.

You only need to run this command to build.

## Full example

    git clone https://github.com/nrfconnect/sdk-nrf
    wget https://raw.githubusercontent.com/coderbyheart/fw-nrfconnect-nrf-docker/saga/Dockerfile
    cd sdk-nrf
    docker build --no-cache=true -t fw-nrfconnect-nrf-docker -f /tmp/Dockerfile .
    docker run --rm -v ${PWD}:/workdir/ncs/nrf fw-nrfconnect-nrf-docker \
      /bin/bash -c 'cd ncs/nrf/applications/asset_tracker; west build -p always -b nrf9160_pca20035ns'
    ls -la applications/asset_tracker/build/zephyr/merged.hex

## Using pre-built image from Dockerhub

> _Note:_ This is a convenient way to quickly build your firmware but using images from untrusted third-parties poses the risk of exposing your source code.

You can use the pre-built image [`coderbyheart/fw-nrfconnect-nrf-docker:latest`](https://hub.docker.com/r/coderbyheart/fw-nrfconnect-nrf-docker).

    git clone https://github.com/nrfconnect/sdk-nrf
    cd sdk-nrf
    docker run --rm -v ${PWD}:/workdir/ncs/nrf coderbyheart/fw-nrfconnect-nrf-docker:latest \
      /bin/bash -c 'cd ncs/nrf/applications/asset_tracker; west build -p always -b nrf9160_pca20035ns'
    ls -la applications/asset_tracker/build/zephyr/merged.hex

## Flashing

    cd sdk-nrf
    docker run --rm -v ${PWD}:/workdir/ncs/nrf --device=/dev/ttyACM0 --privileged \
      coderbyheart/fw-nrfconnect-nrf-docker:latest \
      /bin/bash -c 'cd ncs/nrf/applications/asset_tracker; west flash'

## Interactive usage

    cd sdk-nrf
    docker run -it --name fw-nrfconnect-nrf-docker -v ${PWD}:/workdir/ncs/nrf --device=/dev/ttyACM0 --privileged \
    coderbyheart/fw-nrfconnect-nrf-docker:latest /bin/bash

Then, inside the container:

    cd ncs/nrf/applications/asset_tracker
    west build -p always -b nrf9160_pca20035ns
    west flash
    west build
    ...

Meanwhile, inside or outside of the container, you may modify the code and repeat the build/flash cycle.

Later after closing the container you may re-open it by name to continue where you left off:

    docker start -i fw-nrfconnect-nrf-docker
