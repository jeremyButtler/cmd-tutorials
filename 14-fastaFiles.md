# Goal:

Learn what a fasta file is.

# A fasta file

A fasta file is like a fastq file, but it does not include
  the quality scores. A fasta is used to store sequences.
  For example: genomes and sequences from Genbank.

Unlike a fastq file, a fasta file can have blank lines.
  Each sequence starts with a one line header, which is
  marked with a `>` symbol. There should be no space
  between the `>` and the sequence name. You should avoid
  the space because some programs stop reading in the
  header after the first space or tab. After the name
  you can add a space and add the rest of the meta data.


An example of a header:

`>name length=100 some extra meta data`

After the header comes the sequence. The sequence ends at
  the next header line. This allows the sequence to be
  multiple lines long.

Valid characters for a fasta file are the nucleotides
  (A, T, G, and C), gaps (`-`), and anonymous bases. For
  amino acids, the amino acid letters and gaps are
  allowed.

An example of a fasta file:

```
>name length=100 some extra meta data
ATGCCGACT
GGCAGACTA
TAA

>next_genome
ATTGCAA
ATTGCAA
```
