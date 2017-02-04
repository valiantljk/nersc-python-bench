#!/bin/bash
#SBATCH --account=nstaff
#SBATCH --image=docker:rcthomas/nersc-python-bench:0.1.1
#SBATCH --job-name=mpi4py-import-edison-shifter-200
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=rcthomas@lbl.gov
#SBATCH --nodes=200
#SBATCH --ntasks-per-node=24
#SBATCH --output=logs/mpi4py-import-edison-shifter-200-%j.out
#SBATCH --partition=regular
#SBATCH --qos=normal
#SBATCH --time=30

# Configuration.

commit=true

# Run benchmark.

module load shifter

export OMP_NUM_THREADS=1

output=tmp/latest-$SLURM_JOB_NAME.txt
srun shifter python /usr/local/bin/mpi4py-import.py $(date +%s) | tee $output
