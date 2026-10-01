#!/usr/bin/env bash

#SBATCH --time=12:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=merqury
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=emma.pasnin@students.unibe.ch
#SBATCH --mail-type=END
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/logs/output_merqury_%j.o
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/logs/error_merqury_%j.e

set -euo pipefail

WORKDIR=/data/users/epasnin/assembly_annotation_course
OUTDIR="$WORKDIR/assembly_evaluation/MERQURY"
CONTAINER=/containers/apptainer/merqury_1.3.sif

READS="$WORKDIR/Istisu-1/ERR11437352.fastq.gz"

FLYE="$WORKDIR/assemblies/flye/assembly.fasta"
HIFIASM="$WORKDIR/assemblies/hifiasm/ERR11437352.fa"
LJA="$WORKDIR/assemblies/LJA/assembly.fasta"

MERYL_DB="$OUTDIR/ERR11437352_k21.meryl"

# Location of Merqury inside the container
export MERQURY=/usr/local/share/merqury

mkdir -p "$OUTDIR"

# Check the required input files
for FILE in "$READS" "$FLYE" "$HIFIASM" "$LJA"; do
    [[ -s "$FILE" ]] || {
        echo "ERROR: File is missing or empty: $FILE"
        exit 1
    }
done

# Create a Meryl database of canonical 21-mers from the PacBio HiFi reads
apptainer exec \
    --bind "$WORKDIR" \
    "$CONTAINER" \
    meryl \
    k=21 \
    count \
    output "$MERYL_DB" \
    "$READS"

# Run each Merqury analysis from the output directory
cd "$OUTDIR"

apptainer exec \
    --bind "$WORKDIR" \
    "$CONTAINER" \
    "$MERQURY/merqury.sh" \
    "$MERYL_DB" \
    "$FLYE" \
    "flye"

apptainer exec \
    --bind "$WORKDIR" \
    "$CONTAINER" \
    "$MERQURY/merqury.sh" \
    "$MERYL_DB" \
    "$HIFIASM" \
    "hifiasm"

apptainer exec \
    --bind "$WORKDIR" \
    "$CONTAINER" \
    "$MERQURY/merqury.sh" \
    "$MERYL_DB" \
    "$LJA" \
    "LJA"