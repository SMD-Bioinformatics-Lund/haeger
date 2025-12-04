#!/usr/bin/env python3

import csv
import argparse
import sys
import glob
import os
from pathlib import Path

VERSION = "0.0.1"

description = '''
------------------------
Title: concatenate_reads.py
Date: 2025-08-28
Author(s): Ryan Kennedy
------------------------
Description:
    This script concatenates fastq files based on glob patterns in a CSV file.

List of functions:
    concatenate_fastq_files, process_csv_and_concatenate.

List of standard modules:
    csv, argparse, sys, glob, os, Path

List of "non standard" modules:
    None

Procedure:
    1. Parse input csv samplesheet file.
    2. For each row, find files matching fastqs glob pattern.
    3. Concatenate matching files for each sample.
    4. Write output csv with concatenated file paths.

-----------------------------------------------------------------------------------------------------------
'''

usage = '''
-----------------------------------------------------------------------------------------------------------
Concatenates fastq files based on glob patterns and creates output samplesheet.
Executed using: python3 ./concatenate_reads.py -i <Input_Filepath> -o <Output_Filepath> [--sample-id-column-name <Sample_ID_Column_Name>] [--sample-read-filepath <Sample_Read_Filepath>]
-----------------------------------------------------------------------------------------------------------
'''

parser = argparse.ArgumentParser(
                description=description,
                formatter_class=argparse.RawDescriptionHelpFormatter,
                epilog=usage
                )

parser.add_argument(
    '-v', '--version',
    action='version',
    version=f'%(prog)s {VERSION}'
    )
parser.add_argument(
    '-i', '--input',
    help='input csv file',
    metavar='Input_Filepath',
    dest='input',
    required=True
    )
parser.add_argument(
    '-o', '--output',
    help='output csv file',
    metavar='Output_Filepath',
    dest='output',
    required=True
    )
parser.add_argument(
    '--sample-id-column-name',
    help='name for sample ID column in output CSV',
    default='sample',
    dest='sample_column'
    )
parser.add_argument(
    '--sample-read-filepath',
    help='name for fastq filepath column in output CSV',
    default='fastq_1',
    dest='fastq_column'
    )

args = parser.parse_args()

def concatenate_fastq_files(fastq_files, output_file):
    """
    Concatenate multiple gzipped fastq files into a single file.

    Args:
        fastq_files (list): List of fastq file paths to concatenate
        output_file (str): Path to output concatenated file

    Returns:
        bool: True if successful, False otherwise
    """
    try:
        # Create output directory if it doesn't exist
        os.makedirs(os.path.dirname(output_file), exist_ok=True)

        # Use cat command to concatenate gzipped files
        with open(output_file, 'wb') as outfile:
            for fastq_file in sorted(fastq_files):
                if os.path.exists(fastq_file):
                    with open(fastq_file, 'rb') as infile:
                        outfile.write(infile.read())
                else:
                    print(f"Warning: File not found: {fastq_file}", file=sys.stderr)

        return True
    except Exception as e:
        print(f"Error concatenating files: {str(e)}", file=sys.stderr)
        return False

def process_csv_and_concatenate(input_file, output_file, sample_column, fastq_column):
    """
    Process CSV file and concatenate fastq files based on glob patterns.

    Args:
        input_file (str): Path to input CSV file
        output_file (str): Path to output CSV file
        sample_column (str): Name for sample ID column in output
        fastq_column (str): Name for fastq filepath column in output

    Returns:
        int: Number of samples processed
    """
    try:
        with open(input_file, 'r', newline='', encoding='utf-8') as infile:
            reader = csv.DictReader(infile)

            # Verify required columns exist
            required_columns = ['id', 'fastqs']
            missing_columns = [col for col in required_columns if col not in reader.fieldnames]

            if missing_columns:
                raise ValueError(f"Missing required columns: {', '.join(missing_columns)}")

            # Prepare output data
            output_rows = []

            for row in reader:
                sample_id = row['id']
                fastq_pattern = row['fastqs']

                # Find files matching the glob pattern
                matching_files = glob.glob(fastq_pattern)

                if not matching_files:
                    print(f"Warning: No files found for pattern: {fastq_pattern}", file=sys.stderr)
                    continue

                print(f"Found {len(matching_files)} files for sample {sample_id}")

                # Create output filename
                output_dir = Path(output_file).parent / "concatenated_fastqs"
                concatenated_file = output_dir / f"{sample_id}_concatenated.fastq.gz"

                # Concatenate files
                if concatenate_fastq_files(matching_files, str(concatenated_file)):
                    output_rows.append({
                        sample_column: sample_id,
                        fastq_column: str(concatenated_file)
                    })
                    print(f"Successfully concatenated {len(matching_files)} files for {sample_id}")
                else:
                    print(f"Failed to concatenate files for sample {sample_id}", file=sys.stderr)

            # Write output CSV
            with open(output_file, 'w', newline='', encoding='utf-8') as outfile:
                if output_rows:
                    fieldnames = [sample_column, fastq_column]
                    writer = csv.DictWriter(outfile, fieldnames=fieldnames)
                    writer.writeheader()
                    writer.writerows(output_rows)

            return len(output_rows)

    except FileNotFoundError:
        raise FileNotFoundError(f"Input file not found: {input_file}")
    except Exception as e:
        raise Exception(f"Error processing files: {str(e)}")

def main():
    """Main function to handle command line arguments and execute concatenation."""
    # Validate input file exists
    if not Path(args.input).exists():
        print(f"Error: Input file '{args.input}' does not exist.", file=sys.stderr)
        sys.exit(1)

    # Create output directory if it doesn't exist
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    try:
        print(f"Reading from: {args.input}")
        print(f"Writing to: {args.output}")
        print(f"Output columns: {args.sample_column}, {args.fastq_column}")

        # Perform the concatenation
        sample_count = process_csv_and_concatenate(
            args.input,
            args.output,
            args.sample_column,
            args.fastq_column
        )

        print(f"Successfully processed {sample_count} samples")
        print(f"Output written to: {args.output}")

    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
