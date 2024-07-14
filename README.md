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

## Protein Alignment
