"""Alignment rules: BWA-MEM2 → MarkDuplicates → BQSR."""


rule bwa_mem2_align:
    input:
        r1="results/trimmed/{sample}_R1.fastq.gz",
        r2="results/trimmed/{sample}_R2.fastq.gz",
        ref=REFERENCE,
    output:
        bam=temp("results/aligned/{sample}.sorted.bam"),
    log:
        "logs/bwa_mem2/{sample}.log",
    threads: 16
    params:
        rg=lambda w: f"@RG\\tID:{w.sample}\\tSM:{w.sample}\\tLB:{w.sample}\\tPL:ILLUMINA",
    conda:
        "../envs/alignment.yaml"
    shell:
        """
        bwa-mem2 mem -t {threads} -R '{params.rg}' -M \
            {input.ref} {input.r1} {input.r2} 2> {log} | \
        samtools sort -@ {threads} -o {output.bam} -
        samtools index {output.bam}
        """


rule mark_duplicates:
    input:
        bam="results/aligned/{sample}.sorted.bam",
    output:
        bam="results/dedup/{sample}.dedup.bam",
        metrics="results/dedup/{sample}.metrics.txt",
    log:
        "logs/markdup/{sample}.log",
    conda:
        "../envs/gatk.yaml"
    resources:
        mem_mb=16000,
    shell:
        """
        gatk MarkDuplicatesSpark \
            -I {input.bam} -O {output.bam} -M {output.metrics} \
            --spark-master local[{threads}] 2> {log}
        """


rule base_recalibrator:
    input:
        bam="results/dedup/{sample}.dedup.bam",
        ref=REFERENCE,
        known=KNOWN_SITES,
    output:
        table="results/bqsr/{sample}.recal.table",
    log:
        "logs/bqsr/{sample}.log",
    conda:
        "../envs/gatk.yaml"
    params:
        known=lambda w, input: " ".join(f"--known-sites {k}" for k in input.known),
    shell:
        """
        gatk BaseRecalibrator \
            -I {input.bam} -R {input.ref} \
            {params.known} -O {output.table} 2> {log}
        """


rule apply_bqsr:
    input:
        bam="results/dedup/{sample}.dedup.bam",
        ref=REFERENCE,
        table="results/bqsr/{sample}.recal.table",
    output:
        bam="results/recal/{sample}.recal.bam",
    log:
        "logs/apply_bqsr/{sample}.log",
    conda:
        "../envs/gatk.yaml"
    shell:
        """
        gatk ApplyBQSR -I {input.bam} -R {input.ref} \
            --bqsr-recal-file {input.table} -O {output.bam} 2> {log}
        """
