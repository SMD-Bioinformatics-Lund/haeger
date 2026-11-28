# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

 - Added `haeger_software_versions.yml` to `pipeline_info`, listing the versions of haeger's own tools

### Fixed

 - Fixed `nanostats_txt` path failing to parse with Nextflow's strict config syntax
 - Fixed `nanostats_txt` path to match TRANA's `nanoplot_unprocessed` output
 - Fixed `concatenate_reads.py` not being executable
 - Fixed `concatenate_reads.py` failing when the output CSV path has no directory
 - Fixed `concatenate_reads.py` writing relative fastq paths that failed samplesheet validation
 - Fixed boolean flags such as `--run_trana false` counting as true when passed on the command line with Nextflow's strict syntax parser
 - Fixed `EXPORT_TO_CDM` writing `null` for the sequencing run, assay and LIMS ID
 - Fixed `EXPORT_TO_CDM` pointing `--qc` at the CDM directory instead of the QC directory
 - Fixed TRANA's `pipeline_info` reports going to `null/pipeline_info` unless `--outdir` was given on the command line or in a params file
 - Fixed CI failing to install Apptainer now that `ubuntu-latest` is Ubuntu 26.04, by pinning the runner to `ubuntu-24.04`

### Changed

 - `concatenate_reads.py` now copies the input CSV's other columns into its output samplesheet, and they are added to `meta`
 - Bumped `concatenate_reads.py` to version 0.1.0
 - TRANA's master HTML is now named after the sequencing run rather than the run timestamp
 - Pinned CI's TRANA checkout to `v1.1.0` instead of TRANA's `main` branch

## [0.1.0]

### Added

 - Added `parse_qc_for_cdm.py` to bin
 - Added `cdm` & `qc` modules
 - Added config that overrides `trana` config
 - Added `CHANGELOG`
 - Added `concatenate_reads.py` to bin
 - Added `PIPELINE_INITIALISATION` subworkflow
 - Added `nextflow_schema.json` for parameter validation
 - Added haeger-specific MultiQC assets
 - Added CI stub-run workflow and `test` profile

### Fixed

### Changed
