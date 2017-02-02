#!/bin/bash -l

job_names=(
    mpi4py-import-edison-common-004
    mpi4py-import-edison-project-004
    mpi4py-import-edison-scratch-004
    pynamic-edison-common-004
    pynamic-edison-project-004
    pynamic-edison-scratch-004
)

for name in ${job_names[@]}
do
    [ -z "$(squeue -u $USER -o '\%40j' | grep ${name})" ] && sbatch $name.sh
done
