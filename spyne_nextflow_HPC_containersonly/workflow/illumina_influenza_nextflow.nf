#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Initiate parameters
params.s = null
params.r = null
params.e = null

//Info required for completion email and summary
def final_report = []
//def html_file = []

// Import modules
include { create_nextflow_samplesheet } from "${launchDir}/modules/create_nextflow_samplesheet.nf"
include { find_chemistry              } from "${launchDir}/modules/find_chemistry.nf"
include { subsample                   } from "${launchDir}/modules/subsample.nf"
include { irma                        } from "${launchDir}/modules/irma.nf"
include { check_irma                  } from "${launchDir}/modules/check_irma.nf"
include { pass_negatives              } from "${launchDir}/modules/pass_negatives.nf"
include { catfiles                    } from "${launchDir}/modules/catfiles.nf"
include { dais_ribosome               } from "${launchDir}/modules/dais_ribosome.nf"
include { prepareIRMAjson             } from "${launchDir}/modules/prepareIRMAjson.nf"
include { staticHTML                  } from "${launchDir}/modules/staticHTML.nf"
include { getRun                      } from "${launchDir}/modules/getRun.nf"
include { parquetMaker                } from "${launchDir}/modules/parquetMaker.nf"
include { renameFiles                 } from "${launchDir}/modules/renameFiles.nf"
include { prepEmail                   } from "${launchDir}/modules/prepEmail.nf"

// Orchestrate the process flow
workflow {
    samplesheet_ch = Channel.fromPath(params.s, checkIfExists: true)
    run_ID_ch = Channel.fromPath(params.r, checkIfExists: true)
    experiment_type_ch = Channel.value(params.e)

    // Convert the samplesheet to a nextflow format
    create_nextflow_samplesheet(samplesheet_ch, run_ID_ch, experiment_type_ch)

    // Generate input_channel
    input_ch = create_nextflow_samplesheet.out
        .splitCsv(header: true)

    // Find chemistry
    new_ch = input_ch.map { item ->
        [item.sample_ID, item.fastq_1]
    }
    find_chemistry_ch = new_ch.combine(run_ID_ch)
    find_chemistry(find_chemistry_ch)

    // Create the irma chemistry channel
    irma_chemistry_ch = find_chemistry.out
        .splitCsv(header: true)

    // Subsample
    new_ch2 = input_ch.map { item ->
        [sample_ID:item.sample_ID, fastq_1:item.fastq_1, fastq_2:item.fastq_2]
    }
    new_ch3 = irma_chemistry_ch.map { item ->
                [sample_ID: item.sample_ID, subsample:item.subsample]
    }
    subsample_ch = new_ch2.combine(new_ch3)
                .filter { it[0].sample_ID == it[1].sample_ID }
                .map { [it[0].sample_ID, it[0].fastq_1, it[0].fastq_2, it[1].subsample] }
    subsample(subsample_ch)

    // Run irma
    new_ch4 = subsample.out.subsampled_fastq.map { item ->
                [sample_ID: item[0], subsampled_R1: item[1], subsampled_R2: item[2]]
    }
    irma_ch = new_ch4.combine(irma_chemistry_ch)
                .filter { it[0].sample_ID == it[1].sample_ID }
                .map { [it[0].sample_ID, it[0].subsampled_R1, it[0].subsampled_R2, it[1].irma_custom_0, it[1].irma_custom_1] }
    irma(irma_ch)

    // Irma checkpoint
    check_irma_ch = irma.out.map { item ->
        def sample = item[0]
        def paths = item[1]
        def directory = paths.find { it.endsWith(sample) && !it.endsWith('.log') }
        return tuple(sample, directory)
    }
    check_irma(check_irma_ch)

    // Filter samples to passed and failed
    passedSamples = check_irma.out.filter { it[2].text.trim() == 'passed' }.map { it[1] }
    failedSamples = check_irma.out.filter { it[2].text.trim() == 'failed' }.map { it[0] }

    // Process failed samples
    pass_negatives(failedSamples)

    // Proceed with passed samples
    // cat all fasta files into one
    catfiles(passedSamples.collect())

    // Run dais_ribosome
    dais_ribosome(catfiles.out)

    // prepare IRMA json files
    prepareIRMAjson(dais_ribosome.out.collect())

    // Create static HTML output
    staticHTML(prepareIRMAjson.out)

    //Get run name
    getRun(staticHTML.out)

    //Create parquet files
    parquetMaker(getRun.out)

    //Create parquet files
    renameFiles(parquetMaker.out)

    //Prepare email output
    prepEmail(renameFiles.out)
}

// Workflow Event Handler

workflow.onComplete {
    def msg = """\
       Pipeline execution summary
       ---------------------------
       Completed at: ${workflow.complete}
       Duration    : ${workflow.duration}
       Success     : ${workflow.success}
       workDir     : ${workflow.workDir}
       exit status : ${workflow.exitStatus}
       """
       .stripIndent()

    sendMail(to: 'xpa3@cdc.gov', subject: 'Nextflow pipeline execution', body:msg, attach: './summary.xlsx')
}
