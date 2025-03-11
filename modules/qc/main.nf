process PARSE_QC_FOR_CDM {
    //               Software MUST be pinned to channel (i.e. "bioconda"), version (i.e. "1.10").
    //               For Conda, the build (i.e. "pyhdfd78af_1") must be EXCLUDED to support installation on different operating systems.
    conda "conda-forge::nf-core=3.0.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nf-core:3.0.2--pyhdfd78af_1':
        'quay.io/biocontainers/nf-core:3.0.2' }"

    input:
    path nanostats

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
