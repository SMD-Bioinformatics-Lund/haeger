process PARSE_QC_FOR_CDM {
    input:
    tuple val(meta), path(nanostats)

    output:
    tuple val(meta), path("${prefix}_qc.json"), emit: json
    path "versions.yml"                       , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    parse_qc_for_cdm.py ${args} --input ${nanostats} --output ${prefix}_qc.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        parse_qc_for_cdm: \$(parse_qc_for_cdm.py --version | sed 's/^.*parse_qc_for_cdm.py //' )
    END_VERSIONS
    """

    stub:
    def prefix  = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_qc.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        parse_qc_for_cdm: \$(parse_qc_for_cdm.py --version | sed 's/^.*parse_qc_for_cdm.py //')
    END_VERSIONS
    """
}
