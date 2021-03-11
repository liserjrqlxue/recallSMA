#!/bin/bash
set -euo pipefail


sampleID=$1
bam=$2
vcf=$3
outVcf=$(echo $4|sed 's|\.gz$||g')
workdir=$(dirname $outVcf)

mkdir -p $workdir

bin=$(dirname $0)
export PATH=$bin:$PATH

SMA=$bin/../etc/SMA.5kb.bed
SMN1=$bin/../etc/SMN1.5kb.bed
ref=$bin/../ref/chr5.SMN2.1kb.mask.fa

mkdir -p $workdir
fq1=$workdir/$sampleID.SMA.1.fq.gz
fq2=$workdir/$sampleID.SMA.2.fq.gz

samtools view -b -L $SMA -o $workdir/$sampleID.SMA.u.bam $bam chr5:69340350-70253839

gatk SamToFastq -F $fq1 -F2 $fq2 -I $workdir/$sampleID.SMA.u.bam -VALIDATION_STRINGENCY SILENT

bwa mem -t 8 -M -R "@RG\tID:$sampleID\tSM:$sampleID\tLB:SMA\tPL:COMPLETE" $ref $fq1 $fq2|samtools view -S -b -o $workdir/$sampleID.SMA.raw.bam

gatk SortSam -I $workdir/$sampleID.SMA.raw.bam -O $workdir/$sampleID.SMA.sort.bam -SO "coordinate" -CREATE_INDEX true

gatk HaplotypeCaller -R $ref -O $workdir/$sampleID.SMA.g.vcf -I $workdir/$sampleID.SMA.sort.bam  -ERC GVCF -contamination 0.0   -G StandardAnnotation -G StandardHCAnnotation -G AS_StandardAnnotation   -GQB 10 -GQB 20 -GQB 30 -GQB 40 -GQB 50 -GQB 60 -GQB 70 -GQB 80 -GQB 90   --base-quality-score-threshold 6   -DF MappingQualityReadFilter   --max-reads-per-alignment-start 0   -mbq 10   -stand-call-conf 0.0   -OVM true   --showHidden -L $SMN1

gatk GenotypeGVCFs -R $ref -O $workdir/$sampleID.SMA.vcf.gz -V $workdir/$sampleID.SMA.g.vcf -G StandardAnnotation -stand-call-conf 0.0 --showHidden

gatk SelectVariants -XL $SMN1 -V $vcf -O $workdir/$sampleID.noSMA.vcf.gz

bcftools concat $workdir/$sampleID.noSMA.vcf.gz $workdir/$sampleID.SMA.vcf.gz -a -o $outVcf

bgzip -f $outVcf

tabix -f -p vcf  $outVcf.gz
