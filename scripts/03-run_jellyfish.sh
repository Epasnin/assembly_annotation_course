#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=40G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=jellyfish
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=emma.pasnin@students.unibe.ch
#SBATCH --mail-type=END
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/logs/output_jellyfish_%j.o
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/logs/error_jellyfish_%j.e

WORKDIR=/data/users/epasnin/assembly_annotation_course
OUTDIR="$WORKDIR/read_QC/jellyfish"

# Create output directory
mkdir -p "$OUTDIR"

# Load the Jellyfish module
module load Jellyfish/2.3.0-GCC-10.3.0

# Count canonical 21-mers in the PacBio WGS reads
jellyfish count \
    -C \
    -m 21 \
    -s 5G \
    -t "$SLURM_CPUS_PER_TASK" \
    -o "$OUTDIR/ERR11437352_k21.jf" \
    <(zcat "$WORKDIR/Istisu-1/ERR11437352.fastq.gz")

#convert k-mer counts to histogram
jellyfish histo \
    -t "$SLURM_CPUS_PER_TASK" \
    "$OUTDIR/ERR11437352_k21.jf" \
    > "$OUTDIR/ERR11437352_k21.histo"
