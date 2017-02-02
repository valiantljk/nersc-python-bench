
FROM ubuntu:16.04
MAINTAINER Rollin Thomas

# Update and install prerequisites

RUN                                 \
    apt-get update              &&  \
    apt-get install -y              \
        build-essential             \
        gfortran

# Install MPICH

ADD http://www.mpich.org/static/downloads/3.2/mpich-3.2.tar.gz              \
    /usr/local/src/

RUN                                                                         \
    cd /usr/local/src                                                   &&  \
    tar xf mpich-3.2.tar.gz                                             &&  \
    cd mpich-3.2                                                        &&  \
    ./configure                                                         &&  \
    make -j 2                                                           &&  \
    make install                                                        &&  \
    cd /usr/local/src                                                   &&  \
    rm -rf mpich-3.2

# Install Miniconda and packages

ADD https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh   \
    /usr/local/src/

RUN                                                                         \
    cd /usr/local/src                                                   &&  \
    /bin/bash ./Miniconda2-latest-Linux-x86_64.sh -b -p /miniconda2

ENV PATH /miniconda2/bin:$PATH

RUN                                                                         \
    conda upgrade --yes --all                                           &&  \
    conda install --yes astropy

# Install mpi4py

ADD https://bitbucket.org/mpi4py/mpi4py/downloads/mpi4py-2.0.0.tar.gz       \
    /usr/local/src/

RUN                                                                         \
    cd /usr/local/src                                                   &&  \
    tar zxf mpi4py-2.0.0.tar.gz                                         &&  \
    cd mpi4py-2.0.0                                                     &&  \
    python setup.py build                                               &&  \
    python setup.py install                                             &&  \
    cd /usr/local/src                                                   &&  \
    rm -rf mpi4py-2.0.0

# Install mpi4py-import benchmark script

ADD scripts/mpi4py-import.py /usr/local/bin

RUN chmod a+x /usr/local/bin/mpi4py-import.py

# Install pynamic v1.3

ADD https://github.com/LLNL/pynamic/archive/1.3.tar.gz                      \
    /usr/local/src

RUN                                                                         \
    cd /usr/local/src                                                   &&  \
    tar zxf 1.3.tar.gz                                                  &&  \
    cd pynamic-1.3/pynamic-pyMPI-2.6a1                                  &&  \
    python ./config_pynamic.py 495 1850 -e -u 215 1850 -n 100 -t -c --with-libs="m" "CPPFLAGS=-DPYMPI_MACOSX"