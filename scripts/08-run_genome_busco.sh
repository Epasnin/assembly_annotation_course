#!/usr/bin/env bash

#SBATCH --time=08:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=busco
#SBATCH --array=0-2%2
#SBATCH --mail-user=emma.pasnin@students.unibe.ch
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/assembly_evaluation/BUSCO/slurm_busco_%A_%a.out
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/assembly_evaluation/BUSCO/slurm_busco_%A_%a.err

set -euo pipefail

WORKDIR=/data/users/epasnin/assembly_annotation_course
OUTDIR="$WORKDIR/assembly_evaluation/BUSCO"
CONTAINER=/containers/apptainer/busco_5.7.1.sif

BUSCO_DB=/data/databases/busco5/busco_database
LINEAGE="$BUSCO_DB/lineages/brassicales_odb10"

ASSEMBLIES=(
    "$WORKDIR/assemblies/flye/assembly.fasta"
    "$WORKDIR/assemblies/hifiasm/ERR11437352.fa"
    "$WORKDIR/assemblies/LJA/assembly.fasta"
)

NAMES=(
    "flye_busco"
    "hifiasm_busco"
    "LJA_busco"
)

INPUT="${ASSEMBLIES[$SLURM_ARRAY_TASK_ID]}"
NAME="${NAMES[$SLURM_ARRAY_TASK_ID]}"

mkdir -p "$OUTDIR"

# Confirm that the selected assembly exists and is not empty
[[ -s "$INPUT" ]] || {
    echo "ERROR: Assembly is missing or empty: $INPUT"
    exit 1
}

# Confirm that the local BUSCO lineage exists
[[ -d "$LINEAGE" ]] || {
    echo "ERROR: BUSCO lineage is missing: $LINEAGE"
    exit 1
}

# Confirm that the BUSCO container exists
[[ -s "$CONTAINER" ]] || {
    echo "ERROR: BUSCO container is missing: $CONTAINER"
    exit 1
}

echo "BUSCO array task: $SLURM_ARRAY_TASK_ID"
echo "Assembly: $INPUT"
echo "Output name: $NAME"
echo "Lineage: $LINEAGE"

# BUSCO writes its internal log into the current working directory
cd "$OUTDIR"

apptainer exec \
    --bind "$WORKDIR" \
    --bind "$BUSCO_DB" \
    "$CONTAINER" \
    busco \
    -i "$INPUT" \
    -m genome \
    -o "$NAME" \
    -l "$LINEAGE" \
    --offline \
    --cpu "$SLURM_CPUS_PER_TASK" \
    --out_path "$OUTDIR"