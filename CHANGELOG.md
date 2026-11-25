# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Fixed

 - Fixed `nanostats_txt` path failing to parse with Nextflow's strict config syntax
 - Fixed `nanostats_txt` path to match TRANA's `nanoplot_unprocessed` output
 - Fixed `concatenate_reads.py` not being executable
 - Fixed `concatenate_reads.py` failing when the output CSV path has no directory
 - Fixed `concatenate_reads.py` writing relative fastq paths that failed samplesheet validation

### Changed

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
