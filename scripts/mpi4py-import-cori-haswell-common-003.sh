#!/bin/bash 
#SBATCH --account=nstaff
#SBATCH --constraint=haswell
#SBATCH --job-name=mpi4py-import-cori-haswell-common-003
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rcthomas@lbl.gov
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=32
#SBATCH --output=logs/mpi4py-import-cori-haswell-common-003-%j.out
#SBATCH --partition=regular
#SBATCH --qos=normal
#SBATCH --time=30

# Configuration.

commit=false

site=nersc-python-bench-site
target_dir=/global/common/shared/das/$site/$NERSC_HOST
env_dir=$target_dir/env

# Environment.

unset PYTHONPATH
unset PYTHONSTARTUP
unset PYTHONUSERBASE
export PATH=$env_dir/bin:$PATH

# Sanity checks.

which python
python -c 'import sys; print "\n".join(sys.path)'
python -c "import astropy; print astropy.__path__"
strace -f -c python -c "import astropy"

# Initialize benchmark result.

if [ $commit = true ]; then
    python report-benchmark.py initialize
fi

# Run benchmark.

output=tmp/latest-$SLURM_JOB_NAME.txt
time srun python mpi4py-import.py $(date +%s) | tee $output

# Finalize benchmark result.

if [ $commit = true ]; then
    python report-benchmark.py finalize $( grep elapsed $output | awk '{ print $NF }' )
fi
