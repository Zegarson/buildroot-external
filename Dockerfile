FROM ubuntu:22.04

ENV BUILDROOT_DEPS="sed make debianutils binutils build-essential diffutils gcc g++ \
                    patch gzip bzip2 perl tar cpio unzip rsync file bc findutils python3 \
                    libssl-dev" \
    TOOLS="sudo wget curl neofetch git bash nano locales ca-certificates" \
    DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y && \
    apt install -y $BUILDROOT_DEPS $TOOLS

RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt update && \
    apt install -y docker-ce-cli && \
    apt clean && apt autoclean 

RUN locale-gen en_US.utf8
WORKDIR /root/buildroot

CMD ["/bin/bash"]