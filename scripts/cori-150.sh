#!/bin/bash -l

job_names=(
    mpi4py-import-cori-haswell-common-150
    mpi4py-import-cori-haswell-project-150
    mpi4py-import-cori-haswell-scratch-150
    pynamic-cori-haswell-common-150
    pynamic-cori-haswell-project-150
    pynamic-cori-haswell-scratch-150
)

for name in ${job_names[@]}
do
    [ -z "$(squeue -u $USER -o '\%40j' | grep ${name})" ] && sbatch $name.sh
done
