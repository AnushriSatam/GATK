#the NA12878.bam was aquired from GATK resource bundle. It was already marked for duplicates and recalibrated, so we can skip to variant calling, after removing the non-human contigs. the below code is just for practice.
#create dictionary for reference
/home/anushri/gatk-4.2.6.1/gatk CreateSequenceDictionary \
-R ../ref/b37/b37.fasta \
-O ../ref/b37/b37.dict

samtools faidx ../ref/b37/b37.fasta

#mark duplicates
/home/anushri/gatk-4.2.6.1/gatk MarkDuplicates \
-I ../bam/NA12878.bam \
-O ../bam/NA12878.marked.bam \
-M ../bam/NA12878.marked.metrics.txt

#to remove any viral contigs present (may not be required if the reference file used in bwa is same as the one used for base recalibration)
samtools view -b -h ../bam/NA12878.bam \
    1 2 3 4 5 6 7 8 9 10 \
    11 12 13 14 15 16 17 18 19 \
    20 21 22 X Y MT > ../bam/NA12878.marked.human.bam

samtools index ../bam/NA12878.marked.human.bam

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
-bqsr-recal-file recal_data.table \
-O ../bam/NA12878.recalibrated.bam

#variant calling
/home/anushri/gatk-4.2.6.1/gatk HaplotypeCaller \
-R ../ref/b37/b37.fasta \
-I ../bam/NA12878.recalibrated.bam \
-O ../variants/chr20_variants.vcf
