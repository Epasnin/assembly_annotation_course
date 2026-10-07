# De novo genome and transcriptome assembly of *Arabidopsis thaliana*

## Project overview

This project performs read quality control, genome-size estimation, de novo genome assembly, de novo transcriptome assembly, assembly evaluation and genome comparison using sequencing data from *Arabidopsis thaliana*.

PacBio HiFi whole-genome sequencing reads are used for genome analysis and assembly. Paired-end Illumina RNA-seq reads are quality-filtered and used for transcriptome assembly. Three genome assemblers—Flye, Hifiasm and LJA—are evaluated using BUSCO, QUAST, Merqury and MUMmer.

## Input data

| Dataset | File(s) | Sequencing type | Purpose |
|---|---|---|---|
| PacBio WGS | `Istisu-1/ERR11437352.fastq.gz` | PacBio HiFi | Genome-size estimation and genome assembly |
| RNA-seq | `RNAseq_Sha/ERR754081_1.fastq.gz` and `RNAseq_Sha/ERR754081_2.fastq.gz` | Paired-end Illumina | Transcriptome assembly |

## Workflow

### 1. Read quality assessment

Script: `scripts/01-run_fastqc.sh`

FastQC is run on the original PacBio and Illumina reads to assess read quality, GC content, sequence-length distributions and potential adapter contamination.

### 2. Read filtering and trimming

Script: `scripts/02-run_fastp.sh`

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

Script: `scripts/03-run_jellyfish.sh`

Jellyfish is used to count canonical 21-mers in the PacBio WGS reads. The k-mer counts are converted into a histogram for analysis with GenomeScope 2.0.

Main outputs:

```text
jellyfish/ERR11437352_k21.jf
jellyfish/ERR11437352_k21.histo
```

GenomeScope estimates genome size, heterozygosity, genome coverage and repetitive-sequence content.

### 4. Flye genome assembly

Script: `scripts/04-run_flye.sh`

Flye assembles the PacBio HiFi reads using an expected genome size of 135 Mb.

Main output:

```text
assemblies/flye/assembly.fasta
```

### 5. Hifiasm genome assembly

Script: `scripts/05-run_hifiasm.sh`

Hifiasm is used to assemble the PacBio HiFi reads. The primary contig graph is converted from GFA to FASTA format.

Main outputs:

```text
assemblies/hifiasm/ERR11437352.bp.p_ctg.gfa
assemblies/hifiasm/ERR11437352.fa
```

### 6. LJA genome assembly

Script: `scripts/06-run_LJA.sh`

The La Jolla Assembler assembles the PacBio HiFi reads using a multiplex de Bruijn graph approach.

Main outputs:

```text
assemblies/LJA/assembly.fasta
assemblies/LJA/mdbg.gfa
assemblies/LJA/dbg.log
```

### 7. Trinity transcriptome assembly

Script: `scripts/07-run_trinity.sh`

Trinity performs de novo transcriptome assembly using the trimmed paired-end Illumina RNA-seq reads.

Input files:

```text
fastp/ERR754081_1_trimmed.fastq.gz
fastp/ERR754081_2_trimmed.fastq.gz
```

Main output:

```text
assemblies/trinity.Trinity.fasta
```

### 8. Genome assembly completeness with BUSCO

Script: `scripts/08-run_genome_busco.sh`

BUSCO evaluates the Flye, Hifiasm and LJA assemblies in genome mode using the `brassicales_odb10` lineage dataset.

| Assembly | Complete | Single-copy | Duplicated | Fragmented | Missing | Contigs | N50 |
|---|---:|---:|---:|---:|---:|---:|---:|
| Flye | 99.8% | 98.8% | 1.0% | 0.3% | 0.1% | 91 | 6 Mb |
| Hifiasm | 98.8% | 97.9% | 0.9% | 0.3% | 0.9% | 268 | 15 Mb |
| LJA | 99.8% | 98.8% | 1.0% | 0.3% | 0.1% | 834 | 13 Mb |

Flye and LJA recovered almost all expected Brassicales genes, with only one missing BUSCO each. Hifiasm had the highest N50 but slightly lower gene completeness. BUSCO alone cannot determine the best overall assembly, so these results are considered together with QUAST and Merqury.

### 9. Transcriptome completeness with BUSCO

Script: `scripts/09-run_transcriptome_busco.sh`

BUSCO evaluates the Trinity assembly in transcriptome mode using `brassicales_odb10`.

| Complete | Single-copy | Duplicated | Fragmented | Missing |
|---:|---:|---:|---:|---:|
| 78.7% | 39.1% | 39.6% | 3.8% | 17.5% |

The high duplicated fraction is expected in a de novo transcriptome because Trinity may reconstruct multiple transcript isoforms for the same gene. Missing BUSCOs may represent genes that were not expressed in the sampled tissue or conditions.

### 10. Reference-based assembly evaluation with QUAST

Script: `scripts/10-run_reference_quast.sh`

QUAST compares the three genome assemblies with the TAIR10 reference genome and annotation. The reports contain assembly length, contig number, N50, genome fraction, duplication ratio, misassemblies and sequence-error statistics.

Main output directory:

```text
assembly_evaluation/QUAST/
```

### 11. Reference-free evaluation with Merqury

Script: `scripts/11-run_mercury.sh`

Merqury compares k-mers from each genome assembly with k-mers from the original PacBio HiFi reads. It estimates consensus quality value, error rate and k-mer completeness and generates copy-number spectra plots.

Main output directory:

```text
assembly_evaluation/MERQURY/
```

### 12. Genome comparison with MUMmer

Script: `scripts/12-run_nummer.sh`

Nucmer aligns the Flye, Hifiasm and LJA assemblies against the TAIR10 reference and against each other. Mummerplot converts the alignments into dotplots that can reveal collinearity, inversions, rearrangements, duplicated regions and possible assembly differences.

Main output directory:

```text
assembly_evaluation/MUMMER/
```

## Directory structure

```text
assembly_annotation_course/
├── assemblies/                  # Genome and transcriptome assemblies
│   ├── flye/
│   ├── hifiasm/
│   └── LJA/
├── assembly_evaluation/         # BUSCO, QUAST, Merqury and MUMmer results
│   ├── BUSCO/
│   ├── QUAST/
│   ├── MERQURY/
│   └── MUMMER/
├── fastp/                       # Trimmed RNA-seq reads and Fastp reports
├── Istisu-1/                    # PacBio HiFi WGS reads
├── jellyfish/                   # K-mer database and histogram
├── logs/                        # Slurm standard-output and error logs
├── read_QC/                     # FastQC results
├── RNAseq_Sha/                  # Original paired-end RNA-seq reads
├── scripts/                     # Slurm scripts for the workflow
│   ├── 01-run_fastqc.sh
│   ├── 02-run_fastp.sh
│   ├── 03-run_jellyfish.sh
│   ├── 04-run_flye.sh
│   ├── 05-run_hifiasm.sh
│   ├── 06-run_LJA.sh
│   ├── 07-run_trinity.sh
│   ├── 08-run_genome_busco.sh
│   ├── 09-run_transcriptome_busco.sh
│   ├── 10-run_reference_quast.sh
│   ├── 11-run_mercury.sh
│   └── 12-run_nummer.sh
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
sbatch scripts/08-run_genome_busco.sh
sbatch scripts/09-run_transcriptome_busco.sh
sbatch scripts/10-run_reference_quast.sh
sbatch scripts/11-run_mercury.sh
sbatch scripts/12-run_nummer.sh
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
- BUSCO 5.7.1
- QUAST 5.2.0
- Merqury 1.3
- MUMmer4
- GenomeScope 2.0
- Apptainer
- Slurm

## Assembly comparison

The three genome assemblies are evaluated using complementary criteria:

- **Contiguity:** number of contigs, longest contig, N50 and L50
- **Gene completeness:** complete, duplicated, fragmented and missing BUSCOs
- **Reference agreement:** genome fraction, misassemblies and sequence differences reported by QUAST
- **Read-supported accuracy:** Merqury QV, error rate and k-mer completeness
- **Structural agreement:** MUMmer alignments and dotplots against TAIR10 and between assemblies

No single metric determines the best assembly. For example, Hifiasm has the highest BUSCO-reported N50, while Flye has fewer contigs and Flye and LJA have slightly higher BUSCO completeness. The final assessment therefore considers contiguity, completeness, accuracy and structural agreement together.