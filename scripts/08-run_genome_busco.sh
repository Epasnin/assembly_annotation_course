#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=busco
#SBATCH --array=0-2
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/logs/output_busco_%A_%a.o
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/logs/error_busco_%A_%a.e

set -euo pipefail

WORKDIR=/data/users/epasnin/assembly_annotation_course
OUTDIR="$WORKDIR/assembly_evaluation/BUSCO"
CONTAINER=/containers/apptainer/busco_5.7.1.sif

ASSEMBLIES=(
    "$WORKDIR/assemblies/flye/assembly.fasta"
    "$WORKDIR/assemblies/hifiasm/ERR11437352.fa"
    "$WORKDIR/assemblies/LJA/assembly.fasta"
)

NAMES=(
    "flye.busco"
    "hifiasm.busco"
    "LJA.busco"
)

INPUT="${ASSEMBLIES[$SLURM_ARRAY_TASK_ID]}"
NAME="${NAMES[$SLURM_ARRAY_TASK_ID]}"

mkdir -p "$OUTDIR"

apptainer exec \
    --bind "$WORKDIR" \
    "$CONTAINER" \
    busco \
    -i "$INPUT" \
    -m genome \
    -o "$NAME" \
    -l brassicales_odb10 \
    --cpu "$SLURM_CPUS_PER_TASK" \
    --out_path "$OUTDIR"