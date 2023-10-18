#!/bin/bash 
# Wrapper to perform genome assembly 

# Usage:
# ./MIRA.sh {path to samplesheet.csv} <run_id> <experiment_type> <OPTIONAL: amplicon_library> <optional: CLEANUP-FOOTPRINT>

# Experiment type options: Flu-ONT, SC2-Spike-Only-ONT, Flu_Illumina, SC2-Whole-Genome-ONT, SC2-Whole-Genome-Illumina

# Run whatever Bash commands here
SCRIPT=$(realpath -s "$0")
RESOURCE_ROOT=$(dirname "$SCRIPT")
BBTOOLS_ROOT=$(which bbmap)
JAVA_ROOT=$(which java)

# Export bbtools to system path
bbtools_path=$(ls ${BBTOOLS_ROOT})

for eachdir in ${bbtools_path}
do
	export PATH=$PATH:${BBTOOLS_ROOT}/${eachdir}
done

# Export java to system path
java_path=$(ls ${JAVA_ROOT})

for eachdir in ${java_path}
do
	export PATH=$PATH:${JAVA_ROOT}/${eachdir}/bin
done

# Check the java version
#java --version

# Check the docker version
docker --version


run_path=$(dirname $(readlink -f $1))

# Archive previous run
if [ -f ${run_path}/spyne_logs.tar.gz ]; then
	tar  --remove-files -czf ${run_path}/previous_run_$(date -d @$(stat -c %Y ${run_path}/spyne_logs.tar.gz) "+%Y%b%d-%H%M%S").tar.gz ${run_path}/spyne_logs.tar.gz ${run_path}/*fasta ${run_path}/dash-json ${run_path}/irma_allconsensus_bam.tar.gz ${run_path}/config.yaml ${run_path}/.snakemake
fi

# Create config.yaml from samplesheet
#until [ -f ${run_path}/spyne_logs.tar.gz ]; do
#	python3 $RESOURCE_ROOT/scripts/cli_config_create.py "$@"
#done

python3 $RESOURCE_ROOT/scripts/cli_config_create.py "$@"