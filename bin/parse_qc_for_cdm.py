"""Generate a master html template."""

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
    csv, argparse.

List of "non standard" modules:
    pandas, .

Procedure:
    1. Get sample IDs by parsing samplesheet csv.
    2. Render html using template.
    3. Write out master.html file.

-----------------------------------------------------------------------------------------------------------
'''

usage = '''
-----------------------------------------------------------------------------------------------------------
Generates master html file that points to all html files.
Executed using: python3 ./generate_master_html.py -i <Input_Directory> -o <Output_Filepath>
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
    version='%(prog)s {VERSION}'
    )
parser.add_argument(
    '-i', '--input',
    help='input from NanoPlot NanoStats file',
    metavar='NANOPLOT_INPUT_FILE',
    dest='input',
    required=True
    )
parser.add_argument(
    '-c', '--cdmpy',
    help='input from NanoPlot NanoStats file',
    metavar='CDMPY_OUTPUT_FILE',
    dest='cdmpy',
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
        current_section = "top_quality_scores"
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
                key = key.strip().lower().replace(" ", "_")
                value = value.strip().replace(",", "")
                value = float(value) if "." in value else int(value)
                summary_dict[key] = value

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

                if current_section == "top_scores":
                    match = re.match(r"^(\d+):\s+([\d.]+)\s+\((\d+)\)$", line)
                    if match:
                        rank = match.group(1)
                        mean_quality = float(match.group(2))
                        read_length = int(match.group(3))
                        if current_section in summary_dict:
                            summary_dict[current_section][rank] = (mean_quality, read_length)
                        else:
                            summary_dict[current_section] = {rank: (mean_quality, read_length)}

                if current_section == "top_longest_reads":
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
