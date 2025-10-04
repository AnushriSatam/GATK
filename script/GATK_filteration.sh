#Split the VCF into SNPs and indels:
/home/anushri/gatk-4.2.6.1/gatk SelectVariants \
-R ../ref/b37/b37.fasta \
-V ../variants/chr20_variants.vcf \
--select-type-to-include SNP \
-O ../variants/chr20_snp.vcf

/home/anushri/gatk-4.2.6.1/gatk SelectVariants \
-R ../ref/b37/b37.fasta \
-V ../variants/chr20_variants.vcf \
--select-type-to-include INDEL \
-O ../variants/chr20_indel.vcf

#filter snp and indels based on GATK best practices
/home/anushri/gatk-4.2.6.1/gatk VariantFiltration \
-R ../ref/b37/b37.fasta \
-V ../variants/chr20_snp.vcf \
--filter-name "QD_filter" --filter-expression "QD < 2.0" \
--filter-name "FS_filter" --filter-expression "FS > 60.0" \
--filter-name "MQ_filter" --filter-expression "MP < 40.0" \
-O ../variants/chr20_snp_filtered.vcf

/home/anushri/gatk-4.2.6.1/gatk VariantFiltration \
-R ../ref/b37/b37.fasta \
-V ../variants/chr20_indel.vcf \
--filter-name "QD_filter" --filter-expression "QD < 2.0" \
--filter-name "FS_filter" --filter-expression "FS > 200.0" \
-O ../variants/chr20_indel_filtered.vcf

#merge them into one file
/home/anushri/gatk-4.2.6.1/gatk MergeVcfs \
-I ../variants/chr20_snp_filtered.vcf \
-I ../variants/chr20_indel_filtered.vcf \
-O ../variants/chr20_variants_filtered_merged.vcf

#exclude the ones that failed the filter
/home/anushri/gatk-4.2.6.1/gatk SelectVariants \
-R ../ref/b37/b37.fasta \
-V ../variants/chr20_variants_filtered_merged.vcf \
--exclude-filtered \
-O ../variants/chr20_variants_filter_pass.vcf

#annotation using GATK funcotator
/home/anushri/gatk-4.2.6.1/gatk Funcotator \
--variant ../variants/chr20_variants_filter_pass.vcf \
--reference ../ref/b37/b37.fasta \
--ref-version hg19 \
--data-sources-path /home/anushri/funcotator_dataSources.v1.7.20200521g \
--output ../variants/annotated.vcf \
--output-file-format VCF



