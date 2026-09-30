#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=fastqc
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/logs/output_fastqc_%j.o
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/logs/error_fastqc_%j.e

WORKDIR=/data/users/epasnin/assembly_annotation_course
OUTDIR=/data/users/epasnin/assembly_annotation_course/read_QC/fastqc_results

mkdir -p "$OUTDIR"

apptainer exec \
    --bind "$WORKDIR" \
    /containers/apptainer/fastqc-0.12.1.sif \
    fastqc \
    --threads "$SLURM_CPUS_PER_TASK" \
    --outdir "$OUTDIR" \
    "$WORKDIR/Istisu-1/ERR11437352.fastq.gz" \
    "$WORKDIR/RNAseq_Sha/ERR754081_1.fastq.gz" \
    "$WORKDIR/RNAseq_Sha/ERR754081_2.fastq.gz"