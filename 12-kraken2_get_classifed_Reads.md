# Goal:

Extract the reads that kraken2 classified.

# Introduction:

At this point kraken2 has given you an idea of what may
  be in your sample. However, you still need to prove that
  the species you found is really in your sample. You also
  might like to get a genome out.

I can think of a few ways to approach this, though there
  are likely many more.

1. Pull out the reads kraken2 classified for each species
   and build an assembly/consensus from them
2. Map the reads to a reference genome of the species
   kraken2 found then build an assembly/consensus
3. Use a denovo assembler to build assemblies for the
   entire dataset
   - This can take a good amount of memory and time

For this episode we will talk about pulling out the reads
  using the kraken2 classification. In the next episode
  we will pull out reads by reference.

# Getting the programs:

The output file (`--output`) made by kraken2 has the reads
  and the taxon they were assigned to. You can use a tool
  like krakentools to extract the reads by there taxon
  ids. Krakentools can also pull out reads at higher
  taxonomic levels (ex: family) and merge them into a
  lower taxonomic level (ex: species). I have had a
  problem with krakentools not detecting my biopython
  install. I would recommend trying krakentools first.

- krakentools can be found at
  [github.com/jenniferlu717/KrakenTools](
    github.com/jenniferlu717/KrakenTools)

For this part of the tutorial I will focus on two other
  tools. I know that you can install them. Otherwise I
  would focus on krakentools.

Normally I would recommend that you read the README file
  to figure out how to install a tool. However, in this
  case I will provide the commands.

```
cd ~/Downloads;
git clone https://github.com/jeremyButtler/bioTools;

cd ~/Downloads/bioTools/k2TaxaIdSrc;
make -f mkfile.unix;    # build the k2TaxaId program
chmod a+x k2TaxaId;     # give execute permission
mv k2TaxaId ~/Downloads;#move k2TaxaIf to downloads

cd ../seqByIdSrc;
make -f mkfile.unix;    # build the seqById program
chmod a+x seqById;      # give execute permision
mv seqById ~/Downloads; # move seqById to downloads
```

I am not having you install these tools because I do not
  want to add a bunch of tools you might not need to your
  system. You can move the tools around. To make
  things simple for now I will keep them in downloads.

To call a with tools `~/Downloads/<tool>` (assuming the
  tool is in Downloads).

# Getting the reads:

Before getting any of the read ids, make sure to record
  the version number of the programs you plan to use. In
  this case the version numbers are for the repository I
  used, so I grouped k2TaxaId and seqById together.

The version number part of my notebook looks like this:

```
# Programs

- fastq-dump version 3.0.3
- kraken2 2.1.6
- pavian web page for sankey plots
  - [https://fbreitwieser.shinyapps.io/pavian/](
     https://fbreitwieser.shinyapps.io/pavian/)
- Programs from bioTools version 2026-02-27:
  - k2TaxaId
  - seqById
```

## Getting read ids:

The k2TaxaId program will extract the read ids for taxons
  that have more then 10 reads. It will go with the most
  specific level (ex: species over family). k2TaxaId will
  also merge higher level orders into the lower levels
  (ex: family into species). The default will put reads
  in genus bins or family bins (species reads mereged in).

Get the help message for k2TaxaId and figure out how to
  use it (hint `-id` is for the `--output` file from
  kraken2). Then run k2TaxaId on the plusPF and viral
  database kraken2 results.

If you want to get the number of lines (classified reads)
  for a file use `wc -l <filename>.ids`. To get the number
  of lines for all files do `wc -l *.ids` (the `*` means
  anything).

For k2TaxaId I provided the read ids (`kraken2 --output`)
  with `-id <kraken2_output_file>`. I also provided the
  report with `-report <kraken2_report_file>`. Finally,
  I wanted to avoid the default output name, so I used
  `-prefix <good_output_name>`.

My command looked something like

```
~/Downloads/k2TaxaId \
   -report <kraken2_report_file> \
   -id <kraken2_output_file> \
   -prefix <good_prefix>;
```

I added this entry to my nodes:

```
# 03 k2 reads

I wanted to get the reads kraken2 assigned to each taxon.
  I used k2TaxaId to get the read ids per taxon. I then
  used seqById to get the reads for each taxon using the
  read ids.

## Get taxon read ids

First I extracted the read ids for each taxon.

<start_code_block>
mkdir 03-k2-reads;

k2TaxaId \
    -report "02-k2/02-zymo-k2plusPF16-report.txt" \
    -id "02-k2/02-zymo-k2plusPF16-ids.tsv" \
    -prefix "03-k2-reads/03-zymo-k2plusPF16-k2Taxa";

k2TaxaId \
    -report "02-k2/02-zymo-k2viral-report.txt" \
    -id "02-k2/02-zymo-k2viral-ids.tsv" \
    -prefix "03-k2-reads/03-zymo-k2viral-k2Taxa";
<end_code_block>
```

## Getting reads by read ids:

You can get reads from a fastq file by using read ids with
  seqById. A better, more versatile tool would be
  `seqkit grep`. However, k2TaxaId outputs the taxon id
  with the read id, which might cause problems for
  `seqkit`.

Get the help message for seqById and pull the reads for
  at least one viral file and one bacterial file.

Here is the code I used to extract the reads.

After that I used seqById to extract the reads using the
  ids. I used the `-fq <file>.fastq` to provide the
  uncompressed fastq file. I used
  `-id <k2TaxaId_prefix>.ids` to input the read id files.
  Finally, I used the `-out <good_name>.fastq` to provided
  the file name to save the reads to.

```
seqById \
    -fq <file.fastq> \
    -id <k2TaxaId_prefix>.ids \
    -out <good_name>.fastq;
```

If you are using gzip compressed (`.gz`) fastq files then
  you can uncompress them using
  `cat <file>.fastq.gz | gunzip -c`. The `|` passes the
  output of cat (merges files) to gunzip. The `-c` in
  gunzip tells gunzip it is taking input from stdin
  (another program).

**Dealing with a fastq.gz file**

```
cat <file>.fastq.gz |
  gunzip -c |
  seqById \
    -fq <file.fastq> \
    -id <k2TaxaId_prefix>.ids \
    -out <good_name>.fastq;
```

I used a loop (will get into later) to extract all the
  read ids for me. I added this entry to my note book:

```
## Get taxon reads

I then used the read ids to extract the reads.

<start_code_block>
# This loop will pass each output file from k2TaxaId to
#   seqById.
for strReadId in ./"03-k2-reads/"*.ids;
do
   # check for the null case (no files)
   if [ ! -f "$strReadId" ]; # -f checks if I have a file
   then
      continue; # move to the next file
   fi;

   outNameStr="$(basename "$strReadId" | sed 's/.ids//')";
      # basename gets the file name stored in strReadId
      # sed replaces patterns in strings
      #     s/.ids// removes the .ids at the end of the

   # extract the reads
   seqById \
       -fq 01-input/01-SRR28476579.fastq \
       -id "$strReadId" \
       -out "03-k2-reads/$outNameStr-seqById.fq";
done; # end the loop
<end_code_block>
```

# Final thoughts:

The method I showed is one way of getting read ids.
  However, with this method we are trusting the kraken2
  made accurate assignments. Or at least accurate enough
  were each bin has a single species and is not mixed. We
  are also missing any unclassified reads that may have
  not had the correct minimizers.

Even still, we can use these reads to build a consensus,
  which we can then blast to see if we are correct.

In the next episode I will cover another way of getting
  the reads out (mapping to a set of references). Then I
  will talk about assemblies.

You can see my current notebook in the
  12-gettingReadsFromKraken2-notebook.md file.
