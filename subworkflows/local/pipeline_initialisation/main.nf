include { CONCATENATE_READS } from '../../../modules/local/concatenate_reads/main.nf'

include { samplesheetToList } from 'plugin/nf-schema'

workflow PIPELINE_INITIALISATION {

    take:
    csv              // path: haeger input CSV

    main:

    ch_versions = Channel.empty()

    CONCATENATE_READS (csv)
    ch_versions = ch_versions.mix(CONCATENATE_READS.out.versions)

    CONCATENATE_READS.out.csv
        .flatMap { samplesheet_path ->
            samplesheetToList(samplesheet_path, "${projectDir}/assets/schema_input.json")
        }
        .map { meta, fastq_1, fastq_2 ->
            fastq_2
                ? [ meta.id, meta + [ single_end: false ], [ fastq_1, fastq_2 ] ]
                : [ meta.id, meta + [ single_end: true  ], [ fastq_1           ] ]
        }
        .groupTuple()
        .map { validateInputSamplesheet(it) }
        .set { ch_reads }

    emit:
    samplesheet = CONCATENATE_READS.out.csv  // channel: path to concatenated samplesheet
    reads       = ch_reads                   // channel: [ val(meta), [ reads ] ]
    versions    = ch_versions
}

def validateInputSamplesheet(input) {
    def (metas, fastqs) = input[1..2]
    if (metas.collect { it.single_end }.unique().size != 1) {
        error("Please check input samplesheet -> Multiple runs of a sample must be of the same datatype i.e. single-end or paired-end: ${metas[0].id}")
    }
    return [ metas[0], fastqs[0] ]
}
