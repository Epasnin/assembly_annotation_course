#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=busco
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/logs/output_busco_%j.o
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/logs/error_busco_%j.e

set -euo pipefail

WORKDIR=/data/users/epasnin/assembly_annotation_course
OUTDIR="$WORKDIR/assembly_evaluation/BUSCO"
CONTAINER=/containers/apptainer/busco_5.7.1.sif

mkdir -p "$OUTDIR"

apptainer exec \
    --bind "$WORKDIR" \
    "$CONTAINER" \
    busco \
    -i "$WORKDIR/assemblies/trinity.Trinity.fasta" \
    -m transcriptome \
    -o trinity_busco \
    -l brassicales_odb10 \
    --cpu "$SLURM_CPUS_PER_TASK" \
    --out_path "$OUTDIR"