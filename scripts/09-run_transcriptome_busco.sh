#!/usr/bin/env bash

#SBATCH --time=08:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=busco_trinity
#SBATCH --mail-user=emma.pasnin@students.unibe.ch
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/assembly_evaluation/BUSCO/slurm_busco_trinity_%j.out
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/assembly_evaluation/BUSCO/slurm_busco_trinity_%j.err

set -euo pipefail

WORKDIR=/data/users/epasnin/assembly_annotation_course
OUTDIR="$WORKDIR/assembly_evaluation/BUSCO"
CONTAINER=/containers/apptainer/busco_5.7.1.sif
TRANSCRIPTS="$WORKDIR/assemblies/trinity.Trinity.fasta"

BUSCO_DB=/data/databases/busco5/busco_database
LINEAGE="$BUSCO_DB/lineages/brassicales_odb10"

mkdir -p "$OUTDIR"

[[ -s "$TRANSCRIPTS" ]] || {
    echo "ERROR: Trinity assembly is missing or empty: $TRANSCRIPTS"
    exit 1
}

[[ -d "$LINEAGE" ]] || {
    echo "ERROR: BUSCO lineage is missing: $LINEAGE"
    exit 1
}

[[ -s "$CONTAINER" ]] || {
    echo "ERROR: BUSCO container is missing: $CONTAINER"
    exit 1
}

echo "Input transcriptome: $TRANSCRIPTS"
echo "Lineage: $LINEAGE"
echo "Output: $OUTDIR/trinity_busco"

# BUSCO writes its internal busco_*.log file to the current directory
cd "$OUTDIR"

apptainer exec \
    --bind "$WORKDIR" \
    --bind "$BUSCO_DB" \
    "$CONTAINER" \
    busco \
    -i "$TRANSCRIPTS" \
    -m transcriptome \
    -o trinity_busco \
    -l "$LINEAGE" \
    --offline \
    --cpu "$SLURM_CPUS_PER_TASK" \
    --out_path "$OUTDIR"