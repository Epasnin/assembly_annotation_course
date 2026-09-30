# De novo genome and transcriptome assembly of *Arabidopsis thaliana*

## Project overview

This project performs quality control, genome-size estimation, de novo genome assembly and de novo transcriptome assembly using sequencing data from *Arabidopsis thaliana*.

PacBio HiFi whole-genome sequencing reads are used for genome analysis and assembly. Paired-end Illumina RNA-seq reads are quality-filtered and used for transcriptome assembly.

## Input data

| Dataset | File(s) | Sequencing type | Purpose |
|---|---|---|---|
| PacBio WGS | `Istisu-1/ERR11437352.fastq.gz` | PacBio HiFi | Genome-size estimation and genome assembly |
| RNA-seq | `RNAseq_Sha/ERR754081_1.fastq.gz` and `ERR754081_2.fastq.gz` | Paired-end Illumina | Transcriptome assembly |

## Workflow

### 1. Read quality assessment

Script:

```text
scripts/01-run_fastqc.sh
```

FastQC is run on the original PacBio and Illumina reads to assess read quality, GC content, sequence length distributions and potential adapter contamination.

### 2. Read filtering and trimming

Script:

```text
scripts/02-run_fastp.sh
```

The paired-end Illumina RNA-seq reads are trimmed and filtered with Fastp. Fastp is also run on the PacBio reads with filtering disabled to determine the total number of reads and bases.

#### Fastp results

| Measurement | Before filtering | After filtering |
|---|---:|---:|
| Illumina reads | 45,241,360 | 39,807,212 |
| Illumina bases | 4.569 Gb | 3.995 Gb |
| Q20 bases | 88.92% | 93.78% |
| Q30 bases | 78.55% | 83.56% |

A total of 5,434,148 reads, corresponding to approximately 12.01% of the input reads, were removed. Both Q20 and Q30 percentages increased after filtering, indicating improved read quality.

The PacBio dataset contains 323,355 reads and approximately 5.994 Gb of sequence data. No PacBio reads were filtered.

Using an expected *A. thaliana* genome size of approximately 135 Mb, the expected PacBio coverage is:

```text
5.994 Gb / 0.135 Gb ≈ 44.4×
```

### 3. K-mer counting and GenomeScope analysis

Script:

```text
scripts/03-run_jellyfish.sh
```

Jellyfish is used to count canonical 21-mers in the PacBio WGS reads. The k-mer counts are converted into a histogram and uploaded to GenomeScope 2.0.

Main outputs:

```text
jellyfish/ERR11437352_k21.jf
jellyfish/ERR11437352_k21.histo
```

GenomeScope is used to estimate:

- Genome size
- Heterozygosity
- Genome coverage
- Repetitive sequence content

### 4. Flye genome assembly

Script:

```text
scripts/04-run_flye.sh
```

Flye assembles the PacBio HiFi reads using an expected genome size of 135 Mb.

Main output:

```text
assemblies/flye/assembly.fasta
```

### 5. Hifiasm genome assembly

Script:

```text
scripts/05-run_hifiasm.sh
```

Hifiasm is used to assemble the PacBio HiFi reads. The primary contig graph is converted from GFA to FASTA format.

Main outputs:

```text
hifiasm/ERR11437352.bp.p_ctg.gfa
hifiasm/ERR11437352.fa
```

### 6. LJA genome assembly

Script:

```text
scripts/06-run_LJA.sh
```

The La Jolla Assembler assembles the PacBio HiFi reads using a multiplex de Bruijn graph approach.

Main outputs:

```text
LJA/assembly.fasta
LJA/mdbg.gfa
LJA/dbg.log
```

### 7. Trinity transcriptome assembly

Script:

```text
scripts/07-run_trinity.sh
```

Trinity performs de novo transcriptome assembly using the trimmed paired-end Illumina RNA-seq reads.

Input files:

```text
ERR754081_1_trimmed.fastq.gz
ERR754081_2_trimmed.fastq.gz
```

Main output:

```text
assemblies/trinity/Trinity.fasta
```

## Directory structure

```text
assembly_annotation_course/
├── assemblies/             # Genome and transcriptome assemblies
├── hifiasm/                # Hifiasm output files
├── Istisu-1/               # PacBio HiFi WGS reads
├── LJA/                    # LJA output files
├── logs/                   # Slurm standard-output and error logs
├── read_QC/                # FastQC, Fastp and Jellyfish results
├── RNAseq_Sha/             # Original paired-end RNA-seq reads
├── scripts/                # Slurm scripts for the workflow
│   ├── 01-run_fastqc.sh
│   ├── 02-run_fastp.sh
│   ├── 03-run_jellyfish.sh
│   ├── 04-run_flye.sh
│   ├── 05-run_hifiasm.sh
│   ├── 06-run_LJA.sh
│   └── 07-run_trinity.sh
└── README.md
```

## Running the workflow

Each step is submitted to the Slurm scheduler separately:

```bash
sbatch scripts/01-run_fastqc.sh
sbatch scripts/02-run_fastp.sh
sbatch scripts/03-run_jellyfish.sh
sbatch scripts/04-run_flye.sh
sbatch scripts/05-run_hifiasm.sh
sbatch scripts/06-run_LJA.sh
sbatch scripts/07-run_trinity.sh
```

Job status can be checked with:

```bash
squeue -u epasnin
```

Completed-job resource usage and exit status can be inspected with:

```bash
sacct -j JOB_ID \
    --format=JobID,JobName,State,ExitCode,Elapsed,MaxRSS,ReqMem
```

## Software

- FastQC 0.12.1
- Fastp 0.24.1
- Jellyfish 2.3.0
- Flye 2.9.5
- Hifiasm 0.25.0
- LJA 0.2
- Trinity 2.15.1
- Apptainer
- Slurm

## Assembly comparison

The Flye, Hifiasm and LJA genome assemblies will be compared using assembly statistics such as:

- Total assembly length
- Number of contigs
- Longest contig
- N50 and L50
- GC content
- Completeness
- Agreement with the expected *A. thaliana* genome size

GenomeScope and final assembly-evaluation results will be added after completing the analyses.