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

#extract the annotation into a table:
#the funcotation feilds header is required, tab delimited
cat ../variants/annotated.vcf |grep "Funcotation fields are :" |sed 's/|/\t/g' > funcotation_output.txt
#now you need the exact fields matching the header from your annotated file:
/home/anushri/gatk-4.2.6.1/ gatk VariantsToTable \
-V ../variants/annotated.vcf|-F AC -F AN -F DP -F AF -F FUNCOTATION \
-O ../variants/annotated.table

#extract only the funcotation fields and make them tab delimited, overwrite the funcotation_output file
../variants/annotation.table|cut -f 5|sed 's/|/\t/g' >> funcotation_output.txt


