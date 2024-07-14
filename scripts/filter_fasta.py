#!/usr/bin/env python3

import argparse
from Bio import SeqIO
import sys

def filter_fasta_by_length(fasta_file, length_threshold):
    with open(fasta_file, 'r') as file:
        for record in SeqIO.parse(file, 'fasta'):
            if len(record.seq) >= length_threshold:
                SeqIO.write(record, sys.stdout, 'fasta')

def compute_len(fasta_file):
    with open(fasta_file, 'r') as file:
        for record in SeqIO.parse(file, 'fasta'):
            return round(len(record.seq)*0.8,0)

                
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Filter FASTA sequences by length')
    parser.add_argument('-f', '--fasta', required=True, help='Input FASTA file')
    parser.add_argument('-r', '--reference', required=True, help='Reference sequence determined to compute length threshold')
    # parser.add_argument('-l', '--length', type=int, required=True, help='Length threshold')

    args = parser.parse_args()
    length = compute_len(args.reference)
    filter_fasta_by_length(args.fasta, length)
