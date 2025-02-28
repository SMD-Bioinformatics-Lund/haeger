#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { GMSEMU  } from '../gms_16S/workflows/gmsemu.nf'
include { SULPHUR } from './workflows/sulphur.nf'

workflow {
    ch_versions = Channel.empty()
    Channel
        .fromPath(params.input)
        .splitCsv(header: true)
        .map { meta ->
            meta = meta + [ fq_pairs: 1, single_end: false, is_fastq: true, id: meta.sample ]
            meta
        }
        .set { ch_meta }

    if (params.run_16s) {
        GMSEMU()
        ch_versions.mix(GMSEMU.out.versions)

        SULPHUR(GMSEMU.out.nanostats)
        ch_versions.mix(SULPHUR.out.versions)
    } else {
        ch_nanostats = ch_meta.map { meta ->
            def sample_id = meta.sample
            def nanostats_txt = String.format(params.16s_results_paths.nanostats_txt, sequencing_run, sample_id)
            tuple(meta, file(nanostats_txt))
        }
        SULPHUR(GMSEMU.out.nanostats)
        ch_versions.mix(SULPHUR.out.versions)
    }
}