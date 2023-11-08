#!/bin/bash 
# Wrapper to perform genome assembly 

usage() { echo -e "THIS IS AN EDIT! \n Usage in Spyne container: \n docker exec spyne bash $0 -s {path to samplesheet.csv starting with /data/} -r <run_id starting with /data> -e <experiment_type> <OPTIONAL: -p amplicon_library> <optional: -c CLEANUP-FOOTPRINT> \n
Usage in git cloned CLI: \n bash $0 -s {path to samplesheet.csv } -r <run_id > -e <experiment_type> <OPTIONAL: -p amplicon_library> <optional: -c CLEANUP-FOOTPRINT> <optional: -n > " 1>&2; exit 1;}

# Experiment type options: Flu-ONT, SC2-Spike-Only-ONT, Flu_Illumina, SC2-Whole-Genome-ONT, SC2-Whole-Genome-Illumina
# Primer Schema options: articv3, articv4, articv4.1, articv5.3.2, qiagen, swift, swift_211206


while getopts 's:r:e:p:c:na' OPTION
do
	case "$OPTION" in
	s ) SAMPLESHEET="$OPTARG";;
	r ) RUNPATH="$OPTARG";; 
	e ) EXPERIMENT_TYPE="$OPTARG";; 
	p ) PRIMER_SCHEMA="$OPTARG";; 
	c ) CLEANUP="${OPTARG}";;
	n ) NOCONTAINER=True;;
	a ) APPLICATION=True;;
	* ) usage;;
	esac
done

if [[ -z "${SAMPLESHEET}" ]] || [ -z "${RUNPATH}" ] || [ -z "${EXPERIMENT_TYPE}" ]; then
	usage
fi

if [[ -z "${PRIMER_SCHEMA}" ]]; then
	OPTIONALARGS=""; else 
	OPTIONALARGS="-p $PRIMER_SCHEMA"
fi

if [[ -z "${CLEANUP}" ]]; then
	OPTIONALARGS="${OPTIONALARGS}"; else
	OPTIONALARGS="${OPTIONALARGS} -c ${CLEANUP}"
fi

# Run whatever Bash commands here
# Set paths for non-container dev work
if [[ $NOCONTAINER ]]; then
	SCRIPT=$(realpath -s "$0")
	echo "${SCRIPT}"
	RESOURCE_ROOT=$(dirname "$SCRIPT")
	echo "${RESOURCE_ROOT}"
	BBTOOLS_ROOT=$(which bbmap)
	JAVA_ROOT=$(which java); else #set paths in container
	RESOURCE_ROOT=/spyne
	BBTOOLS_ROOT=/opt/bbtools
	JAVA_ROOT=/opt/java
fi

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
if [[ -z "${NOCONTAINER}" ]]; then
	java --version
fi
# Check the docker version
docker --version


#run_path=$(dirname $(readlink -f $RUNPATH/))

# Archive previous run
if [[ -f ${RUNPATH}/spyne_logs.tar.gz  && -n "${CLEANUP}" ]]; then
	tar  --remove-files -czf ${RUNPATH}/previous_run_$(date -d @$(stat -c %Y ${RUNPATH}/spyne_logs.tar.gz) "+%Y%b%d-%H%M%S").tar.gz ${RUNPATH}/spyne_logs.tar.gz ${RUNPATH}/*fasta ${RUNPATH}/dash-json ${RUNPATH}/irma_allconsensus_bam.tar.gz ${RUNPATH}/config.yaml ${RUNPATH}/.snakemake
fi

if [[ $APPLICATION ]]; then
	CLI=""; else
	CLI="-m"
fi

python3 "$RESOURCE_ROOT"/scripts/config_create.py $CLI -s "$SAMPLESHEET" -r "$RUNPATH" -e "$EXPERIMENT_TYPE" $OPTIONALARGS