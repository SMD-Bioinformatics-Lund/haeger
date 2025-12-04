Post-processing for the [trana](https://github.com/genomic-medicine-sweden/trana) pipeline

### Running haeger

Example run script which can be executed using sbatch:

```
#!/bin/bash
#SBATCH --job-name=haeger
#SBATCH --output=slurm_logs/%j.log
#SBATCH --ntasks=4
#SBATCH --mem=4gb
#SBATCH --time=7-00:00:00
#SBATCH --partition="grace-lowest"

module load Java/13.0.2
module load nextflow/24.04.3
module load singularity/3.2.0

main_nf="/path/to/haeger/main.nf"
csv="/path/to/samplesheet.csv"

nextflow run "${main_nf}" \
    --csv "${csv}" | tee "${outdir}/run.log"
```