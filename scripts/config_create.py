import yaml
from os.path import abspath
from sys import argv, exit
import pandas as pd
from glob import glob
import subprocess
import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-s","--samplesheet", help="Samplesheet with sample names")
parser.add_argument("-r", "--runid", help="Full path to data directory containing either a fastq_pass subdirectory for ONT data or fastq subdirectory for Illumina")
parser.add_argument("-e", "--experiment_type", help="Experiment type options: Flu-ONT, SC2-Spike-Only-ONT, Flu_Illumina, SC2-Whole-Genome-ONT, SC2-Whole-Genome-Illumina" )
parser.add_argument("-p", "--primer_schema", required=False, help="For whole-genome SARS-CoV-2 Illumina data, which primer schema was used?")
parser.add_argument("-c", "--cleanup", required=False, help="option for data cleanup, CLEANUP-FOOTPRINT, other options for development and testing")
parser.add_argument("-m", "--mira", action='store_true', required=False, help="Command-line MIRA called from MIRA.sh bash script")

inputarguments = parser.parse_args()

root = "/".join(abspath(__file__).split("/")[:-2])
if len(argv) < 2:
    exit(
        "\n\tUSAGE: {} -s <samplesheet.csv> -r <runpath> -e <experiment_type> <optional: -p primer_schema> <optional: -c clean_option> \n".format(__file__)
    )
print(f"argv[1:]= {argv[1:]}")
try:
    samplesheet = inputarguments.samplesheet
    runpath = inputarguments.runid
    if runpath[-1] == '/':
        runpath = runpath[:-1]
    experiment_type = inputarguments.experiment_type
    if inputarguments.primer_schema:
        amplicon = True
        primer_schema = inputarguments.primer_schema
    else:
        amplicon = False
    if inputarguments.cleanup:
        clean_option = inputarguments.cleanup
    else:
        clean_option = ''
    if inputarguments.mira:
        cli = True
    else:
        cli = False
except:
    parser.print_help()
    exit(0) 
   
df = pd.read_csv(samplesheet)
dfd = df.to_dict("index")

if 'ont' in experiment_type.lower():
    if 'fastq_pass' in runpath:
        if not cli:
            data = {'runid':runpath.split('/')[runpath.split('/').index('fastq_pass') -1], 'barcodes':{}}
        else:
            data = {'runid':runpath.split('/')[runpath.split('/').index('fastq_pass') -1], 'cli': True, 'barcodes':{}}
    else:
        if not cli:
            data = {'runid':runpath.split('/')[-1], 'barcodes':{}}
        else:
            data = {'runid':runpath.split('/')[-1], 'cli': True, 'barcodes':{}}
    def reverse_complement(seq):
        rev = {"A": "T", "T": "A", "C": "G", "G": "C", ",": ","}
        seq = seq[::-1]
        return "".join(rev[i] for i in seq)

    failures = ""
    try:
        with open(
            "{}/lib/EXP-NBD196.yaml".format(root), "r"
        ) as y:
            barseqs = yaml.safe_load(y)
    except:
        with open(
            "{}/lib/EXP-NBD196.yaml".format(root), "r"
        ) as y:
            barseqs = yaml.safe_load(y)
    for d in dfd.values():
        if 'fastq_pass' in runpath:
            fastq_pass = glob(runpath + '/*/')
        else:
            fastq_pass = glob(runpath + '/fastq_pass/*/')
        if d['Barcode #'] in [x.split("/")[-2] for x in fastq_pass]:

            data["barcodes"][d["Sample ID"]] = {
                "sample_type": d["Sample Type"],
                "barcode_number": d["Barcode #"],
                "barcode_sequence": barseqs[d["Barcode #"]],
                "barcode_sequence_rc": reverse_complement(barseqs[d["Barcode #"]]),
            }
        else:
            failures += str(d["Barcode #"]) + "\n"

    if len(failures) > 1:
        print("failed samples detected: Barcodes\n", failures.strip())
else:
    if not cli:
        data = {'runid':runpath.split('/')[-1], 'samples':{}}
    else:
        data = {'runid':runpath.split('/')[-1], 'cli': True, 'samples':{}}
    for d in dfd.values():
        id = d['Sample ID']
        print(f"runpath = {runpath}\nid = {id}")
        R1_fastq = glob(f"{runpath}/**/{id}*R1*fastq*", recursive=True)[0]
        R2_fastq = glob(f"{runpath}/**/{id}*R2*fastq*", recursive=True)[0]
        if len(R1_fastq) < 1 or len(R2_fastq) < 1:
            print(f"Fastq pair not found for sample {id}")
            exit()
        if amplicon:
            data["samples"][d["Sample ID"]] = {
                "sample_type": d["Sample Type"],
                "R1_fastq": R1_fastq.replace(f'{runpath}/',''), 
                "R2_fastq": R2_fastq.replace(f'{runpath}/',''), 
                "Library" : primer_schema
            }
        else:
            data["samples"][d["Sample ID"]] = {
                "sample_type": d["Sample Type"],
                "R1_fastq": R1_fastq.replace(f'{runpath}/',''), 
                "R2_fastq": R2_fastq.replace(f'{runpath}/',''), 
            }
with open(runpath.replace("fastq_pass", "") + "/config.yaml", "w") as out:
    yaml.dump(data, out, default_flow_style=False)

snakefile_path = f"{root}/workflow/"
if "ont" in experiment_type.lower():

    if "flu" in experiment_type.lower():
        snakefile_path += "influenza_snakefile"
    elif "spike" in experiment_type.lower():
        snakefile_path += "sc2_spike_snakefile"
    elif "sc2" in experiment_type.lower():
        snakefile_path += "sc2_wgs_snakefile"
    elif "rsv" in experiment_type.lower():
        snakefile_path += "rsv_snakefile"
else:
    if "flu" in experiment_type.lower():
        snakefile_path += "illumina_influenza_snakefile"
    elif "sc2" in experiment_type.lower():
        snakefile_path += "illumina_sc2_snakefile"
    elif "rsv" in experiment_type.lower():
        snakefile_path += "illumina_rsv_snakefile"

if "TESTDEV-QUICK" in clean_option:
    snake_cmd = (
        f"snakemake -s {snakefile_path} \
        --configfile config.yaml \
        --cores 4 	\
        --printshellcmds \
        --rerun-incomplete"
    )
elif "TESTDEV-PRINTDAG" in clean_option:
    snake_cmd = (
        f"snakemake -s {snakefile_path} \
        --configfile config.yaml \
        --cores 4 	\
        --printshellcmds \
        --dag |awk '/digraph/,/\u007d/' |dot -Tpdf > filegraph.pdf"
    ) 
elif "TESTDEV-DEBUGDAG" in clean_option:
    snake_cmd = (
        f"snakemake -s {snakefile_path} \
        --configfile config.yaml \
        --cores 4 	\
        --printshellcmds \
        --debug-dag"
    ) 
else:
    snake_cmd = (
            f"snakemake -s {snakefile_path} \
            --configfile config.yaml \
            --cores 4 	\
            --printshellcmds \
    	    --restart-times 10 \
    	    --rerun-incomplete \
    	    --latency-wait 600 "
        )
os.chdir(runpath.replace("fastq_pass", ""))
print(f"\n\nSNAKEMAKE CMD:\n {snake_cmd}\n\n")
subprocess.run(snake_cmd, shell=True)

# Remove extraneous intermediate files and tar archive logs, F1 bam and plurality consensus
if "CLEANUP-FOOTPRINT" in clean_option:
    fullsize = int(subprocess.run(f"du -d0", stdout=subprocess.PIPE, shell=True).stdout.decode().split('\t')[0])
    subprocess.run(f"{root}/workflow/scripts/spyne_cleanup.sh", shell=True)
    cleansize = int(subprocess.run(f"du -0", stdout=subprocess.PIPE, shell=True).stdout.decode().split('\t')[0])
    removed = fullsize - cleansize
    print(f"{removed/1000:.2f}MB removed\n{cleansize/1000:.2f}MB remain")
