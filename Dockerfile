FROM ubuntu:20.04

ENV BUILDROOT_DEPS="sed make binutils build-essential diffutils gcc g++ \
        bash patch gzip bzip2 perl tar cpio unzip rsync file bc findutils wget \
        python python3 libncurses5 libncurses5-dev cvs git asciidoc w3m" \
    # https://github.com/AdvancedClimateSystems/docker-buildroot/blob/master/Dockerfile
    DOCKER_BUILDROOT_DEPS="locales libdevmapper-dev libsystemd-dev \
        mercurial whois vim bison flex libssl-dev libfdt-dev" \
    EXTRA_DEPS="net-tools rlwrap swig  subversion libtinfo5 patchelf \
        libidn11-dev autoconf automake libtool asciidoctor elfutils \
        texinfo zlib1g-dev gcc-multilib gettext pkg-config cmake \
        ccache m4 linux-headers-generic" \
    TOOLS="wget curl neofetch git bash nano openssh-client screen sudo" 

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y $BUILDROOT_DEPS 
RUN apt-get install -y $DOCKER_BUILDROOT_DEPS 
RUN apt-get install -y $EXTRA_DEPS 
RUN apt-get install -y $TOOLS

RUN apt-get clean && apt-get autoclean 

RUN locale-gen en_US.utf8
WORKDIR /root/buildroot

CMD ["/bin/bash"]