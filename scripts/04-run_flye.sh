#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=flye
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=emma.pasnin@students.unibe.ch
#SBATCH --mail-type=END
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/logs/output_flye_%j.o
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/logs/error_flye_%j.e

WORKDIR=/data/users/epasnin/assembly_annotation_course
OUTDIR="$WORKDIR/assemblies/flye"
CONTAINER=/containers/apptainer/flye_2.9.5.sif
READS="$WORKDIR/Istisu-1/ERR11437352.fastq.gz"

# Create output directory
mkdir -p "$OUTDIR"

apptainer exec \
    --bind "$WORKDIR" \
    "$CONTAINER" \
    flye \
    --pacbio-hifi "$READS" \
    --genome-size 135m \
    --threads "$SLURM_CPUS_PER_TASK" \
    --out-dir "$OUTDIR"
