# Goal:

Learn how to download and extract databases for kraken2.

# Introduction

In the last episode we gave a general (not accurate) idea
  of how kraken2 works. In this episode we will talk about
  how to get a database for kraken2. One thing we are not
  doing is making a database. I do not know how to do
  that. Instead I will be downloading a database from the
  web and extracting it.

# Getting kraken2 databases

Kraken2 uses a database of patterns (compact hash
  minimizers) to match reads to references. These
  databases can be very large (over 100Gb). So, kraken2
  does not come with any databases. You must download a
  database your self.

## Downloading databases

We will need some databases to run kraken2. In episode
  05 we downloaded data for the zymo mock community, which
  is a bacterial community. So, we will want a database
  with bacteria. Kraken2 will load the database into your
  ram (memory), so get the 8Gb versions. I am going to
  use the plusPF8 database.

I also want to show the problem of using the wrong
  database with kraken2. So, download the viral database
  as well (it is less then 1Gb).

You can find kraken2 databases at:

[https://github.com/BenLangmead/aws-indexes/blob/master/docs/k2.md](
 https://github.com/BenLangmead/aws-indexes/blob/master/docs/k2.md
)

## Uncompressing the databases

The downloaded databases will be gz compressed (.gz). The
  tar (.tar.gz) means that the compressed file has
  multiple files. So, when uncompressed you will end up
  with multiple files. To make sure we keep all the files
  together lets make a directory to store the database.
  Then move into the new directory.

You will want a separate directory for each database.

To uncompress the file you can use the `tar` command. The
  `tar` help message is overwhelming. So, instead of
  reading through everything see if you can figure out
  how to use `tar` to uncompress from the `Examples`
  section. The only extra thing you will need to add to
  the command is a `-z` or `--gzip` to have tar first
  uncompress the file.

I would recommend you view the `tar` help message with
  `less` (`tar --help | less`). This will start you out
  at the top were the examples are.

Once you have given up (try for at least a few minutes)
  you can  move on to were I uncompress the archive. For
  this example I will uncompress the viral database only.

```
Examples:
  tar -cf archive.tar foo bar  # Create archive.tar from
                               # files foo and bar.
  tar -tvf archive.tar         # List all files in
                               # archive.tar verbosely.
  tar -xf archive.tar          # Extract all files from
                               # archive.tar.

```
From the tar help message examples I can see that to
  extract files from a tar archive I can do
  `tar -xf <archive>`. However, this does not work on
  a `tar.gz` file because I still need to deal with
  the `gz` compression. However, I can use `-z` or
  `--gzip` to have tar uncompress the tar archive first.
  So, the new command looks like
  `tar -z -x -f <archive>.tar.gz`.

Here is the command I used for the viral database.

```
cd ~/Downloads;
mkdir k2_databases;
mkdir k2_databases/k2_viral;
cd k2_databases/k2_viral;
tar -x --gzip -f ~/Downloads/k2_viral_20251015.tar.gz
```

At this point you are ready to use the viral database. All
  you need is a set of fastq files.

# Final words

At this point you should have at least one fastq file and
  a kraken2 database to classify reads with. In the next
  episode we will classify reads with kraken2.
