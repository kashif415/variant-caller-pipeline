"""
Variant Calling Pipeline - GATK4 Best Practices
Main Snakefile orchestrating the full workflow.
"""

import pandas as pd
from pathlib import Path
from snakemake.utils import min_version, validate

min_version("7.32")

# ─────────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────────
configfile: "config/config.yaml"

samples = pd.read_csv(config["samples"], sep="\t").set_index("sample_id", drop=False)
SAMPLES = samples.index.tolist()
REFERENCE = config["reference"]["fasta"]
KNOWN_SITES = config["reference"]["known_sites"]

# ─────────────────────────────────────────────────────────────────
# Modular rules
# ─────────────────────────────────────────────────────────────────
include: "workflow/rules/common.smk"
include: "workflow/rules/qc.smk"
include: "workflow/rules/alignment.smk"
include: "workflow/rules/variant_calling.smk"
include: "workflow/rules/annotation.smk"

# ─────────────────────────────────────────────────────────────────
# Target rule
# ─────────────────────────────────────────────────────────────────
rule all:
    input:
        "results/multiqc/multiqc_report.html",
        expand("results/annotated/{sample}.annotated.vcf.gz", sample=SAMPLES),
        "results/joint/cohort.vqsr.vcf.gz",


onsuccess:
    print("✅ Pipeline completed successfully!")


onerror:
    print("❌ Pipeline failed. See logs/ for details.")
