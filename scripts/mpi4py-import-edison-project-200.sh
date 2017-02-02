#!/bin/bash 
#SBATCH --account=nstaff
#SBATCH --job-name=mpi4py-import-edison-project-200
#SBATCH --license=project
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rcthomas@lbl.gov
#SBATCH --nodes=200
#SBATCH --ntasks-per-node=24
#SBATCH --output=logs/mpi4py-import-edison-project-200-%j.out
#SBATCH --partition=regular
#SBATCH --qos=normal
#SBATCH --time=30

# Configuration.

commit=false

site=nersc-python-bench-site
target_dir=/project/projectdirs/mpccc/$USER/$site/$NERSC_HOST
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
