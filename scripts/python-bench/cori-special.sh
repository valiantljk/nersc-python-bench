#!/bin/bash -l

job_names=(
    mpi4py-import-cori-haswell-project-003
    pynamic-cori-haswell-project-003
    mpi4py-import-cori-haswell-project-150
    pynamic-cori-haswell-project-150
)

for name in ${job_names[@]}
do
    [ -z "$(squeue -u $USER -o '\%40j' | grep ${name})" ] && sbatch $name.sh
done
