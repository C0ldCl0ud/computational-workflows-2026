params.step = 0


workflow{


    // Task 1 - Read in the samplesheet.
    if (["1","2", "3", "4"].contains(params.step)) {
        def in_ch = channel.empty()
        def samples_ch = channel.empty()
        if (params.step >= "1") {
            in_ch = channel.fromPath('samplesheet.csv')
        }
        if (params.step == "1"){
            in_ch.view()
        }

        // Task 2 - Read in the samplesheet and create a meta-map with all metadata and another list with the filenames ([[metadata_1 : metadata_1, ...], [fastq_1, fastq_2]]).
        //          Set the output to a new channel "in_ch" and view the channel. YOU WILL NEED TO COPY AND PASTE THIS CODE INTO SOME OF THE FOLLOWING TASKS (sorry for that).

        if (params.step >= "2") {
            samples_ch = in_ch
                .splitCsv(header: true)
                .map {row ->
                    [row, [row.fastq_1, row.fastq_2]]
                }
        }
        if (params.step == "2"){
            samples_ch.view()
        }

        // Task 3 - Now we assume that we want to handle different "strandedness" values differently.
        //          Split the channel into the right amount of channels and write them all to stdout so that we can understand which is which.

        if (params.step >= "3") {
            strandedness_ch = samples_ch.branch{sample, fastq ->
                def valid_strandedness = ["forward","reverse","auto"]
                if (!valid_strandedness.contains(sample.strandedness)){
                    throw new IllegalArgumentException(
                        "Invalid strandedness '${sample.strandedness}' for sample '${sample.sample}'"
                    )
                }
                forward: sample.strandedness == "forward"
                reverse: sample.strandedness == "reverse"
                auto: sample.strandedness == "auto"
            }
        }
        if (params.step == "3"){
            strandedness_ch.forward.collect().view{ sample -> "forward: ${sample}"}
            strandedness_ch.reverse.collect().view{ sample -> "reverse: ${sample}"}
            strandedness_ch.auto.collect().view{ sample -> "auto: ${sample}"}
        }
        // Task 4 - Group together all files with the same sample-id and strandedness value.
        if (params.step == "4") {
            group_ch = samples_ch
                .map {meta, fastq ->
                    [[meta.sample, meta.strandedness], fastq]
                }
                .groupTuple()
            group_ch.view()
        }
    }




}