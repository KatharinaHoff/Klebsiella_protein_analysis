# Analysis of immogenic proteins in *Klebsiella pneumoniae*

Katharina J. Hoff, University of Greifswald, katharina.hoff@uni-greifswald.de

A joint project with Lisa Zierke and Prof. Dr. Sven Hammerschmidt at University of Greifswald

## Genome Assemblies

I downloaded the ncbi_dataset.tsv for genome assemblies for *K. pneumoniae* from NCBI on February 16th 2024. If both a RefSeq and a GenBank assembly was listed, the GenBank assembly was removed:

```
cat ncbi_dataset.tsv | perl -ane '$k = $F[0]; $k =~ s/^(..)./$1X/; if (!exists $seen{$k} || $F[0] =~ /N/){$seen{$k} = $_} END{print values %seen}' > nonredundant.tsv
```

Incomplete assemblies below a completeness threshold of 95% were filtered out:

```
perl -F'\t' -ane 'print if $F[-1] > 95' nonredundant.tsv > complete.tsv
```

To estimate whether we could use an existing and consistent annotation, we counted how many of the assemblies were annotated with the PGAP pipeline:

```
grep -c PGAP complete.tsv
```

This returned only 10763 of 18689 assemblies. We therefore decided not to rely on the PGAP assembly.

A total of 18689 assemblies were downloaded from NCBI. All but 20 were downloaded by FTP-link retrieval with wget using https://github.com/KatharinaHoff/Klebsiella_protein_analysis/blob/main/scripts/download_ass.sh . The missing 20 assemblies were manually downloaded because we could not identify a valid FTP link.

## Protein Identification

The query proteins are contained in file https://github.com/KatharinaHoff/Klebsiella_protein_analysis/blob/main/data/proteins/query.fa

We used GenomeThreader [1] to identify candidate proteins for each query in each genome assembly. This approach is not optimal since we had to manually curate the output in some cases, but it ensures the prediction of a complete gene with start and stop codon.

```
while IFS= read -r genome_file; do
    # Derive the flat_genome filename by removing the path and .fna extension
    flat_genome=$(basename "$genome_file" .fna)
    ass_acc=$(echo "$flat_genome" | cut -d"_" -f1,2)      
    gth2aa.sh "$genome_file" test.fa > "${ass_acc}.aa"
    num_entries=$(grep -c "^>" "${ass_acc}.aa")
    if [ "$num_entries" -eq 0 ]; then
        echo "Warning: gene not found in ${genome_file} (${ass_acc})"
    elif [ "$num_entries" -gt 1 ]; then
        echo "Warning: gene found more than once in ${genome_file} (${ass_acc})"
    fi
done < ../genomes.txt
```

We manually removed (rare) duplicates and some format errors that were introduced by gth2aa.sh in rare cases.

We renamed the found proteins to contain assembly and query name with rename_fasta_entries.py:

```
rename_fasta_entries.py -i aa/ -o aa2/ -p ${queryname}
```

Proteins shorter than 80% of the respective query length were discarded:

```
cat aa2/* > all.aa
filter_fasta.py -f all.aa -r query.fa > all.f.aa
```

## Protein Alignment

Protein Multiple Sequence Alignments were generated with learnMSA [2] as follows:

```
input_file=$(sed -n "${SLURM_ARRAY_TASK_ID}p" input_files.txt)
learnMSA -i "${input_file}" -o "${input_file%.*}.out"
```

## References

[1] Gremme, G. (2012). Computational gene structure prediction (Doctoral dissertation, Staats-und Universitätsbibliothek Hamburg Carl von Ossietzky).

[2] Becker, F., & Stanke, M. (2022). learnMSA: learning and aligning large protein families. GigaScience, 11, giac104.
