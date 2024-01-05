import argparse
import csv
import gzip

parser = argparse.ArgumentParser(description='Find chemistry information from fastq files.')
parser.add_argument('-s', '--sample', required=True, help='Sample name')
parser.add_argument('-q', '--fastq', required=True, help='R1.fastq file path')
parser.add_argument('-r', '--runid', required=True, help='Run ID')

args = parser.parse_args()

sample = args.sample
fastq = args.fastq
runid = args.runid

csv_filename = f"{sample}_chemistry.csv"
headers = ["sample_ID", "irma_custom_0", "irma_custom_1", "subsample"]
with open(csv_filename, mode='w', newline='') as csv_file:
    csv_writer = csv.writer(csv_file)
    csv_writer.writerow(headers)

try:
    with open(fastq) as infi:
        contents = infi.readlines()
except:
    with gzip.open(fastq) as infi:
            contents = infi.readlines()

if len(contents[1]) > 145:
    irma_custom = ["",""]
    subsample = "100000"
elif len(contents[1]) > 70:
    config_path = "/home/try8/spyne_nextflow/workflow/irma_contif/FLU-2x75.sh"
    irma_custom = [f"mkdir -p /home/try8/results/IRMA && cp {config_path} /home/try8/results/IRMA/ &&", f"--external-config /data/{runid}/IRMA/FLU-2x75.sh"]
    subsample = "200000"

with open(f'{sample}_chemistry.csv', 'a', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow([sample, irma_custom[0], irma_custom[1], subsample])