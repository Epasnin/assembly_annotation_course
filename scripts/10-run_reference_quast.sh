#!/usr/bin/env bash

#SBATCH --time=08:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=quast
#SBATCH --mail-user=emma.pasnin@students.unibe.ch
#SBATCH --mail-type=END
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/logs/output_quast_%j.o
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/logs/error_quast_%j.e

set -euo pipefail

WORKDIR=/data/users/epasnin/assembly_annotation_course
OUTDIR="$WORKDIR/assembly_evaluation/QUAST"
CONTAINER=/containers/apptainer/quast_5.2.0.sif
REFERENCE=/data/courses/assembly-annotation-course/references

FLYE="$WORKDIR/assemblies/flye/assembly.fasta"
HIFIASM="$WORKDIR/assemblies/hifiasm/ERR11437352.fa"
LJA="$WORKDIR/assemblies/LJA/assembly.fasta"

REF_GENOME="$REFERENCE/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"
ANNOTATION="$REFERENCE/Arabidopsis_thaliana.TAIR10.57.gff3"

mkdir -p "$OUTDIR"

# Check that all required files exist and are not empty
for FILE in "$FLYE" "$HIFIASM" "$LJA" "$REF_GENOME" "$ANNOTATION"; do
    [[ -s "$FILE" ]] || {
        echo "ERROR: File is missing or empty: $FILE"
        exit 1
    }
done

# Evaluate all three assemblies with the reference and annotation
apptainer exec \
    --bind "$WORKDIR" \
    --bind "$REFERENCE" \
    "$CONTAINER" \
    quast.py \
    "$FLYE" \
    "$HIFIASM" \
    "$LJA" \
    --labels "Flye,Hifiasm,LJA" \
    --reference "$REF_GENOME" \
    --features "$ANNOTATION" \
    --eukaryote \
    --large \
    --threads "$SLURM_CPUS_PER_TASK" \
    --output-dir "$OUTDIR/with_reference"

# Evaluate all three assemblies without a reference
apptainer exec \
    --bind "$WORKDIR" \
    "$CONTAINER" \
    quast.py \
    "$FLYE" \
    "$HIFIASM" \
    "$LJA" \
    --labels "Flye,Hifiasm,LJA" \
    --eukaryote \
    --large \
    --est-ref-size 135000000 \
    --threads "$SLURM_CPUS_PER_TASK" \
    --output-dir "$OUTDIR/without_reference"
