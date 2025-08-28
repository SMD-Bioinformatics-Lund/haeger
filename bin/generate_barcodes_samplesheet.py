#!/usr/bin/env python3

import csv
import argparse
import sys
from pathlib import Path

VERSION = "0.0.1"

description = '''
------------------------
Title: generate_barcodes_samplesheet.py
Date: 2025-08-28
Author(s): Ryan Kennedy
------------------------
Description:
    This script creates the input csv file for gms_16S pipeline.

List of functions:
    filter_columns_and_writeout.

List of standard modules:
    csv, argparse, sys, Path

List of "non standard" modules:
    None

Procedure:
    1. Parse input csv samplesheet file.
    2. Write out csv samplesheet file.

-----------------------------------------------------------------------------------------------------------
'''

usage = '''
-----------------------------------------------------------------------------------------------------------
Creates csv samplesheet file for gms_16S pipeline input.
Executed using: python3 ./generate_barcodes_samplesheet.py -i <Input_Filepath> -o <Output_Filepath>
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

args = parser.parse_args()


def filter_columns_and_writeout(input_file, output_file):
    """
    Convert CSV file to CSV, extracting only barcode and sample_id columns.
    
    Args:
        input_file (str): Path to input CSV file
        output_file (str): Path to output CSV file
    
    Returns:
        int: Number of data rows processed (excluding header)
    """
    try:
        with open(input_file, 'r', newline='', encoding='utf-8') as infile:
            reader = csv.DictReader(infile)
            
            # Verify required columns exist
            required_columns = ['barcode', 'sample_id']
            missing_columns = [col for col in required_columns if col not in reader.fieldnames]
            
            if missing_columns:
                raise ValueError(f"Missing required columns: {', '.join(missing_columns)}")
            
            with open(output_file, 'w', newline='', encoding='utf-8') as outfile:
                writer = csv.writer(outfile, delimiter=',')
                
                # Write header
                writer.writerow(['barcode', 'sample_id'])
                
                # Write data rows
                row_count = 0
                for row in reader:
                    writer.writerow([row['barcode'], row['sample_id']])
                    row_count += 1
                
                return row_count
                
    except FileNotFoundError:
        raise FileNotFoundError(f"Input file not found: {input_file}")
    except Exception as e:
        raise Exception(f"Error processing files: {str(e)}")


def main():
    """Main function to handle command line arguments and execute conversion."""
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
        
        # Perform the conversion
        row_count = filter_columns_and_writeout(args.input, args.output)
        
        print(f"Successfully processed {row_count} data rows")
        print(f"Output written to: {args.output}")
            
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
