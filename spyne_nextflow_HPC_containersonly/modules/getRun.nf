#!/usr/bin/env nextflow

/*
========================================================================================
   getRun module
========================================================================================
*/

nextflow.enable.dsl = 2

process getRun {
    tag { 'Creating static HTML output' }

    publishDir "${params.r}", mode: 'copy'

    input:
    path('*')

    output:
    stdout

    script:
    '''
    parameter=$(cat hold_path.txt)
    base_name=$(basename ${parameter})
    echo ${base_name}
    '''
}
