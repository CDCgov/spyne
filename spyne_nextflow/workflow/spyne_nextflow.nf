#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Initiate parameters
params.s = "${launchDir}/samplesheet.csv"
params.r = null
params.e = null
params.outdir = 'results'

// Import modules
include { create_nextflow_samplesheet } from "${launchDir}/spyne_nextflow/modules/create_nextflow_samplesheet.nf"
include { find_chemistry } from "${launchDir}/spyne_nextflow/modules/find_chemistry.nf"
include { subsample } from "${launchDir}/spyne_nextflow/modules/subsample.nf"
include { irma } from "${launchDir}/spyne_nextflow/modules/irma.nf"

// Orchestrate the process flow
workflow {
    samplesheet_ch = Channel.fromPath( params.s, checkIfExists: true)
    run_ID_ch = Channel.fromPath( params.r, checkIfExists: true )
    experiment_type_ch = Channel.value ( params.e )

    // Convert the samplesheet to a nextflow format
    create_nextflow_samplesheet( samplesheet_ch,run_ID_ch,experiment_type_ch )

    // Generate input_channel
    input_ch = create_nextflow_samplesheet.out
        .splitCsv( header: true )

    // Find chemistry
    new_ch = input_ch.map { item ->
        [item.sample_ID, item.fastq_1]
    }
    find_chemistry_ch = new_ch.combine(run_ID_ch)
    find_chemistry( find_chemistry_ch )

    // Create the irma chemistry channel
    irma_chemistry_ch = find_chemistry.out
        .splitCsv( header: true, sep: ',' )

    // Subsample
    new_ch2 = input_ch.map { item ->
        [sample_ID:item.sample_ID, fastq_1:item.fastq_1, fastq_2:item.fastq_2]
    }
    new_ch3 = irma_chemistry_ch.map {item ->
                [sample_ID: item.sample_ID, subsample:item.subsample]
    } 
    subsample_ch = new_ch2.combine(new_ch3)
                .filter { it[0].sample_ID == it[1].sample_ID }
                .map { [it[0].sample_ID, it[0].fastq_1, it[0].fastq_2, it[1].subsample] }
    subsample( subsample_ch )

    // Run irma
    new_ch4 = irma_chemistry_ch.map {item ->
                [sample_ID: item.sample_ID, irma_custom_0:item.irma_custom_0, irma_custom_1:item.irma_custom_1]
    } 
    subsample.out.subsampled_fastq.view()
    irma_ch = subsample.out.subsampled_fastq.combine(new_ch4)
                .filter { it[0].sample_ID == it[1].sample_ID }
                .map { [it[0].sample_ID, it[0].fastq_1, it[0].fastq_2, it[1].subsample] }
    
}

// Workflow Event Handler

workflow.onComplete {

   println ( workflow.success ? """
       Pipeline execution summary
       ---------------------------
       Completed at: ${workflow.complete}
       Duration    : ${workflow.duration}
       Success     : ${workflow.success}
       workDir     : ${workflow.workDir}
       exit status : ${workflow.exitStatus}
       """ : """
       Failed: ${workflow.errorReport}
       exit status : ${workflow.exitStatus}
       """
   )
}
