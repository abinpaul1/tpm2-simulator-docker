FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

# bring in dependencies
RUN apt-get update && \
    apt-get --yes --quiet install build-essential python3-setuptools python3-dev python3-pip git automake autoconf curl \
    pkg-config autoconf-archive libtool libcurl4-openssl-dev libgmp-dev \
    libssl-dev cmake trousers tpm-tools alien software-properties-common && \
    apt-get clean &&  \
    rm -rf /var/lib/apt/lists* /tmp/* /var/tmp/*

RUN apt-add-repository universe
RUN apt-get update
RUN apt-get install -y libjson-c-dev acl

# Install behave and hamcrest for testing
RUN pip3 install behave pyhamcrest requests pexpect

RUN ln -s /usr/bin/python3 /usr/bin/python

# add lib64 to LD_LIBRARY_PATH
RUN echo "# RHEL lib location compatibility" >> /etc/ld.so.conf.d/lib64.conf && \
    echo "/usr/lib64" >> /etc/ld.so.conf.d/lib64.conf && \
    ldconfig

# have trousers always connect to the tpm-emulator
ENV TCSD_USE_TCP_DEVICE=1

# the trousers listens on ports 2412
EXPOSE 2412

# tpm2-emulator
ADD ibmtpm1661.tar.gz ibmtpm
RUN cd ibmtpm && \
    cd src && \
    make && \
    mv tpm_server /usr/local/bin/ && \
    cd && \
    rm -rf ibmtpm ibmtpm1661.tar.gz

# tpm2-tss
ADD tpm2-tss-3.1.0.tar.gz tpm2-tss-3.1.0
RUN cd tpm2-tss-3.1.0/tpm2-tss-3.1.0 && \
    ./configure --prefix=/usr && \
    CXXFLAGS="-Wno-error" make && \
    make install && \
    cd && \
    rm -rf tpm2-tss-3.1.0 && \
    ldconfig

# tpm2-tools
ADD tpm2-tools-5.2.tar.gz tpm2-tools-5.2
RUN cd tpm2-tools-5.2/tpm2-tools-5.2 && \
    ./bootstrap && \
    ./configure --prefix=/usr --disable-hardening --with-tcti-socket --with-tcti-device && \
    make && \
    make install && \
    cd && \
    rm -rf tpm2-tools-5.2 && \
    ldconfig

# Setup tpm2_pytss
RUN python -m pip install tpm2-pytss

# have the tpm2 tools always connect to the socket
ENV TPM2TOOLS_TCTI_NAME=socket
ENV TPM2TOOLS_TCTI="mssim:host=localhost,port=2321"

# the TPM2 emulator listens on ports 2321 and 2322.
EXPOSE 2321
EXPOSE 2322
