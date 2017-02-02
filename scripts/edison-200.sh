#!/bin/bash -l

job_names=(
    mpi4py-import-edison-common-200
    mpi4py-import-edison-project-200
    mpi4py-import-edison-scratch-200
    pynamic-edison-common-200
    pynamic-edison-project-200
    pynamic-edison-scratch-200
)

for name in ${job_names[@]}
do
    [ -z "$(squeue -u $USER -o '\%40j' | grep ${name})" ] && sbatch $name.sh
done
