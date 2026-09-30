#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=trinity
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=emma.pasnin@students.unibe.ch
#SBATCH --mail-type=END
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/logs/output_trinity_%j.o
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/logs/error_trinity_%j.e

set -euo pipefail

WORKDIR=/data/users/epasnin/assembly_annotation_course
OUTDIR="$WORKDIR/assemblies/trinity"
LEFT="$WORKDIR/read_QC/fastp/ERR754081_1_trimmed.fastq.gz"
RIGHT="$WORKDIR/read_QC/fastp/ERR754081_2_trimmed.fastq.gz"

#load modules
module load Trinity/2.15.1-foss-2021a

Trinity \
    --seqType fq \
    --left "$LEFT" \
    --right "$RIGHT" \
    --CPU "$SLURM_CPUS_PER_TASK" \
    --max_memory 64G \
    --output "$OUTDIR"

