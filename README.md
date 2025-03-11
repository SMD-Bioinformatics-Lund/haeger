Post-processing for the the [gms_16S](https://github.com/genomic-medicine-sweden/gms_16S) pipeline

### Running sulphur

```
Example run script which can be executed using sbatch:

#!/bin/bash
#SBATCH --job-name=sulphur
#SBATCH --output=slurm_logs/%j.log
#SBATCH --ntasks=4
#SBATCH --mem=4gb
#SBATCH --time=7-00:00:00
#SBATCH --partition="grace-lowest"

module load Java/13.0.2
module load nextflow/24.04.3
module load singularity/3.2.0

main_nf="/path/to/sulphur/main.nf"
csv="/path/to/samplesheet.csv"
sequencing_run="YYMMDD_SEQUENCING_RUN_ID"

nextflow run "${main_nf}" \
    --csv "${csv}" \
    --sequencing_run ${sequencing_run} | tee "${outdir}/run.log"
```