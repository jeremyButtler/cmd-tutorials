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
- flye 2.9.6-b1802
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

# 05 flye pull reads with kraken2

I am making denovo assemblies for all the yanked reads
  with read depths over 1000 with flye. This differs
  a little from the tutorial because I am not ready to
  introduce loops in the tutorial.

This code is more commented then I normal would do. I
  often will not explain may commands in this level of
  detail.

```
if [ ! -d "05-flye-k2Pull" ];
then
    mkdir 05-flye-k2Pull;
fi;

# this allows me to build an assembly for all fastq files
#  in the 03 directory
for strFq in ./"03-k2-reads/"*.fq;
do # Loop: build assemblies
    if [ ! -f "$strFq" ]; # if not a file
    then
       continue; # move to the next file
    fi;

   # get the file prefix
   nameStr="$( \
       basename "$strFq" | sed 's/\.fq//; s/03/05/;' \
   )"; # the "$()" allows me to run a command and store
       #   the result in a variable
       # basename <file_path> gets the file name
       # I am using sed to remove the .fq ending and
       #   replace the 03 at the start with an 05. I
       #   use the number to keep track of which folder
       #   the folder belongs

    if [ -f "$nameStr/assembly.fasta" ];
    then
      continue; # the assembly has already been made
    fi;
     
    numReadsSI="$( \
        wc -l "$strFq" | awk '{print $1 / 4;};' \
    )"; # the "$()" allows me to run a command and store
        # the result in a variable
        #   - a "\" breaks a command into multiple lines
        #   - wc -l <file> gets the number of lines in a
        #     file. The output is
        #     "<number_lines> <file_name>"
        #   - awk '{print $1 / 4;};" prints the first
        #     column divided by 4
        #     - columns are separated by spaces or tabs
   if [ "$numReadsSI" -lt 1000 ]; #if less then 1000 reads
   then
      # let the user know we are skiping this file
      printf "\n%s had to few reads\n" "$strFq";

      # save that we skipped this file to the log
      printf "\n%s had to few reads\n" "$strFq" \
         >> "05-flye-k2Pull/05-0log.txt";
         # the >> appends to a file instead of overwriting
         # %s in printf means print a string from a
         #   variable. In our case it is strFq
         # \n means a new line
      continue; # move to the next file
   fi;

   
   # let user and log know the file we are building an
   #   assembly for
   printf "building an assembly for %s\n" "$strFq";
   printf "\nbuilding an assembly for %s\n" "$strFq" \
      >> "05-flye-k2Pull/05-0log.txt";

   # I am using gnu time (for Linux is in /usr/bin) to
   #    get the elapsed time (%e) the memory usage in
   #    kilobytes (%M) and the cpu usage (%P).
   #    the "\t" means a tab
   #    -f means the format to output, you can put any
   #      string in here
   #    -a means append to a file instead of overwriting
   #    -o is the file to write the stats to
   # This is not needed, but I put it here so I could
   #    get and idea of how much memory your computer
   #    needs
   # For cpu usage one thread is 100%, 3 threads is 300%
   /usr/bin/time \
        -f "\ttime=%e\tmemKb=%M\tcpuPerc=%P" \
        -a \
        -o "05-flye-k2Pull/05-0log.txt" \
     flye \
       --meta \
       --nano-raw "$strFq" \
       --threads 8 \
       --out-dir "05-flye-k2Pull/$nameStr-flye";
      # I am increasing the threads to 8 because I do not
      #   want this to take all day

   # I want to extract some stats from the end of the flye
   #   log and stick them in my own log
   sed -n '/Total length:/,/Mean coverage/p;' \
      "05-flye-k2Pull/$nameStr-flye/flye.log" \
      >> "05-flye-k2Pull/05-0log.txt";
     # for sed -n means only print what I tell you to
     # /<pattern/p; means print (p) this line if you find
     #    this pattern
     # /<pattern_1/,/<pattern_2>/p; means print all lines
     #   between pattern_1 and pattern_2
     # I can also substitute on lines with a pattern by
     #   doing
     #   /<pattern_1>/s/<sub_pattern/<replace_pattern>/;
     # Or I can limit my sed command to a lines 1 to 10
     #   using 1,10s/<sub_pattern>/<replace_pattern>/;
done # Loop: build assemblies
```

# 06 flye binned reads by ref

I am making denovo assemblies for all the reads binned
  using the references from kraken2. My min number of
  reads to make an assembly is 1000 reads.

```
if [ ! -d "06-flye-refBin" ];
then
    mkdir 06-flye-refBin;
fi;

for strFq in ./"04-k2-readsByRef/"*.fq;
do # Loop: build assemblies
    if [ ! -f "$strFq" ]; # if not a file
    then
       continue; # move to the next file
    fi;

    nameStr="$( \
        basename "$strFq" | sed 's/\.fq//; s/03/06/;' \
    )";

    if [ -f "$nameStr/assembly.fasta" ];
    then
      continue; # the assembly has already been made
    fi;
     
    numReadsSI="$( \
        wc -l "$strFq" | awk '{print $1 / 4;};' \
    )";

   if [ "$numReadsSI" -lt 1000 ];
   then
      printf "\n%s had to few reads\n" "$strFq";
      printf "\n%s had to few reads\n" "$strFq" \
         >> "06-flye-refBin/06-06log.txt";
      continue; # move to the next file
   fi;

   
   printf "building an assembly for %s\n" "$strFq";
   printf "\nbuilding an assembly for %s\n" "$strFq" \
      >> "06-flye-refBin/06-06log.txt";

   /usr/bin/time \
        -f "\ttime=%e\tmemKb=%M\tcpuPerc=%P" \
        -a \
        -o "06-flye-refBin/06-06log.txt" \
     flye \
       --meta \
       --nano-raw "$strFq" \
       --threads 8 \
       --out-dir "06-flye-refBin/$nameStr-flye";

   sed -n '/Total length:/,/Mean coverage/p;' \
      "06-flye-refBin/$nameStr-flye/flye.log" \
      >> "06-flye-refBin/06-06log.txt";
done # Loop: build assemblies
```
