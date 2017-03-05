#!/bin/bash -l

job_names=(
    mpi4py-import-cori-haswell-common-003
    mpi4py-import-cori-haswell-project-003
    mpi4py-import-cori-haswell-scratch-003
    mpi4py-import-cori-haswell-shifter-003
    pynamic-cori-haswell-common-003
    pynamic-cori-haswell-project-003
    pynamic-cori-haswell-scratch-003
)

for name in ${job_names[@]}
do
    [ -z "$(squeue -u $USER -o '\%40j' | grep ${name})" ] && sbatch $name.sh
done
