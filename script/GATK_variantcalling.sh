
create dictionary for reference
/home/anushri/gatk-4.2.6.1/gatk CreateSequenceDictionary \
-R ../ref/b37/b37.fasta \
-O ../ref/b37/b37.dict

samtools faidx ../ref/b37/b37.fasta

#mark duplicates
/home/anushri/gatk-4.2.6.1/gatk MarkDuplicates \
-I ../bam/NA12878.unmarked.bam \
-O ../bam/NA12878.marked.bam \
-M ../bam/NA12878.marked.metrics.txt

#to remove any viral contigs present (may not be required if the reference file used in bwa is same as the one used for base recalibration)
samtools view -b -h ../bam/NA12878.marked.bam \
    chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 \
    chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 \
    chr20 chr21 chr22 chrX chrY chrM > ../bam/NA12878.marked.human.bam

samtools index NA12878.marked.human.bam

#need to index the known snp and indels files as well
/home/anushri/gatk-4.2.6.1/gatk IndexFeatureFile -I ../known/dbsnp_138.b37.vcf/dbsnp_138.b37.vcf
/home/anushri/gatk-4.2.6.1/gatk IndexFeatureFile -I ../known/Mills_and_1000G_gold_standard.indels.b37.vcf/Mills_and_1000G_gold_standard.indels.b37.vcf

dbsnp=../known/dbsnp_138.b37.vcf/dbsnp_138.b37.vcf
mills=../known/Mills_and_1000G_gold_standard.indels.b37.vcf/Mills_and_1000G_gold_standard.indels.b37.vcf

#base recalibration

/home/anushri/gatk-4.2.6.1/gatk BaseRecalibrator \
-I ../bam/NA12878.marked.human.bam \
-R ../ref/b37/b37.fasta \
--known-sites $dbsnp \
--known-sites $mills \
-O ../recal_data.table

#apply recalibration:

/home/anushri/gatk-4.2.6.1/gatk ApplyBQSR \
-R ../ref/b37/b37.fasta \
-I ../bam/NA12878.marked.human.bam \
--bqsr-recal-file recal_data.table \
-O ../bam/NA12878.recalibrated.bam

#variant calling
/home/anushri/gatk-4.2.6.1/gatk HaplotypeCaller \
-R ../ref/b37/b37.fasta \
-I ../bam/NA12878.recalibrated.bam \
-O ../variants/chr20_variants.vcf
