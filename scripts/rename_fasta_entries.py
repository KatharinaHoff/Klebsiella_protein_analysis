#!/usr/bin/env python3

import os
import argparse
from Bio import SeqIO

def process_fasta_files(input_dir, output_dir, suffix):
    # Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)
    
    # Iterate over all files in the input directory
    for filename in os.listdir(input_dir):
        if filename.endswith('.aa'):
            input_file_path = os.path.join(input_dir, filename)
            output_file_path = os.path.join(output_dir, filename)
            # print("Processing ", input_file_path)
            # Read the input fasta file
            with open(input_file_path, 'r') as infile:
                try:
                    record = next(SeqIO.parse(infile, 'fasta'))
                    # Modify the header
                    header_base = os.path.splitext(filename)[0][:-3]
                    record.id = f"{header_base}_{suffix}"
                    record.description = ""
                    # Write the modified record to the output file
                    with open(output_file_path, 'w') as outfile:
                        SeqIO.write(record, outfile, 'fasta')

                except StopIteration:
                    print(f"Skipping empty or invalid file: {input_file_path}")
                    continue

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Process FASTA files in a directory')
    parser.add_argument('-i', '--input_dir', required=True, help='Input directory containing FASTA files')
    parser.add_argument('-o', '--output_dir', required=True, help='Output directory for processed FASTA files')
    parser.add_argument('-p', '--suffix', required=True, help='Suffix to append to FASTA headers')

    args = parser.parse_args()

    process_fasta_files(args.input_dir, args.output_dir, args.suffix)
