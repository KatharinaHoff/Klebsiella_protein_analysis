#!/bin/bash

# Check if two arguments are given
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <genome_file> <protein_file>"
    exit 1
fi

# Assign the arguments to variables
genome_file="$1"
protein_file="$2"

# Derive the flat_genome filename by removing the path and .fna extension
flat_genome=$(basename "$genome_file" .fna)

# Path to the genome directory (adjust this path as needed)
genome_dir="../../../assemblies/genomes"

ass_acc=$(echo "$flat_genome" | cut -d"_" -f1,2)

# change into a new directory to avoid gth having conflicts
mkdir $ass_acc
cd $ass_acc
cp ../$protein_file .
cp ../$genome_dir/$genome_file .
# Execute your command, adjust paths and options as required
gth -genomic "$genome_file" -protein "$protein_file" -startcodon -finalstopcodon -skipalignmentout -gcmaxgapwidth 1 | awk '/PGS/ {
    match($0, /([[:alnum:]_\-]+)\+/, arr);
    query_name = arr[1];
}
/^>/ {
    if (query_name != "") {
        print $0 " " query_name;
    } else {
        print;
    }
    next;
}
{
    if ($0 ~ /^[[:space:]]*[0-9]+/) {
        $1="";
        gsub(/[[:space:]]/, "");
        print;
    }
}
' | awk '
BEGIN { capture = 0; }
/^>/ {
    print;
    capture = 1;
    next;
}
capture {print;}
'
cd ..

rm -rf $ass_acc
