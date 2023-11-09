#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Initiate parameters
params.s = "${launchDir}/samplesheet.csv"
params.r = null
params.e = null
params.outdir = 'results'

// Import modules
include { nextflow_samplesheet_creat } from "${launchDir}/spyne_nextflow/modules/nextflow_samplesheet_creat.nf"

// Orchestrate the process flow
workflow {
    samplesheet_ch = Channel.fromPath( params.s, checkIfExists: true)
    run_ID_ch = Channel.fromPath( params.r, checkIfExists: true )
    experiment_type_ch = Channel.value ( params.e )

    // Convert the samplesheet to a nextflow format
    nextflow_samplesheet_creat(samplesheet_ch,run_ID_ch,experiment_type_ch)

    // Generate input_channel
    input_ch = nextflow_samplesheet_creat.out
        .splitCsv(header: true, sep: ',')
        .flatten()

    //input_ch.view()

    // Find chemistry
    find_chemistry(input_ch.map{ it.fastq_1 })
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
