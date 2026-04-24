"""Variant calling: HaplotypeCaller → joint genotyping → VQSR."""


rule haplotype_caller:
    input:
        bam="results/recal/{sample}.recal.bam",
        ref=REFERENCE,
        intervals=config["reference"]["intervals"],
    output:
        gvcf="results/gvcf/{sample}.g.vcf.gz",
    log:
        "logs/haplotypecaller/{sample}.log",
    conda:
        "../envs/gatk.yaml"
    threads: 4
    resources:
        mem_mb=16000,
    shell:
        """
        gatk --java-options "-Xmx{resources.mem_mb}m" HaplotypeCaller \
            -I {input.bam} -R {input.ref} -L {input.intervals} \
            -O {output.gvcf} --emit-ref-confidence GVCF \
            --native-pair-hmm-threads {threads} 2> {log}
        """


rule genomics_db_import:
    input:
        gvcfs=expand("results/gvcf/{sample}.g.vcf.gz", sample=SAMPLES),
        intervals=config["reference"]["intervals"],
    output:
        db=directory("results/genomicsdb"),
    log:
        "logs/genomicsdb/import.log",
    conda:
        "../envs/gatk.yaml"
    params:
        gvcf_args=lambda w, input: " ".join(f"-V {g}" for g in input.gvcfs),
    resources:
        mem_mb=32000,
    shell:
        """
        gatk --java-options "-Xmx{resources.mem_mb}m" GenomicsDBImport \
            {params.gvcf_args} --genomicsdb-workspace-path {output.db} \
            -L {input.intervals} --reader-threads 4 2> {log}
        """


rule genotype_gvcfs:
    input:
        db="results/genomicsdb",
        ref=REFERENCE,
    output:
        vcf="results/joint/cohort.vcf.gz",
    log:
        "logs/genotype_gvcfs/cohort.log",
    conda:
        "../envs/gatk.yaml"
    resources:
        mem_mb=32000,
    shell:
        """
        gatk --java-options "-Xmx{resources.mem_mb}m" GenotypeGVCFs \
            -R {input.ref} -V gendb://{input.db} -O {output.vcf} 2> {log}
        """


rule apply_vqsr:
    input:
        vcf="results/joint/cohort.vcf.gz",
        ref=REFERENCE,
    output:
        vcf="results/joint/cohort.vqsr.vcf.gz",
    log:
        "logs/apply_vqsr/cohort.log",
    conda:
        "../envs/gatk.yaml"
    shell:
        """
        gatk VariantRecalibrator -R {input.ref} -V {input.vcf} \
            -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
            -mode SNP -O results/vqsr/snps.recal \
            --tranches-file results/vqsr/snps.tranches 2> {log}
        gatk ApplyVQSR -R {input.ref} -V {input.vcf} \
            --recal-file results/vqsr/snps.recal \
            --tranches-file results/vqsr/snps.tranches \
            --truth-sensitivity-filter-level 99.5 \
            -mode SNP -O {output.vcf} 2>> {log}
        """
