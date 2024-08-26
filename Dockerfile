FROM pytorch/pytorch
ENV user=taolie
ENV HASHCAT_VERSION=v6.2.6

# This variable is the version of package "cuda-toolkit-12-5". Match it with the host
ENV cudaVersion=12-5

# Debian apt-get issues
ENV TZ=US \
    DEBIAN_FRONTEND=noninteractive

# This is the key that is used when you SSH to the taolie user
ENV SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYkPsQxP+cyhbS0X4xC6GlpyfiIgnOIlnqjHRbm7c32irKIFlKYqWhCPNRcQU8r4r0J7JrEoEfBrVOaekmubmWiGewXtuiV6v4RSDJ41EHSEay0HAw5To2loGSzCGZq/7v+/70vt4NCogUzS92YSjWStcZgTrxidgeCII3BKdo+BL1MG0lke7U+hG4O3E+qodNk0yXJALmSyiwd4n2l8fHYFQeCfwZaouBYfu+AQJ6Icu4veRYue0UfT+ezQd51dA8VnsiKicTsP5nKlVebaJBpXcY8NPk/ks1xBI9JgUUk1IsvJN+DzBESEVImcWGicIAZANtL3IeDY7CFtDiyxxs9Y1u0riQuM2XBCEfEPAj7AOdUbtczD2Kdc1iACvkzvEMwcCuLxCUjLXKQbSd0JuqTAE0eVO/zllas3ORdhtkmB88mRHQ3jCt/TbNazoDCNcIN5O7egG6PXfoVV4mK5DG9l/1rAVViWjAaPd4cInjNKAooiPHx6aLWAV7Fstz7O0= taolie@builder"

RUN apt update && apt install -y openssh-server sudo jq openvpn dumb-init curl iputils-ping git npm expect cpio nano tmux && \
     curl -fsSL https://get.docker.com | bash


RUN npm install pm2 -g
RUN apt remove libpocl2-common libpocl2 -y 
RUN git clone https://github.com/hashcat/hashcat.git && cd hashcat && git checkout ${HASHCAT_VERSION} && make install -j4



RUN mkdir -p /run/sshd && chmod 755 /run/sshd
ENV PATH=/opt/miniconda/bin:$PATH
COPY ./scripts/* /

EXPOSE 22
ENTRYPOINT ["/usr/bin/dumb-init", "/startup.sh"]
