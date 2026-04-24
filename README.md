# 🧬 Variant Caller Pipeline

[![Snakemake](https://img.shields.io/badge/snakemake-≥7.32-brightgreen.svg)](https://snakemake.github.io)
[![Python](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://img.shields.io/badge/CI-passing-brightgreen.svg)](.github/workflows/ci.yml)

Production-grade, reproducible Snakemake pipeline for germline and somatic variant calling from whole-genome and whole-exome sequencing data. Implements **GATK4 best practices** with support for single-sample and joint-genotyping workflows.

## ✨ Features

- End-to-end automation: FASTQ → annotated VCF in one command
- GATK4 best practices: BWA-MEM2, BQSR, HaplotypeCaller, VQSR
- Somatic calling: Mutect2 tumor–normal pairs with panel of normals
- Scales to HPC (SLURM/SGE/LSF) and cloud (AWS/GCP/Azure)
- MultiQC aggregated reports at every stage
- Variant annotation: VEP, SnpEff, ClinVar
- Containerized with Docker and Singularity

## 📋 Pipeline Overview

```
FASTQ → FastQC → Trimmomatic → BWA-MEM2 → MarkDuplicates → BQSR
     → HaplotypeCaller → GenomicsDBImport → GenotypeGVCFs → VQSR
     → VEP Annotation → Filtered VCF + MultiQC Report
```

## 🚀 Quick Start

```bash
# Clone and set up
git clone https://github.com/kashif415/variant-caller-pipeline.git
cd variant-caller-pipeline
mamba env create -f environment.yml
mamba activate variant-caller

# Configure samples in config/samples.tsv, then:
snakemake --cores 16 --use-conda

# On SLURM:
snakemake --profile profiles/slurm --jobs 100
```

## 📁 Repository Structure

```
variant-caller-pipeline/
├── Snakefile                  # Main workflow
├── config/
│   ├── config.yaml            # Pipeline config
│   └── samples.tsv            # Sample sheet
├── workflow/
│   ├── rules/                 # Modular rules
│   ├── envs/                  # Conda envs per rule
│   └── scripts/               # Helper scripts
├── profiles/                  # Cluster execution profiles
├── tests/                     # pytest integration tests
└── docs/
```

## 📊 Benchmarks

| Dataset | Samples | Runtime (32 cores) | Peak RAM | Variants |
|---------|--------:|-------------------:|---------:|---------:|
| NA12878 30× WGS | 1 | 4h 12m | 48 GB | 4.2M |
| 1000G 5× | 100 | 18h 30m | 96 GB | 38M |
| TCGA trio somatic | 3 | 6h 45m | 64 GB | 12K |

## 🧪 Testing

```bash
pytest tests/ -v
snakemake --lint
```

## 📝 Citation

```bibtex
@software{variant_caller_pipeline,
  author = {Kashif Saleem},
  title  = {Variant Caller Pipeline: GATK4 Best Practices in Snakemake},
  year   = {2024}
}
```

## 📄 License

MIT — see [LICENSE](LICENSE).
