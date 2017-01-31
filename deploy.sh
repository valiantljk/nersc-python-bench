#!/bin/bash

origin_dir="$(dirname "$(readlink -f "$0")")"
artifacts_dir=$origin_dir/artifacts

# Verify host is Cori or Edison.

if [ -n "$NERSC_HOST" ]; then
    if [ "$NERSC_HOST" != "cori" ] && [ "$NERSC_HOST" != "edison" ]; then
        echo "FATAL illegal NERSC_HOST \"$NERSC_HOST\""
        exit 1
    fi
else
    echo "FATAL missing NERSC_HOST"
    exit 1
fi

# Determine deployment prefix, on shared filesystems append $NERSC_HOST to
# separate installation sites.

site=nersc-python-bench-site

target_dir=
if [ -n "$1" ]; then
    if [ "$1" = "common" ]; then
        target_dir=/global/common/shared/das/$site/$NERSC_HOST
    elif [ "$1" = "project" ]; then
        target_dir=/project/projectdirs/mpccc/$USER/$site/$NERSC_HOST
    elif [ "$1" = "scratch" ]; then
        target_dir=$SCRATCH/$site
    elif [ "$1" = "tmpfs" ]; then
        target_dir=/dev/shm/$site
    else
        echo "FATAL illegal configuration \"$1\""
        exit 1
    fi
else
    echo "FATAL missing configuration"
    exit 1
fi

echo
echo " *** $target_dir *** "
echo

# Delete any pre-existing deployment spot, create new one, move there.

rm -rf $target_dir
mkdir -p $target_dir
cd $target_dir

# Copy artifacts.

cp -rv $artifacts_dir/* .

# Unset Python variables.

unset PYTHONPATH
unset PYTHONSTARTUP
unset PYTHONUSERBASE

# Create Miniconda environment.

env_dir=$target_dir/env
bash Miniconda2-latest-Linux-x86_64.sh -b -p $env_dir

# Set path, install additional packages.

export PATH=$env_dir/bin:$PATH
conda install --copy --offline --quiet --yes *.tar.bz2
rm -rf file: # Temporary, see https://github.com/conda/conda/issues/3911

# Build, install mpi4py using GNU Cray compiler wrapper.

mpi4py=mpi4py-2.0.0

tar zxvf $mpi4py.tar.gz
cd $mpi4py
module swap PrgEnv-intel PrgEnv-gnu
if [ "$NERSC_HOST" = "cori" ]; then
    python setup.py build --mpicc=$(which cc)
else # Assuming this is Edison.
    LDFLAGS="-shared" python setup.py build --mpicc=$(which cc)
fi
python setup.py install

# Diagnostics.

echo which python
which python
echo

echo conda list
conda list
echo

echo strace -f -c python -c "import astropy"
strace -f -c python -c "import astropy"
echo

echo strace -f -c python -c "import astropy.table"
strace -f -c python -c "import astropy.table"
echo

# Build Pynamic.

cd $target_dir
pynamic=pynamic-1.3

tar zxvf $pynamic.tar.gz
cd $pynamic/pynamic-pyMPI-2.6a1

#python ./config_pynamic.py 5 2 -e -u 2 2 -n 100 -t -c --with-includes="-I${CRAY_MPICH2_DIR}/include" 'CPPFLAGS=-DPYMPI_MACOSX LDFLAGS="-L${CRAY_MPICH2_DIR}/lib -lmpich_gnu_51"'
python ./config_pynamic.py 495 1850 -e -u 215 1850 -n 100 -t -c --with-includes="-I${CRAY_MPICH2_DIR}/include" 'CPPFLAGS=-DPYMPI_MACOSX LDFLAGS="-L${CRAY_MPICH2_DIR}/lib -lmpich_gnu_51"'

