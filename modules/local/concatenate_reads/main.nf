process CONCATENATE_READS {
    input:
    path csv
    
    output:
    path output          , emit: csv
    path "*.fastq.gz"    , emit: fastq
    path "versions.yml"  , emit: versions

    script:
    def args = task.ext.args ?: ''
    output = csv.baseName + "_concatenated.csv"
    """
    concatenate_reads.py ${args} --input ${csv} --output ${output}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        concatenate_reads: \$(concatenate_reads.py --version | sed 's/^.*concatenate_reads.py //' )
    END_VERSIONS
    """

    stub:
    output = csv.baseName + "_concatenated.csv"
    """
    touch stub.fastq.gz
    echo -e "sample,fastq_1\\ntest_sample,\${PWD}/stub.fastq.gz" > ${output}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        concatenate_reads: \$(concatenate_reads.py --version | sed 's/^.*concatenate_reads.py //' )
    END_VERSIONS
    """
}
