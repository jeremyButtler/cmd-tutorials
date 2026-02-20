# Goal:

Learn how to download fastq files from the SRA and get an
  initial dataset to work with.

# Introduction:

Most of the time I work on data that people send to me.
  Often times this data has been sequenced in the lab I
  am in. However, for benchmarking (comparing programs), I
  do not have datasets. My solutions in these rare cases
  are to go to the SRA (sequence read archive).

You can download fastq files (has reads) from the SRA
  using your web browser. However, my past experience is
  that the that the quality scores are often one value.
  The quality scores measure the probability that each
  base was called correctly (think error rate).
  The only way I have found to get the correct error rates
  (quality scores) is to download the data using the
  command line.

# Downloading data:

In the sra-toolkit program I had you download there are
  two tools, `prefetch` and `fastq-dump`. `prefetch` will
  download data off the SRA, but not in fastq format. To
  get the data to a fastq file you must use `fastq-dump`.

You can skip the `prefetch` step and use `fastq-dump` do
  download a dataset. In this case `fastq-dump` will
  store he downloaded files from `pre-fetch` in `/tmp`.
  `fastq-dump` will then convert the downloaded files to
  fastq files at your target location. This can be a
  problem if you are downloading a large dataset on a
  system that has `/tmp` on a separate partition. Since,
  most systems use only only partition, we will skip
  using `prefetch`.

The first step is to get the help message for
  `fastq-dump`. It will be similar to less or the other
  command line programs. See if you can get it and can
  figure out how to use `fastq-dump`. The accession number
  I am using for this tutorial is SRR28476579.

When finished or when you hit a brick wall (try at least
  30 seconds to a minute) you can move on to me
  downloading the data.

Help messages can often be got using `-h`, `--h`,
  or `--help`. I can view the `fastq-dump` help message
  by doing `fastq-dump --help`. However, rather then view
  the help message in my terminal I will view it in `less`
  by using `fastq-dump --help | less`. The pipe (`|`)
  passes the output from one command to the input of the
  next command.

Most programs come with a help message. The format depends
  on the programmer. The first line often is the usage
  line. The usage line tells you how to use the program
  and may provide a description.

- Things between `[]`'s are optional inputs
- Things between `<>` is a value you input
- `...` means you can provide multiple items
  -  For `fastq-dump` the `[<path>...]` means you can do
     multiple `prefetch` downloads at once

For `fastq-dump`'s help message we have two usage lines.

```
Usage:
  fastq-dump [options] <path> [<path>...]
  fastq-dump [options] <accession>
```

  The first shows how to user `fastq-dump` if you used
  prefetch first. The second shows how to use
  `fastq-dump` to download the fastq files for an
  accession number.

The lines beneath the usage lines shows options you can
  use when downloading data from the SRA. Each option
  includes a description to the side. In this case a `|`
  symbol is used to separate multiple ways of providing
  the same option

In this case The `<value>` is a value you must provided
  with the option. The `<[value]>` is an option you can
  provided with the option.

```
INPUT
  -A|--accession <accession>  Replaces accession
                              derived from <path> in 
                              filename(s) and deflines
                              (only for single table dump) 
  --table <table-name>        Table name within cSRA
                              object, default is 
and more lines come after
```

In our case I am not using the additional options. So, I
  will use `fastq-dump SRR28476579` to download the fastq
  files. The download will take a bit. After the download
  I will move the files into my input folder with `mv`.

Before running `fastq-dump` remember to put the version
  in your notes and the command that you used. You can
  get the version with `--version`.

In this case my notebook looks like


```
# Goal:

Show new command line users how to run kraken2, flye
  and other bioinformatic tools.

# Programs

- fastq-dump version 3.0.3

# 01 input

Download the ASFV data set from the SRA the new
  users will use to learn flye and kraken2.

<code block start>
fastq-dump SRR28476579;
mv SRR28476579.fastq 01-input/01-SRR28476579.fastq;
<code block end>
```

# Final comments

At this point you have a metagenomic dataset that we can
  use in our next tutorials. In the next episode I will
  go over multiplexers to make life a little easier. After
  that I will talk about data analysis. Then I will move
  into using kraken2 and flye.
