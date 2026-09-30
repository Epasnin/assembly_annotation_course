#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=fastp
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=emma.pasnin@students.unibe.ch
#SBATCH --mail-type=END
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/logs/output_fastp_%j.o
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/logs/error_fastp_%j.e

WORKDIR=/data/users/epasnin/assembly_annotation_course
OUTDIR="$WORKDIR/read_QC/fastp"

mkdir -p "$OUTDIR"

# 1. Trim and filter paired-end Illumina RNA-seq reads
apptainer exec \
    --bind "$WORKDIR" \
    /containers/apptainer/fastp_0.24.1.sif \
    fastp \
    --in1 "$WORKDIR/RNAseq_Sha/ERR754081_1.fastq.gz" \
    --in2 "$WORKDIR/RNAseq_Sha/ERR754081_2.fastq.gz" \
    --out1 "$OUTDIR/ERR754081_1_trimmed.fastq.gz" \
    --out2 "$OUTDIR/ERR754081_2_trimmed.fastq.gz" \
    --html "$OUTDIR/ERR754081_fastp.html" \
    --json "$OUTDIR/ERR754081_fastp.json" \
    --thread "$SLURM_CPUS_PER_TASK" \
    --detect_adapter_for_pe

# 2. Examine PacBio HiFi reads without filtering or trimming
apptainer exec \
    --bind "$WORKDIR" \
    /containers/apptainer/fastp_0.24.1.sif \
    fastp \
    --in1 "$WORKDIR/Istisu-1/ERR11437352.fastq.gz" \
    --out1 /dev/null \
    --html "$OUTDIR/ERR11437352_fastp.html" \
    --json "$OUTDIR/ERR11437352_fastp.json" \
    --thread "$SLURM_CPUS_PER_TASK" \
    --disable_adapter_trimming \
    --disable_quality_filtering \
    --disable_length_filtering