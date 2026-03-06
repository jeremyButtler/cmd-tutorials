# Goal:

Give a very basic overview of how denovo and reference
  based assemblies work. Talk about some of their
  strengths and weaknesses.

Be warned, I am not very strong in this area, so I may
  have some things wrong. I also may miss important
  points.

# Introduction:

At this point we have take a fastq file of unknown reads
  and with kraken2 have split them into bins of reads. In
  our case each bin represents a single Genus (one
  reference). However, these reads can not tell us much on
  their own. We need to take further steps to find convert
  this group of reads into something we can understand.

Most of the reads in our bins are likely (we hope) from
  the same species and are likely from clones. This means
  that they will have the same genome (or very few
  differences). To make things more difficult, Nanopore
  sequencing has an error rate. So, we can not trust a
  single read alone. However, using these two facts we
  can convert a group of reads into a consensus.

A consensus sequence is were all reads are merged into one
  sequence. For positions in the consensus with
  disagreements, the most common base for the position is
  kept.

Example of building a consensus:

```
Read_1   : atCggagA
Read_2   : Gtgggagt
Read_3   : atgggCgt
    |
    |  Build consensus
    v
Consensus: atgggagT
           ^ ^    ^
           | |    T is more common then A
           | G is more common then C
           A is more common then G
```

Another way of detecting differences is to find the
  variants (what is different from the reference). These
  variants are then saved in a variant calling file (vcf).
  Unlike a consensus, a vcf file can store multiple
  variants for a single position. Also, a vcf file can be
  converted to a consensus by filling in the missing
  positions with reference bases. This ease makes vcf
  files a common step in building a consensus.

The only cons I see with vcf files is that they require a
  reference and they are often filtered to remove low
  quality variants. This means these low quality variants
  will be replaced later with reference bases later on.
  This means a vcf file may make the consensus look more
  like a reference (pull the consensus) then it really is.

I have not worked much with vcf files, so I have no
  examples. My methods often use my own file formats that
  include both variants and matches to the reference.

An assembly is a method that merges reads together (makes
  a contig) to get a genome (or larger fragment of a
  genome). These contigs are often converted into a
  consensus.

For our project our next step is to take our bins of
  reads and make an assembly. I can think of two ways to do
  this.

1. Denovo assembly: the reads are joined together by
   patterns in overlapping bases
   - The minimum overlap is often at least a 1000 bases
2. Reference based assemblies: the reads are mapped to a
   reference and the alignment is used to build a
   consensus sequence


## Denovo assembly

A denovo assembly is a method that uses overlaps between
  reads to merge reads together. This means a denovo
  assembly does not need a reference.

```
read_1: atgcagtggcaa
read_2:      tggcaatcaggcatatg
read_3:                 catatgatcgactacctaa
read_4: atccgaccaccccccc (no overlaps)
   |
   | assemble the overlaps
   v
contig: atgcagtggcaatcaggcatatgatcgactacctaa
read_4: atccgaccaccccccc (no overlaps)
```

- Here are some strengths I find for denovo assemblies (I
  am likely missing many others):
  1. Detecting large variants (large insertions or
     deletions)
     - Reference based methods would often remove these
     - This is also an error you can expect from denovo
       assemblies, so you need a way to verify these large
       variants
  2. No reference pull
     - There is not reference to pull the assembly, so
       every mutation is real, a read error, or a
       miss-assembly
  3. Assembling a novel genome (no reference sequence
     exists)
     - Another case would be when there is no close
       reference sequence. This is a case were reference
       based methods will have problems.
  4. Many denovo assemblers can handle metagenomic data
     (multiple species in one sample)
     - For example, we could have used a denovo assembler
       on our dataset instead of kraken2
     - More species means more time and memory costs

- Here are some problems I can think of for denovo
  assemblies
  1. Denovo assemblers can make miss-assemblies
     - Part of another species genome inserted in
       - Less common as species become more distant
     - Terminal repeats, duplicated repeats, or very
       similar genes (ex duplicated) can merged or removed
  2. They can invert genes (another miss-assembly)
  3. Memory usage is higher for denovo assemblies
  4. Denovo assemblies take more time
  5. If the overlaps are to small, then you can not build
     an assembly
     - I think the minimum overlap is typically 1000
       bases
     - Often the minimum overlap to larger for tiling
       primer methods

I have a hard time figuring out when and when not to use
  a denovo assembly. I think if your genome is close to
  existing reference genomes, then a reference based
  assembly will mean less errors to clean up. However, for
  reference based assemblies a bad reference choice means
  a bad assembly.

## Reference based assemblies

Reference based assemblies require that reads be first
  mapped (aligned) to a reference. The mapped reads are
  used to builld a consensus.

Reference bases assembly example:

```
Reference: atgggagattcagttgcag
Read_1   : atCggagT
Read_2   : GtgggagT
Read_3   : atgggCgT
Read_4   :    ggagGttcag
Read_5   :              ttgcag
    |
    |  Build consensus
    v
Consensus: atgggagTttcagttgcag
```

Here is my list of pros and cons. This is what I can think
  of. However, there are likely more.

- Here are some pros:
  1. The mapping step will often remove reads from other
     species (except really close species)
     - Reduces or removes miss-assemblies
  2. Ram and memory usage is generally lower
  3. Deals with terminal repeats better
     - Unless they are the exact same, you will generally 
       have a better score for one end or the other

- Here are some cons:
  1. Read mapping can remove large variants
     - large insertions or deletions can lower mapping
       scores, so they may be lost in the mapping step
     - sometimes the reads with large variants are lost
  2. Reference based assemblies can pull the consensus
     towards the reference
     - Insertions or deletions without enough support are
       removed (always pulls)
     - SNPs that have mixed support may be replaced with
       an anonymous base or the reference base
       - If you used the reference base, you would pull
         the assembly towards the reference
       - An anonymous base represents two or more bases
         (ex: N is a A, T, G, or C)
  3. Does not work on novel genomes
  4. The choice of the reference you use can change how
     accurate your final output is
     - make sure you start with a reference that is close
     - I have made this mistake and it was painful
  5. Does not handle metagenomic samples well

From my experience (very limited) reference based
  assemblies should only be used if you know your reads
  are close to the reference. This is difficult to test
  for.

## Polishing

Another option many people will do is to start of with a
  denovo assembly. Then use the contigs (denovo assembly
  consensuses)  as a reference for a reference based
  assembly. This is known as polishing (remove errors). If
  you use the right programs this can improve accuracy.

This method does not deal with miss-assemblies, but may
  reduce the errors.

# Final thoughts

At this point you should have a very general idea how
  assemblies work. However, this is not an in depth
  comparison (I know to little to give one). Also, the
  algorithms for assemblies can be complex and often go
  over my head. Especially the denovo assemblies.
