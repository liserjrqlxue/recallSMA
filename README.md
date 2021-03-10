# recallSMA
remap to SMN1 and call variant for homologous.

## SMA特殊变异检测流程使用说明
### 需求
#### 软件依赖
* gatk4
	* java 1.8
* bwa
* samtools
* bcftools
* bgzip
* tabix

注：bin/内有软件软链接，src/内有被链接的软件和源码，如环境不支持直接使用请重编译，或者使用环境内已有的相应软件替代

#### 计算资源需求
* 内存使用：1G
* 线程使用：2
* 运行时间：2分钟

### 输入参数信息
* 样品编号`sampleID`
* BAM文件`bam`
* VCF文件`vcf`
* 输出文件`outVcf=outDir/addSMA.vcf.gz`

注：输出文件如果没有.gz后缀会自动加.gz后缀

### 运行
```
sh $pipeline/bin/run.sh $sampleID $bam $vcf $outVcf
```
`pipeline`为流程根目录
 

### 输出
* 工作目录`outDir=$(dirname $outVcf)`
* 输出文件`outVcf=outDir/addSMA.vcf.gz`

注：工作目录内包含中间结果文件
 

