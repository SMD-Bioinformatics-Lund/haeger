process EXPORT_TO_CDM {

  input:
    tuple val(meta), path(qc)

  output:
    tuple val(meta), path("*.cdmpy"), emit: cdmpy

  script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo --sequencing-run ${meta.sequencing_run} \\
        --sample-id ${meta.id} \\
        --assay ${meta.assay} \\
        --qc ${params.cdm_outdir}/${qc} \\
        --lims-id ${meta.clarity_sample_id} > ${prefix}.cdmpy
    """

  stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.cdmpy
    """
}
