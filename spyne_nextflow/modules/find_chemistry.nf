#!/usr/bin/env nextflow

/*
========================================================================================
   find_chemistry module
========================================================================================
*/

nextflow.enable.dsl=2

process find_chemistry {
    tag {"finding chemistry parameters"}

    publishDir "${params.outdir}", mode: 'copy'

    input:
    path fastq
    path runid

    output:
    path "chemistry.csv", emit: chemistry

    script:
    """
    python <<CODE
    import gzip
    import csv

    fastq = '$fastq'
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
        config_path = "/home/try8/spyne_nextflow/bin/FLU-2x75.sh"
        irma_custom = [f"cp {config_path} IRMA/ &&",f"--external-config /data/$runid/IRMA/FLU-2x75.sh"]
        subsample = "200000"

    with open('chemistry.csv', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['irma_custom_0', 'irma_custom_1', 'subsample'])
        writer.writerow([irma_custom[0], irma_custom[1], subsample])
    CODE
    """
}
