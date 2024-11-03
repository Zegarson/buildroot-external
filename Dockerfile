FROM ubuntu:22.04

ENV BUILDROOT_DEPS="sed make debianutils binutils build-essential diffutils gcc g++ \
                    patch gzip bzip2 perl tar cpio unzip rsync file bc findutils python3 \
                    libssl-dev" \
    TOOLS="sudo wget curl neofetch git bash nano locales ca-certificates graphviz" \
    DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y $BUILDROOT_DEPS $TOOLS

RUN locale-gen en_US.utf8
WORKDIR /root/buildroot

CMD ["/bin/bash"]