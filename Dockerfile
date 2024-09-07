FROM ubuntu:20.04

ENV BUILDROOT_DEPS="sed make binutils build-essential diffutils gcc g++ \
        bash patch gzip bzip2 perl tar cpio unzip rsync file bc findutils wget \
        python python3 git" \
    TOOLS="wget curl neofetch git bash nano" 

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