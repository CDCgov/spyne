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
include { check_irma } from "${launchDir}/spyne_nextflow/modules/check_irma.nf"
include { pass_negatives } from "${launchDir}/spyne_nextflow/modules/pass_negatives.nf"
include { catfiles } from "${launchDir}/spyne_nextflow/modules/catfiles.nf"
include { dais_ribosome } from "${launchDir}/spyne_nextflow/modules/dais_ribosome.nf"
include { prepareIRMAjson } from "${launchDir}/spyne_nextflow/modules/prepareIRMAjson.nf"
include { staticHTML } from "${launchDir}/spyne_nextflow/modules/staticHTML.nf"

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
    new_ch4 = subsample.out.subsampled_fastq.map { tuple ->
                [sample_ID: tuple[0], subsampled_R1: tuple[1], subsampled_R2: tuple[2]]
    }
    new_ch5 = irma_chemistry_ch.map {item ->
                [sample_ID: item.sample_ID, irma_custom_0:item.irma_custom_0, irma_custom_1:item.irma_custom_1]
    } 
    irma_ch = new_ch4.combine(new_ch5)
                .filter { it[0].sample_ID == it[1].sample_ID }
                .map { [it[0].sample_ID, it[0].subsampled_R1, it[0].subsampled_R2, it[1].irma_custom_0, it[1].irma_custom_1] }
    irma( irma_ch )
    
    // Irma checkpoint
    checkirma_ch = irma.out.irma_dir
    check_irma( checkirma_ch )

    // Filter samples to passed and failed
    passedSamples = check_irma.out.filter { it[1].text.trim() == 'passed' }.map { it[0] }
    failedSamples = check_irma.out.filter { it[1].text.trim() == 'failed' }.map { it[0] }

    // Process failed samples
    pass_negatives( failedSamples )

    // Proceed with passed samples
    // cat all fasta files into one
    catfile_ch = passedSamples.collect()
    catfiles ( catfile_ch )

    // Run dais_ribosome
    dais_ribosome ( catfiles.out )

    // prepare IRMA json files
    prepareIRMAjson ( dais_ribosome.out.collect() )

    // Create static HTML output
    staticHTML ( prepareIRMAjson.out )
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
