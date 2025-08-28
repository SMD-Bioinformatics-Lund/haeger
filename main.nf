#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { TACO                          } from '../taco/workflows/taco.nf'
include { PIPELINE_INITIALISATION       } from '../taco/subworkflows/local/utils_nfcore_taco_pipeline/main.nf'
include { GENERATE_BARCODES_SAMPLESHEET } from './modules/local/generate_barcodes_samplesheet/main.nf'
include { SULPHUR                       } from './workflows/sulphur.nf'

workflow {
    main:

    ch_versions                 = Channel.empty()

    //
    // Initialize file channels for GENERATE_BARCODES_SAMPLESHEET module
    //
    input_samples               = params.csv                ? file(params.csv, checkIfExists: true)
    merge_fastq_pass            = params.merge_fastq_pass   ? file(params.merge_fastq_pass, checkIfExists: true)

    GENERATE_BARCODES_SAMPLESHEET (input_samples)

    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    PIPELINE_INITIALISATION (
        params.version,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir,
        params.csv,
        GENERATE_BARCODES_SAMPLESHEET.out.barcodes_samplesheet,
        merge_fastq_pass
    )

    if (params.run_taco) {
        //
        // WORKFLOW: Run main workflow
        //
        TACO (
            PIPELINE_INITIALISATION.out.samplesheet,
            PIPELINE_INITIALISATION.out.reads
        )
        ch_versions.mix(TACO.out.versions)

        SULPHUR (TACO.out.nanostats_unprocessed)
        ch_versions.mix(SULPHUR.out.versions)
    } else {
        ch_nanostats = ch_meta.map { meta ->
            def sample_id = meta.id
            def nanostats_txt = String.format(params.taco_results_paths.nanostats_txt, sample_id)
            tuple(meta, file(nanostats_txt))
        }
        SULPHUR (ch_nanostats)
        ch_versions.mix(SULPHUR.out.versions)
    }
}
