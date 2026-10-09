params.step = 0
params.zip = 'zip'


process SAYHELLO {
    debug(true)
    script:
    '''
    echo "Hello World!"
    '''
}

process SAYHELLO_PYTHON{
    debug(true)
    script:
    '''
    python -c 'print("Hello World from python!")'
    '''
}
process UPPERCASE {
    debug true

    input:
    val input

    output:
    path "UPPER.txt"

    script:
    """
    echo "${input}" | tr '[:lower:]' '[:upper:]' > UPPER.txt
    """
}
process SAYHELLO_PARAM{
    debug(true)
    input:
    val input

    script:
    """
    echo ${input}
    """
}
process SAYHELLO_FILE{
    debug(true)
    input:
    val input

    script:
    """
    echo ${input} > hello_world.txt
    cat hello_world.txt
    """
}
process PRINTUPPER{
    debug(true)
    input:
    path input

    script:
    """
    cat ${input}
    """
}
process WRITETOFILE{
    publishDir 'results', mode: 'copy'
    input:
    val input

    output:
    path "names.txt"

    script:
    """
    printf "${input}" > names.txt
    """
}

process ZIP{
    input:
    path input

    output:
    path "${input}.gz"

    script:
    """
    gzip -c "${input}" > ${input}.gz
    """
}

process ALL_ZIP{
    input:
    path input

    output:
    tuple   path("${input.baseName}.zip"),
            path("${input}.gz"),
            path("${input}.bz2")

    script:
    """
    zip ${input.baseName}.zip ${input}
    gzip -c ${input} > ${input}.gz
    bzip2 -c ${input} > ${input}.bz2
    """
}
process WRITE_TSV{
    publishDir 'results', mode: 'copy'

    input:
    val text

    output:
    path "names.tsv"

    script:
    """
    printf '%s\n' "${text}" > names.tsv
    """
}



workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == "1") {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == "2") {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == "3") {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == "4") {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == "5") {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == "6") {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == "7") {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        if (params.zip == 'zip') {
            out_ch = ZIP(out_ch)
        }
        out_ch.view()
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == "8") {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch = ALL_ZIP(out_ch)
        out_ch.view()
    }

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == "9") {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )

        in_ch
            .map { it -> "${it.name}\t${it.title}"}
            .collect()
            .map { rows -> "name\ttitle\n" + rows.join('\n')}
            | WRITE_TSV
            | view()
    }

}