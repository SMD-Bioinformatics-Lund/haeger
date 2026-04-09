#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { TRANA                   } from '../trana/workflows/trana.nf'
include { PIPELINE_INITIALISATION } from './subworkflows/local/pipeline_initialisation/main.nf'
include { HAEGER                  } from './workflows/haeger.nf'

workflow {
    main:

    ch_versions = Channel.empty()

    //
    // Initialize file channels
    //
    input_samples    = params.csv        ? file(params.csv, checkIfExists: true)        : null
    merge_fastq_pass = params.fastq_pass ? file(params.fastq_pass, checkIfExists: true) : null

    //
    // SUBWORKFLOW: Concatenate reads and parse samplesheet
    //
    PIPELINE_INITIALISATION (input_samples)
    ch_versions = ch_versions.mix(PIPELINE_INITIALISATION.out.versions)

    if (params.run_trana) {
        //
        // WORKFLOW: Run main workflow
        //
        TRANA (
            PIPELINE_INITIALISATION.out.samplesheet,
            PIPELINE_INITIALISATION.out.reads,
            params.outdir
        )
        ch_versions = ch_versions.mix(TRANA.out.versions)

        HAEGER (TRANA.out.nanostats_unprocessed)
        ch_versions = ch_versions.mix(HAEGER.out.versions)
    } else {
        ch_nanostats = PIPELINE_INITIALISATION.out.reads.map { meta, reads ->
            def sample_id = meta.id
            def nanostats_txt = String.format(params.trana_results_paths.nanostats_txt, sample_id)
            tuple(meta, file(nanostats_txt))
        }
        HAEGER (ch_nanostats)
        ch_versions = ch_versions.mix(HAEGER.out.versions)
    }
}
