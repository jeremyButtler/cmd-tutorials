# Goal:

Learn how to use kraken2 and pavian to explore a dataset
  for microbes.

# Introduction

At this piont we have a fastq file from the zymo mock
  community and two databases to classify reads with. We
  have the viral database and the plusPF8 database. We are
  know ready to classify reads with kraken2.

You likely already have kraken2 installed. If you have
  not installed kraken2 then take some time to install
  kraken2 (see episode 02-install).

Before running kraken2 I I should point out that I am not
  an expert. So, take what I say with a grain of salt.

# Using kraken2

For kraken2 we need at least two output files. We will
  want the report, which has the read counts for each
  taxonomy. We will also want the output, which has the
  taxon each read id was assigned to.

Take some time to view the kraken2 help message to see if
  you can run kraken2. Do not worry about memory mapping,
  compression (our reads are uncompressed), or paired
  reads (our reads are not paired).

For the database you provide the path to the directory
  you made for your database. For my viral database it
  would be `~/Downloads/k2_databases/k2_viral`.

At least take a minute before moving on in the tutorial.

For the usage line of the kraken2 help message we get
  `Usage: kraken2 [options] <filename(s)>`. This means
  I add the fastq file or files to the end of the kraken2
  command.

From the Options section I can find the flag to provide
 the database (`--db NAME     Name for Kraken 2 DB`). So,
  for my viral database I can do
  `--db ~/Downloads/k2_databases/k2_viral`.

From the options I can get the flag to output a report
  file  (`--report FILENAME    Print a report with ...`).
  So, I can get the report
  using `--report <report_name>.txt`.

There are two ways to To save the output read reports to a
  file. I know that output file is printed to the
  terminal (stdout). So, I can use the `>` to redirect
  stdout output to a file (this overwrites any old file).
  For example, I can do ` > <output_file.tsv`. Kraken2
  also has a flag to do this as well
  (`--output <file_name>.tsv`).

In my examples beneath the lines to run kraken2 became
  very long. However, on command line I can use multiple
  lines by adding a `\` to the end of a line.

So, my command becomes:

```
kraken2 \
    --db ~/Downloads/k2_databases/k2_viral \
    --report 02-zymo-report.txt \
    SRR28476579.fastq \
  > 02-zymo-ids.tsv;
```

Before running this command I should add it to my
  notebook. I should also add the version number of
  kraken2 into my notebook as well (`kraken2 --version`).

At this point the programs entry in my notebook looks
  like:

```
# Programs

- fastq-dump version 3.0.3
- kraken2 2.1.6
```

I also have added in a entry for the kraken2 output. This
  is the first step, so it starts at 2.

```
# 02 kraken2

See what microbes I have in my community using kraken2.
  I first checked for potential viruses using the viral
  database.

<code block starts>
mkdir 02-k2;

kraken2 \
    --db ~/Downloads/k2_databases/k2_viral \
    --report 02-k2/02-zymo-k2viral-report.txt \
    01-input/01-SRR28476579.fastq \
  > 02-k2/02-zymo-k2viral-ids.tsv;
<code block ends>

I also wanted to check for the bacterial species that may
  be in my database.

<code block starts>
kraken2 \
    --db ~/Downloads/k2_databases/k2_plusPF8 \
    --report 02-k2/02-zymo-k2plusPF8-report.txt \
    01-input/01-SRR28476579.fastq \
  > 02-k2/02-zymo-k2plusPF8-ids.tsv;
<code block ends>
```

# Some additional kraken2 flags

We used kraken2 on default settings, which is how I often
  use kraken2. However, there are some additional flags
  that we may or may not find useful.

`--memory-mapping` prevents the database from being
  loaded into ram. This is good when you want to use a
  database that is larger then the amount of ram you have.
  One example were you would use this flag would be the
  100Gb or 500Gb databases.

`--gzip-compressed` is used if all your fastq files are
  gziped compressed (`.fastq.gz` and `.fq.gz`)
  - Based on this flag I do not think you can mix and
    match uncompressed and compressed fastq files

I am not sure on the `--confidence` setting. But, it will
  also require stricture calls for reads. I am guessing
  this is a measure of how many other species/families/...
  this read could be assigned to. Values are 0 (0%) to
  1 (100%).

I known `--minimum-base-quality` will ignore bases with
  low q-scores (see episode 08-fastqFiles.md). I am
  guessing this will ignore kmers that have bases with low
  quality scores.

`--minimum-hit-groups` not fully sure on this one, but
  here is my guess.

When you use kmers you are not jumping k bases for each
  kmer. For example, in a 35mer I am not moving 35 bases
  the reach the next 35mer. Instead you one base at a
  time. So, in a 35mer, a single base (after the first
  34) will be present in 35 35mers. The code block beneath
  has an example for a 3mer.

```
atgcc...
atg        <-- frist 3mer
 tgc       <-- second 3mer
  gcc      <-- third 3mer
   cc.     <-- fourth 3mer
    c..    <-- fifth 3mer
     ...   <-- remaining 3mers in the genome
```

I think `--minimum-hit-groups 2` is saying the 31mer
  minimizer is present and the minimizer in at least two
  of the overlapping 35mers. A 31mer is four bases off a
  35mer, so it is at most repeated in four 35mers. This
  means the maximum value is likely four.

# Pavian to visualize kraken2

At this point we still need to visualize the output from
  kraken2. We have a few options. We could view the report
  file made from kraken2. It is possible, but is not the
  most visual form.

Another option is to make a krona graph. I never got into
  these graphs, so I will not cover them here. If you
  want to try building a krona graph see
  [https://bioinf.cc/misc/2022/02/21/krona-metagenome.html](
   https://bioinf.cc/misc/2022/02/21/krona-metagenome.html).

Sadly I have not taken the time to figure out how to do
  my favored method by command line. This would be a
  sankey plot from pavien.

The github repo is here
  [https://github.com/fbreitwieser/pavian](
   https://github.com/fbreitwieser/pavian).

To access the web page to upload files go to
  [https://fbreitwieser.shinyapps.io/pavian/](
   https://fbreitwieser.shinyapps.io/pavian/).

For this tutorial I will use the webpage.

Upload the report file output by kraken2. Once uploaded
  go to the sample tab (in side menu). In the sankey plot
  the x-axis represents the taxonomic level. You can save
  the html file by clicking save network. You can also
  save the plot by taking a screen shot.

You can insert an image into a mark using
  the `![description](/path/to/image)`. The text between
  the `[]` is the figure caption. This is not loaded in
  github markdown, so you should always include something
  else. The file path to the image is between the `()`.

**viral results plot from pavian**

![Zymo mock community members kraken2 found using the
  viral database
](11-zymo-k2viral-pavian.png)

**bacterial results plot from pavian**

![Zymo mock community members kraken2 found using the
  viral database
](11-zymo-k2pluspf16-pavian.png)

# Final notes

You will notice from the pavian sankey plots the the
  bacterial database does not match the viral database.
  This does make some sense.

Another tool you can use to find the abundance of species
  in a sample is bracken (uses kraken2 output). I have
  never used bracken, so I do not have any advice here.

# My notebook at the end

To see my notebook at the end of this tutorial see the
  10-kraken-using-notebook.md file.
