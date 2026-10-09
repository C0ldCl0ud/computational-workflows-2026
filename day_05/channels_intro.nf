workflow{

    // =========================================================================== //
    //                                  Examples                                   //                            
    // =========================================================================== //

    def out_ch

    // Queue channel
    if (params.step == "0") {
        out_ch = channel.of(1,2,3)
    }

    // Value channel
    if (params.step == 00) {
        out_ch = channel.value(1)
    }


    // =========================================================================== //
    //                                  Tasks                                      //                            
    // =========================================================================== //


    // Task 1 - Create a channel that enumerates the numbers from 1 to 10

    if (params.step == "1") {
        out_ch = channel.fromList(1..10)
    }

    // Task 2 - Create a channel that gives out the entire alphabet
    
    if (params.step == "2") {
        out_ch = channel.fromList('a'..'z')
    }

    // Task 3 - Create a channel that includes all files in the "files_dir" directory

    if (params.step == "3") {
        out_ch = channel.fromPath("${params.files_dir}/*")
    }

    // Task 4 - Create a channel that includes all TXT files in the "files_dir" directory
    
    if (params.step == "4") {
        out_ch = channel.fromPath("${params.files_dir}/*.txt")
    }

    // Task 5 - Create a channel that includes the files "fastq_1.fq" and "fastq_2.fq" in the "files_dir" directory

if (params.step == '5') {
    def files = params.files.split(',')

    out_ch = channel.fromList(
        files.collect { filename ->
            file("${params.files_dir}/${filename}")
        }
    )
}

    // Task 6 - go back to the time when you included all files. Are you sure that really ALL files are included? If not, how can you include them?

    if (params.step == "6") {
        if (params.include_hidden) {
            out_ch = channel.fromPath("${params.files_dir}/*", hidden: true)
        }else{
            out_ch = channel.fromPath("${params.files_dir}/*")
        }
    }

    // Task 7 - get all filepairs in the "files_dir" directory

    if (params.step == "7") {
        out_ch = channel.fromFilePairs("${params.files_dir}/*_{1,2}.*")
    }
    
    out_ch.view()

}