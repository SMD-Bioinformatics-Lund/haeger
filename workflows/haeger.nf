// Postprocessing
include { PARSE_QC_FOR_CDM  } from '../modules/local/qc/main.nf'
include { EXPORT_TO_CDM     } from '../modules/local/cdm/main.nf'

workflow HAEGER {
    take:
    ch_nanoplot

    main:
    ch_versions = Channel.empty()

    PARSE_QC_FOR_CDM(ch_nanoplot)
    ch_versions = ch_versions.mix(PARSE_QC_FOR_CDM.out.versions)

    EXPORT_TO_CDM(PARSE_QC_FOR_CDM.out.json)

    emit:
    versions = ch_versions
}
