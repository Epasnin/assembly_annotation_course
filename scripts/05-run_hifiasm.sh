#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=hifiasm
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=emma.pasnin@students.unibe.ch
#SBATCH --mail-type=END
#SBATCH --output=/data/users/epasnin/assembly_annotation_course/logs/output_hifiasm_%j.o
#SBATCH --error=/data/users/epasnin/assembly_annotation_course/logs/error_hifiasm_%j.e

WORKDIR=/data/users/epasnin/assembly_annotation_course
OUTDIR="$WORKDIR/assemblies/hifiasm"
CONTAINER=/containers/apptainer/hifiasm_0.25.0.sif
READS="$WORKDIR/Istisu-1/ERR11437352.fastq.gz"
PREFIX="$OUTDIR/ERR11437352"

# Create output directory
mkdir -p "$OUTDIR"

apptainer exec \
    --bind "$WORKDIR" \
    "$CONTAINER" \
    hifiasm \
    -o "$OUTDIR/ERR11437352" \
    -t "$SLURM_CPUS_PER_TASK" \
    "$READS"

awk '/^S/{print ">"$2;print $3}' \
    "$OUTDIR/ERR11437352.bp.p_ctg.gfa" \
    > "$OUTDIR/ERR11437352.fa"