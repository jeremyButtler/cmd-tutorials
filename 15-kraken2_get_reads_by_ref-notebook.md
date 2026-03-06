# Goal:

Show new command line users how to run kraken2, flye
  and other bioinformatic tools.

This is how my note book looks after I finished the
  kraken2 tutorial (see 10-kraken2-using.md)

# Programs

- fastq-dump 3.0.3
- kraken2 2.1.6
- pavian web page for sankey plots
  - [https://fbreitwieser.shinyapps.io/pavian/](
     https://fbreitwieser.shinyapps.io/pavian/)
- minimap2 2.30-r1287
- Programs from bioTools version 2026-03-04:
  - k2TaxaId
  - seqById
  - binSam
- Custom scripts:
  - getRefsByTaxon.sh
    - download a Genbank reference for each taxon id

# 01 input

Download the ASFV data set from the SRA the new
  users will use to learn flye and kraken2.

```
fastq-dump SRR28476579;
mv SRR28476579.fastq 01-input/01-SRR28476579.fastq;
```

# 02 kraken2

## viral database

See what microbes I have in my community using kraken2.
  I first checked for potential viruses using the viral
  database.

```
if [ ! -d 02-k2 ]; # -d check if 02-k2 directory exists
then               # ! -d check if 02-k2 does not exist
   mkdir 02-k2;    # make the 02 directory this only fires
fi;                #   02-k2 does not exist

kraken2 \
    --db ~/Downloads/k2_databases/k2_viral \
    --report 02-k2/02-zymo-k2viral-report.txt \
    --output 02-k2/02-zymo-k2viral-ids.tsv \
    01-input/01-SRR28476579.fastq;
```

- For the viral database kraken2 reported:
  - 123223 sequences (334.94 Mbp)
  - classified 30158 sequences (24.47%)
  - unclassified 93065 sequences (75.53%)

## plusFP16 database

I also wanted to check for the bacterial species that may
  be in my database.

I am using the 16Gb database because it was on my
  computer. I know for the tutorial I told you to download
  the 8Gb database. The results should still be similar.

```
kraken2 \
    --db ~/files/k2-db/k2-pluspf16-20259714 \
    --report 02-k2/02-zymo-k2plusPF16-report.txt \
    01-input/01-SRR28476579.fastq \
  > 02-k2/02-zymo-k2plusPF16-ids.tsv;
```

- For the plusPF16 database kraken2 reported:
  - 123223 sequences (334.94 Mbp)
  - classified 118766 sequences (96.38%)
  - nclassified 4457 sequences (3.62%)

## graphs from pavian

After running kraken2 I made sankey plots with pavian

**viral database**

![Zymo mock community members kraken2 found using the
  viral database
](11-zymo-k2viral-pavian.png)

**plusPF16 database**

![Zymo mock community members kraken2 found using the
  plusPF16 database
](11-zymo-k2pluspf16-pavian.png)

## observations

It looks like kraken2 got different results depending on
  the databases. The plusPF database was able to bin most
  of the reads. While the viral database binned a quater
  of the reads. The difference in binning can not be
  explained by misses in one database. It is possible that
  the viral database is picking up sections of phage
  genomes that were inserted into the host.

# 03 k2 reads

I wanted to get the reads kraken2 assigned to each taxon.
  I used k2TaxaId to get the read ids per taxon. I then
  used seqById to get the reads for each taxon using the
  read ids.

## Get taxon read ids

First I extracted the read ids for each taxon.

```
# make my output directory
if [ ! -d "03-k2-reads" ];
then
   mkdir 03-k2-reads;
fi; # see section 02 for the explanation

k2TaxaId \
    -report "02-k2/02-zymo-k2plusPF16-report.txt" \
    -id "02-k2/02-zymo-k2plusPF16-ids.tsv" \
    -prefix "03-k2-reads/03-zymo-k2plusPF16-k2Taxa";

k2TaxaId \
    -report "02-k2/02-zymo-k2viral-report.txt" \
    -id "02-k2/02-zymo-k2viral-ids.tsv" \
    -prefix "03-k2-reads/03-zymo-k2viral-k2Taxa";
```

## Get taxon reads

I then used the read ids to extract the reads.

TODO: fix bug in k2TaxaId were Citrobacter is printed out
  with non-valid symbols.

```
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
```

# 04 kraken2 reads by reference

Normally I would only do one method of getting the reads.
  However, I want to keep a single set of notes for this
  tutorial series.

My goal here is to get the reads for each Genus kraken2
  found. I am using a set of downloaded references to
  extract all reads.

First I need to get the taxon ids and download the
  reference genomes.

```
if [ ! -d 04-k2-readsByRef ];
then
   mkdir 04-k2-readsByRef;
fi;

# get the taxon ids
find ./"03-k2-reads" -name *.ids |
  sed 's/.*\///; s/03-zymo-k2.*-k2Taxa-//; s/-.*//;' \
  > 04-k2-readsByRef/04-zymo-k2-k2TaxaId-taxon.ids;

# get the reference genomes
sh ~/Downloads/getRefsByTaxon.sh \
    -taxon 04-k2-readsByRef/04-zymo-k2-k2TaxaId-taxon.ids\
    -prefix 04-k2-readsByRef/04-zymo-k2;
```

Get the reads for each taxon.

```
# the -x map-ont is to use ONT settings. This is a default
#   setting, so it is not needed. However, it is still
#   a good habit
minimap2 \
    -a \
    -x map-ont \
    04-k2-readsByRef/04-zymo-k2-refs.fa.gz \
    01-input/01-SRR28476579.fastq |
  binSam \
    -sam - \
    -fq-out \
    -prefix 04-k2-readsByRef/04-zymo-k2-map;

  # I am skipping the filtering step because binSam will
  #  not bin unmapped reads. In the tutorial I used the
  #  sam tools step to show you how to filter reads
```
