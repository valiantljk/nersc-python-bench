#!/bin/bash
# -----------------------------------------------------------------------------
# Collect artifacts needed for deploying benchmark environments:
#
# * Miniconda installer script;
# * Anaconda tar.bz2 package archives needed for running and reporting tests;
# * mpi4py tar.gz source archive; and
# * pynamic tar.gz source archive.
# -----------------------------------------------------------------------------

# Define artifacts directory strictly relative to where init.sh runs.

origin_dir="$(dirname "$(readlink -f "$0")")"
artifacts_dir=$origin_dir/artifacts

# Delete any pre-existing artifacts directory, create new one, move there.

rm -rf $artifacts_dir
mkdir -p $artifacts_dir
cd $artifacts_dir

# Download latest Miniconda installer script.

wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh

# Create temporary Miniconda environment to get package archives easily.

env_dir=$artifacts_dir/env
bash Miniconda2-latest-Linux-x86_64.sh -b -p $env_dir

# Extract archives of necessary packages.
#
# Set environment path, install necessary packages to environment, pull package
# archives into artifacts directory, then delete environment.  Cannot do this
# in offline mode.

export PATH=$env_dir/bin:$PATH

conda update --all --yes
conda install --yes astropy mysql-python

env_pkgs_dir=$env_dir/pkgs
cp -v $env_pkgs_dir/astropy-*.tar.bz2 .
cp -v $env_pkgs_dir/mkl-*.tar.bz2 .
cp -v $env_pkgs_dir/mysql-python-*.tar.bz2 .
cp -v $env_pkgs_dir/numpy-*.tar.bz2 .
rm -rf $env_dir

# Download mpi4py source.

mpi4py=mpi4py-2.0.0
wget https://bitbucket.org/mpi4py/mpi4py/downloads/$mpi4py.tar.gz

# Download Pynamic 1.3 source.

pynamic_version=1.3
pynamic=pynamic-$pynamic_version

wget -O $pynamic.tar.gz https://github.com/LLNL/pynamic/archive/$pynamic_version.tar.gz
