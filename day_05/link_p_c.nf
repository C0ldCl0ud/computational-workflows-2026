#!/usr/bin/env nextflow

process SPLITLETTERS {
    publishDir 'results', mode: 'copy'
    input:
    val input

    output:
    path "${input.out_name}.txt"

    script:
    """
    echo "${input.input_str}" | fold -w "${input.block_size}" > ${input.out_name}.txt
    """
} 

process CONVERTTOUPPER {
    input:
    path input

    output:
    stdout

    script:
    """
    cat ${input} | tr '[:lower:]' '[:upper:]'
    """
} 

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    in_ch = channel.fromPath("samplesheet_2.csv")
    samples_ch = in_ch
                .splitCsv(header: true)
    samples_ch.view()
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    out_ch = samples_ch | SPLITLETTERS
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout
    out_ch | CONVERTTOUPPER | view()
    out_ch.view()
    // read in samplesheet}

    // split the input string into chunks

    // lets remove the metamap to make it easier for us, as we won't need it anymore

    // convert the chunks to uppercase and save the files to the results directory



}