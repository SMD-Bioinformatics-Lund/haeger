#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { GMSEMU                  } from '../taco/workflows/gmsemu.nf'
include { PIPELINE_INITIALISATION } from './subworkflows/local/utils_sulphur_pipeline/main.nf'
include { SULPHUR                 } from './workflows/sulphur.nf'

workflow {
    main:
    ch_versions = Channel.empty()

    PIPELINE_INITIALISATION (params.csv)

    PIPELINE_INITIALISATION.out.reads.map {
        meta, reads -> [meta + [single_end: 1]]
    }.set{ ch_meta }

    if (params.run_taco) {
        GMSEMU (PIPELINE_INITIALISATION.out.samplesheet, PIPELINE_INITIALISATION.out.reads)
        ch_versions.mix(GMSEMU.out.versions)

        SULPHUR (GMSEMU.out.nanostats_unprocessed)
        ch_versions.mix(SULPHUR.out.versions)
    } else {
        ch_nanostats = ch_meta.map { meta ->
            def sample_id = meta.id
            def sequencing_run = meta.sequencing_run
            def nanostats_txt = String.format(params.taco_results_paths.nanostats_txt, sequencing_run, sample_id)
            tuple(meta, file(nanostats_txt))
        }
        SULPHUR (ch_nanostats)
        ch_versions.mix(SULPHUR.out.versions)
    }
}