#!/bin/bash

# Directory where you want to save the FASTA files
output_dir="./genomes"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through each assembly accession number in your list
while read -r assembly_acc; do
    echo "Downloading genome for assembly accession: $assembly_acc"
    # Fetch the FTP link for the assembly
    ftp_link=$(esearch -db assembly -query "$assembly_acc" < /dev/null | \
               efetch -format docsum | \
               xtract -pattern DocumentSummary -element FtpPath_GenBank)
    
    if [ -n "$ftp_link" ]; then
        # Construct the file name based on the FTP link
        file_name=$(basename "$ftp_link")
	outfile=${output_dir}/${file_name}_genomic.fna.gz
	echo "Potential output file is $outfile"
        if [ ! -f ${outfile} ]; then
	    echo "It does not exist yet"
            # Download the genomic FASTA file
	    echo 'wget -c "${ftp_link}/${file_name}_genomic.fna.gz" -O "${output_dir}/${file_name}_genomic.fna.gz"'
            wget -c "${ftp_link}/${file_name}_genomic.fna.gz" -O "${output_dir}/${file_name}_genomic.fna.gz"
	fi
        
        # Optionally, unzip the downloaded file
        # gunzip -f "${output_dir}/${file_name}_genomic.fna.gz"
    else
        echo "FTP link not found for $assembly_acc"
    fi
done < missing_acc.lst
