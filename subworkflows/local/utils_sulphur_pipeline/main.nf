//
// Subworkflow with functionality specific to the nf-core/raredisease pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { samplesheetToList } from 'plugin/nf-schema'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SUBWORKFLOW TO INITIALISE PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow PIPELINE_INITIALISATION {

    take:
    input 

    main:

    Channel
        .fromList(samplesheetToList(input, "${projectDir}/assets/schema_input.json"))
        .tap { ch_original_input }
        .map { meta, fastq1, fastq2 -> meta.id }
        .reduce([:]) { counts, sample -> //get counts of each sample in the samplesheet - for groupTuple
            counts[sample] = (counts[sample] ?: 0) + 1
            counts
        }
        .combine( ch_original_input )
        .map { counts, meta, fastq1, fastq ->
            if (!fastq2) {
                return [ meta + [ single_end:true ], [ fastq1 ] ]
            } else {
                return [ meta + [ single_end:false ], [ fastq1, fastq2 ] ]
            }
        }
        .tap{ ch_input_counts }
        .map { meta, fastqs -> fastqs }
        .reduce([:]) { counts, fastqs -> //get line number for each row to construct unique sample ids
            counts[fastqs] = counts.size() + 1
            return counts
        }
        .combine( ch_input_counts )
        .map { lineno, meta, fastqs -> //append line number to sampleid
            new_meta = meta + [id:meta.id+"_LNUMBER"+lineno[fastqs]]
            return [ new_meta, fastqs ]
        }
        .set { ch_samplesheet }

    ch_samplesheet
        .map { meta, fastqs ->
            new_id = meta.sample
            new_meta = meta - meta.subMap('lane', 'read_group') + [id:new_id]
            return new_meta
        }
        .unique()
        .set { ch_samples }


    emit:
    samplesheet = ch_samplesheet
    samples     = ch_samples
}