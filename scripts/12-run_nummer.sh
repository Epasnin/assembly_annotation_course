#!/usr/bin/env bash

#SBATCH --time=6:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=mummer
#SBATCH --mail-user=emma.pasnin@students.unibe.ch
#SBATCH --mail-type=END
#SBATCH --array=0-5
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/logs/output_mummer_%A_%a.o
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/logs/error_mummer_%A_%a.e

set -euo pipefail

WORKDIR=/data/users/epasnin/assembly_annotation_course
OUTDIR="$WORKDIR/assembly_evaluation/MUMMER"
CONTAINER=/containers/apptainer/mummer4_gnuplot.sif

REFERENCE_DIR=/data/courses/assembly-annotation-course/references
TAIR10="$REFERENCE_DIR/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"

FLYE="$WORKDIR/assemblies/flye/assembly.fasta"
HIFIASM="$WORKDIR/assemblies/hifiasm/ERR11437352.fa"
LJA="$WORKDIR/assemblies/LJA/assembly.fasta"

# Reference sequence for each comparison
REFERENCES=(
    "$TAIR10"
    "$TAIR10"
    "$TAIR10"
    "$FLYE"
    "$FLYE"
    "$HIFIASM"
)

# Query sequence for each comparison
QUERIES=(
    "$FLYE"
    "$HIFIASM"
    "$LJA"
    "$HIFIASM"
    "$LJA"
    "$LJA"
)

NAMES=(
    "TAIR10_vs_Flye"
    "TAIR10_vs_Hifiasm"
    "TAIR10_vs_LJA"
    "Flye_vs_Hifiasm"
    "Flye_vs_LJA"
    "Hifiasm_vs_LJA"
)

REFERENCE="${REFERENCES[$SLURM_ARRAY_TASK_ID]}"
QUERY="${QUERIES[$SLURM_ARRAY_TASK_ID]}"
NAME="${NAMES[$SLURM_ARRAY_TASK_ID]}"

RESULTDIR="$OUTDIR/$NAME"
PREFIX="$RESULTDIR/$NAME"

mkdir -p "$RESULTDIR"

# Check the selected input files
for FILE in "$REFERENCE" "$QUERY"; do
    [[ -s "$FILE" ]] || {
        echo "ERROR: File is missing or empty: $FILE"
        exit 1
    }
done

echo "Comparison: $NAME"
echo "Reference: $REFERENCE"
echo "Query: $QUERY"

# Align query against reference
apptainer exec \
    --bind "$WORKDIR" \
    --bind "$REFERENCE_DIR" \
    "$CONTAINER" \
    nucmer \
    --prefix "$PREFIX" \
    --breaklen 1000 \
    --mincluster 1000 \
    --threads "$SLURM_CPUS_PER_TASK" \
    "$REFERENCE" \
    "$QUERY"

# Generate a PNG dot plot from the delta file
apptainer exec \
    --bind "$WORKDIR" \
    --bind "$REFERENCE_DIR" \
    "$CONTAINER" \
    mummerplot \
    -R "$REFERENCE" \
    -Q "$QUERY" \
    --filter \
    -t png \
    --large \
    --layout \
    --fat \
    --prefix "$PREFIX" \
    "$PREFIX.delta"