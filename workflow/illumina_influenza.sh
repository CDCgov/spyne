#!/bin/bash
while getopts 's:d:' OPTION
do
	case $OPTION in 
	s ) SAMPLESHEET=$OPTARG;;
    d ) DATAPATH=$OPTARG;;
	esac
done
bpath=
if [ "$bpath" == "" ]; then
	bpath=$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
fi

[[ ! -d IRMA/ ]] && mkdir IRMA
for sample in $(cut -f1 -d, $SAMPLESHEET ); do
    echo "Starting assembly of sample $sample"
    IRMA FLU fastqs/*/${sample}*R1*.fastq* fastqs/*/${sample}*R2*.fastq*  IRMA/$sample |tee -a ./log.out 2> ./log.err
    done



cat IRMA/*/*.fasta > dais_input.fasta

echo "Starting DAIS-Ribosome on IRMA output"

$bpath/scripts/daiswrapper.sh -i dais_input.fasta -m INFLUENZA 

