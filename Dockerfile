# Use latest CentOs image as base image
FROM centos:latest

# Prepare dependencies for build
RUN yum groupinstall -y 'Development Tools'

# Install CERN package and its dependencies
RUN yum install -y epel-release && yum install -y root rsync wget which
RUN yum install -y git cmake3 gcc-c++ gcc binutils libX11-devel libXpm-devel libXft-devel libXext-devel openssl-devel
WORKDIR /opt

# Install FastJet
WORKDIR /opt
RUN wget http://fastjet.fr/repo/fastjet-3.3.4.tar.gz  && \
    tar -xvzf fastjet-3.3.4.tar.gz && \
    mkdir fastjet
WORKDIR /opt/fastjet-3.3.4/
RUN ./configure --prefix=/opt/fastjet --disable-auto-ptr && \
    make && \
    make install
WORKDIR /opt

# Install FastJet contrib
RUN wget http://fastjet.hepforge.org/contrib/downloads/fjcontrib-1.045.tar.gz && \
    tar -xvzf fjcontrib-1.045.tar.gz
WORKDIR /opt/fjcontrib-1.045
RUN ./configure --fastjet-config=/opt/fastjet/bin/fastjet-config && \
    make && \
    make install

# Install RooUnfold
WORKDIR /opt
RUN git clone https://gitlab.cern.ch/RooUnfold/RooUnfold.git
WORKDIR /opt/RooUnfold
RUN make

# Set PATH variables
ENV PATH=/opt/pythia8303/bin/:/opt/fastjet/bin/:/opt/RooUnfold/:$PATH

# Install TStarJetPico for reading data 
WORKDIR /opt
RUN git clone https://github.com/imooney/eventStructuredAu.git
WORKDIR /opt/eventStructuredAu
ENV ROOTSYS=/usr/bin/root
RUN make 

# Set PATH variables
ENV PATH=/opt/eventStructuredAu/:$PATH

RUN mkdir /work
WORKDIR /work
ENTRYPOINT ["/bin/bash"]
