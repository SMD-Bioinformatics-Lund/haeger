process GENERATE_BARCODES_SAMPLESHEET {
    input:
    path csv
    
    output:
    path output
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''
    """
    generate_barcodes_samplesheet.py ${args} --input ${csv} --output ${output}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        generate_barcodes_samplesheet: \$(generate_barcodes_samplesheet.py --version | sed 's/^.*generate_barcodes_samplesheet.py //' )
    END_VERSIONS
    """
}
