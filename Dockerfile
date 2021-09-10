# Source: https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/nrf/gs_installing.html

# Base image which contains global dependencies
FROM ubuntu:20.10 as base
WORKDIR /ncs

ARG NCS_REVISION=master
ENV NCS_REVISION=${NCS_REVISION}

ENV DEBIAN_FRONTEND=noninteractive

# System dependencies
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt install -y --no-install-recommends \
        git cmake ninja-build gperf \
        ccache dfu-util device-tree-compiler wget \
        python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
        make gcc gcc-multilib g++-multilib libsdl2-dev \
        # process .tar.bz2
        bzip2  \
        # nRF-command-line-tools dependency
        libncurses5 && \
    rm -rf /var/lib/apt/lists/* && \
    # GCC ARM Embed Toolchain
    wget -qO- \
    'https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2?revision=108bd959-44bd-4619-9c19-26187abf5225&la=en&hash=E788CE92E5DFD64B2A8C246BBA91A249CB8E2D2D' \
    | tar xj && \
    mkdir tmp && cd tmp && \
    # Nordic command line tools
    # Releases: https://www.nordicsemi.com/Software-and-tools/Development-Tools/nRF-Command-Line-Tools/Download
    wget -q https://www.nordicsemi.com/-/media/Software-and-other-downloads/Desktop-software/nRF-command-line-tools/sw/Versions-10-x-x/10-13-0/nRF-Command-Line-Tools_10_13_0_Linux64.zip && \
    unzip nRF-Command-Line-Tools_10_13_0_Linux64.zip && \
    tar xvzf nRF-Command-Line-Tools_10_13_0_Linux64/nRF-Command-Line-Tools_10_13_0_Linux-amd64.tar.gz && \
    dpkg -i *.deb && \
    cd .. && rm -rf tmp && \
    pip3 install -U pip

# Build image, contains project-specific dependencies
FROM base
COPY entrypoint.sh .
RUN chmod +x ./entrypoint.sh && \
    # Zephyr requirements of nrf
    pip3 install -U west && \
    west init -m https://github.com/nrfconnect/sdk-nrf --mr ${NCS_REVISION} && \
    west update && \
    west zephyr-export && \
    pip3 install -r zephyr/scripts/requirements.txt && \
    pip3 install -r nrf/scripts/requirements.txt && \
    pip3 install -r bootloader/mcuboot/scripts/requirements.txt && \
    pip3 cache purge && rm -rf /root/.cache

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
ENV GNUARMEMB_TOOLCHAIN_PATH=/ncs/gcc-arm-none-eabi-9-2019-q4-major

ENTRYPOINT ["/ncs/entrypoint.sh"]
