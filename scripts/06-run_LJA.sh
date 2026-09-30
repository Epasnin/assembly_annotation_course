#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=LJA
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=emma.pasnin@students.unibe.ch
#SBATCH --mail-type=END
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/logs/output_LJA_%j.o
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/logs/error_LJA_%j.e

WORKDIR=/data/users/epasnin/assembly_annotation_course
OUTDIR="$WORKDIR/assemblies/LJA"
CONTAINER=/containers/apptainer/lja-0.2.sif

mkdir -p "$OUTDIR"

apptainer exec \
    --bind "$WORKDIR" \
    "$CONTAINER" \
    lja \
    --reads "$WORKDIR/Istisu-1/ERR11437352.fastq.gz" \
    -o "$OUTDIR" \
    -t "$SLURM_CPUS_PER_TASK"
