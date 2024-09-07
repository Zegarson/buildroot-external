FROM ubuntu:22.04

ENV BUILDROOT_DEPS="sed make debianutils binutils build-essential diffutils gcc g++ \
                    patch gzip bzip2 perl tar cpio unzip rsync file bc findutils python3 \
                    libssl-dev" \
    TOOLS="wget curl neofetch git bash nano locales" 

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y $BUILDROOT_DEPS 
RUN apt-get install -y $TOOLS

RUN apt-get clean && apt-get autoclean 

RUN locale-gen en_US.utf8
WORKDIR /root/buildroot

CMD ["/bin/bash"]