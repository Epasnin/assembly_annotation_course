#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=quast
#SBATCH --array=0-2
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/logs/output_quast_%A_%a.o
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/logs/error_quast_%A_%a.e

WORKDIR="/data/users/epasnin/assembly_annotation_course"
OUTDIR="$WORKDIR/assembly_evaluation/QUAST"

CONTAINER="/containers/apptainer/quast_5.2.0.sif"
REFERENCE="/data/courses/assembly-annotation-course/references"

ASSEMBLIES=(
    "$WORKDIR/assemblies/flye/assembly.fasta"
    "$WORKDIR/assemblies/hifiasm/ERR11437352.fa"
    "$WORKDIR/assemblies/LJA/assembly.fasta"
)

NAMES=(
    "flye.quast"
    "hifiasm.quast"
    "LJA.quast"
)

INPUT="${ASSEMBLIES[$SLURM_ARRAY_TASK_ID]}"
NAME="${NAMES[$SLURM_ARRAY_TASK_ID]}"

apptainer exec \
    --bind "$WORKDIR" \
    --bind "$REFERENCE" \
    "$CONTAINER" \
    quast.py \
    -o "$OUTDIR/$NAME" \
    -r "$REFERENCE/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa" \
    --threads "$SLURM_CPUS_PER_TASK" \
    "$INPUT"
