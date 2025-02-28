#!/usr/bin/env python

"""Generate qc json file from NanoPlot input file."""

import re
import json
import argparse

VERSION = "0.0.1"

description = '''
------------------------
Title: parse_qc_for_cdm.py
Date: 2025-02-27
Author(s): Ryan Kennedy
------------------------
Description:
    This script creates the input(s) for cdm.

List of functions:
    parse_summary, get_flag.

List of standard modules:
    re, csv, argparse.

List of "non standard" modules:
    None

Procedure:
    1. Parse NanoPlot NanoStats file.
    2. Write out qc json file.

-----------------------------------------------------------------------------------------------------------
'''

usage = '''
-----------------------------------------------------------------------------------------------------------
Creates qc json file for cdm input.
Executed using: python3 ./parse_qc_for_cdm.py -i <Input_Directory> -o <Output_Filepath>
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
    help='input from NanoPlot NanoStats file',
    metavar='NANOPLOT_INPUT_FILE',
    dest='input',
    required=True
    )
parser.add_argument(
    '-o', '--output',
    help='qc output json file',
    metavar='QC_OUTPUT_JSON_FILE',
    dest='output',
    required=True
    )

args = parser.parse_args()

def get_flag(line):
    if "reads above quality cutoffs" in line:
        current_section = "pct_above_x"
    elif "mean basecall quality scores" in line:
        current_section = "top_mean_quality_scores"
    elif "longest reads" in line:
        current_section = "top_longest_reads"
    return current_section

def parse_summary(file_path):
    summary_dict = {}
    current_section = None
    with open(file_path, 'r', encoding="utf-8") as file:
        for line in file:
            line = line.strip()
            if not line:
                continue
            if ":" in line:
                key, value = line.split(":", 1)
                if not value.strip():
                    continue
                key = key.strip().lower().replace(" ", "_")
                value = value.strip().replace(",", "")

                if current_section == "pct_above_x":
                    parts = line.split()
                    quality_score = parts[0].strip(":>").lower()
                    num_reads = int(parts[1])
                    percentage = float(parts[2].strip('()%'))
                    megabases = float(parts[3][:-2])
                    if current_section in summary_dict:
                        summary_dict[current_section][quality_score] = (num_reads, percentage, megabases)
                    else:
                        summary_dict[current_section] = {quality_score: (num_reads, percentage, megabases)}

                elif current_section == "top_mean_quality_scores":
                    match = re.match(r"^(\d+):\s+([\d.]+)\s+\((\d+)\)$", line)
                    if match:
                        rank = match.group(1)
                        mean_quality = float(match.group(2))
                        read_length = int(match.group(3))
                        if current_section in summary_dict:
                            summary_dict[current_section][rank] = (mean_quality, read_length)
                        else:
                            summary_dict[current_section] = {rank: (mean_quality, read_length)}

                elif current_section == "top_longest_reads":
                    match = re.match(r"^(\d+):\s+(\d+)\s+\(([\d.]+)\)$", line)
                    if match:
                        rank = match.group(1)
                        read_length = int(match.group(2))
                        mean_quality = float(match.group(3))
                        if current_section in summary_dict:
                            summary_dict[current_section][rank] = (read_length, mean_quality)
                        else:
                            summary_dict[current_section] = {rank: (read_length, mean_quality)}
                else:
                    try:
                        value = float(value) if "." in value else int(value)
                    except ValueError:
                        continue
                    summary_dict[key] = value
            else:
                current_section = get_flag(line)
    return summary_dict

def create_qc_output(version, summary_dict):
    return [
        {
        "software": "parse_qc_for_cdm",
        "version": version,
        "result": summary_dict
        }
    ]

def main():
    summary_dict = parse_summary(args.input)
    qc_output = create_qc_output(VERSION, summary_dict)
    with open(args.output, "w", encoding="utf-8") as fout:
        json.dump(qc_output, fout, indent=4)

if __name__ == "__main__":
    main()
