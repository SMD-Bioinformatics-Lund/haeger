process EXPORT_TO_CDM {

  input:
    tuple val(sample_id), path(qc), val(sequencing_run), val(lims_id), val(sample_name)
    val species

  output:
    tuple val(meta), path("${prefix}.cdmpy"), emit: cdmpy

  script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo --sequencing-run ${sequencing_run} \\
        --sample-id ${sample_name} \\
        --assay ${species} \\
        --qc ${params.outdir}/${params.speciesDir}/${params.cdmDir}/${qc} \\
        --lims-id ${lims_id} > ${prefix}.cdmpy
    """

  stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.cdmpy
    """
}
