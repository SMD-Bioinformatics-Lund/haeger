#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { TRANA                         } from '../trana/workflows/trana.nf'
include { PIPELINE_INITIALISATION       } from '../trana/subworkflows/local/utils_nfcore_trana_pipeline/main.nf'
include { CONCATENATE_READS             } from './modules/local/concatenate_reads/main.nf'
include { HAEGER                        } from './workflows/haeger.nf'

workflow {
    main:

    ch_versions                 = Channel.empty()

    //
    // Initialize file channels for CONCATENATE_READS module
    //
    input_samples               = params.csv                        ? file(params.csv, checkIfExists: true)
    merge_fastq_pass            = params.sequencing_run             ? file("${params.sequencing_run}/fastq_pass", checkIfExists: true)

    CONCATENATE_READS (input_samples)

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
        CONCATENATE_READS.out.csv,
        merge_fastq_pass
    )

    if (params.run_trana) {
        //
        // WORKFLOW: Run main workflow
        //
        TRANA (
            PIPELINE_INITIALISATION.out.samplesheet,
            PIPELINE_INITIALISATION.out.reads
        )
        ch_versions.mix(TRANA.out.versions)

        HAEGER (TRANA.out.nanostats_unprocessed)
        ch_versions.mix(HAEGER.out.versions)
    } else {
        ch_nanostats = ch_meta.map { meta ->
            def sample_id = meta.id
            def nanostats_txt = String.format(params.trana_results_paths.nanostats_txt, sample_id)
            tuple(meta, file(nanostats_txt))
        }
        HAEGER (ch_nanostats)
        ch_versions.mix(HAEGER.out.versions)
    }
}
