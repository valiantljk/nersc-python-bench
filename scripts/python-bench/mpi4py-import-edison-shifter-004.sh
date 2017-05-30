#!/bin/bash
#SBATCH --account=nstaff
#SBATCH --image=docker:rcthomas/nersc-python-bench:0.1.6
#SBATCH --job-name=mpi4py-import-edison-shifter-004
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rcthomas@lbl.gov
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=24
#SBATCH --output=logs/mpi4py-import-edison-shifter-004-%j.out
#SBATCH --partition=regular
#SBATCH --qos=normal
#SBATCH --time=30

# Configuration.

commit=true

module load shifter

# Initialize benchmark result.

if [ $commit = true ]; then
    shifter python /usr/local/bin/report-benchmark.py initialize
fi

# Run benchmark.

export OMP_NUM_THREADS=1

output=tmp/latest-$SLURM_JOB_NAME.txt
srun shifter python /usr/local/bin/mpi4py-import.py $(date +%s) | tee $output

# Finalize benchmark result.

if [ $commit = true ]; then
    shifter python /usr/local/bin/report-benchmark.py finalize $( grep elapsed $output | awk '{ print $NF }' )
fi
