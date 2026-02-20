# Goal:

Understand the fastq file format

# Introduction

In bioinformatics it is common to use human readable (text
  based) file formats. These files can be read and
  manipulated in text editors. Understanding how these
  file formats look can help you to check for errors,
  reformat the files, or manipulate the files.

## Fastq format

Fastq files hold the reads you sequenced. They have four
  entires. Each entry takes at least one line

1. The header; read id and meta data
   - Is only one line long
   - Starts with an `@` symbol followed by a read id
     (ex: `@read_id`)
   - A space or tab ends the read id (ex: `@read_id data)
   - After a space or tab comes meta data such as the
     basecaller model, read length, flow cell, or anything
     else. Separating each item of metadata by tabs or
     spaces is common.
2. The sequence
   - The sequence of the read, can have multiple lines
3. The spacer marks the end of the sequence
   - Starts with a `+`
   - There can be more then a `+`, however, doing this
     makes reading the fastq file more complicated. At the
     very least make sure you have a space or tab after
     the `+` (ex: `+ data`)
4. The quality scores for each base
   - The predicted percent error rate from the basecaller
   - Can be any visible character
   - Should have the same number of lines as the sequence

An example of a four line fastq entry:

```
@read_id length=12      <---- header
atgcccgattag            <---- sequence
+                       <---- spacer
07;8Aa--c:':            <---- quality scores for each base
```

An example of a six line fastq entry:

```
@read_id length=12
atgcccgatctg
agggcgctatag
+
07;8Aa--c:':
:_&-%a-$!N~:
```

## Understanding the quality score entry

The quality score is how confident the basecaller is in
  the base call. A low quality scores means that it is
  likely wrong.

The quality score entry is not something you would
  normally read. Even if you tried it is not something
  you can read. It is more for machines.

The value of the quality score entry ranges between 0 to
  93. With each increase of 10 marking a 10x lower error
  rate. So, 0 means everything is wrong, 10 means 1 of
  10 bases is wrong, 20 means 1 of 100 bases is wrong.

| quality score | char | accuracy (%) | error rate      |
|:--------------|:-----|:-------------|:----------------|
|  0            | !    |  0           | always wrong    |
| 10            | +    | 90           | 1 of 10         |
| 20            | 5    | 99           | 1 of 100        |
| 30            | ?    | 99.9         | 1 of 1000       |
| 40            | I    | 99.99        | 1 of 10000      |
| 50            | S    | 99.999       | 1 of 100000     |
| 60            | ]    | 99.9999      | 1 of 1000000    |
| 70            | g    | 99.99999     | 1 of 10000000   |
| 80            | q    | 99.999999    | 1 of 100000000  |
| 90            | {    | 99.9999999   | 1 of 1000000000 |

Table: quality score accuracies per 10

The first step to convert the quality score is to get the
  number from the character. In your computer each
  character is represented by a number (ascii). The
  visible characters (letters, numbers, punctuation, and
  special symbols) start at 33. If you subtract 33 from
  the characters number you get the assigned quality
  score.

You can find the numbers for each item by looking up the
  ascii table.

The quality score is found using the equation
  `-10 * log10(error_rate)`. You can convert the quality
  score to its error rate using `10^(score / -10)`.

When ONT (Nanopore) finds the mean quality score they
  first convert the score to its error rate. Then they
  find the mean error rate. After that they convert it
  back into the quality score. For some reason this often
  gives a quality score then taking the mean of all
  scores.

| q-score | number reads (ONT) | number reads (mean) |
|:--------|:-------------------|:--------------------|
| 7       |     3              |      0              |
| 8       |  3387              |      0              |
| 9       |  9157              |      3              | 
| 10      | 15774              |     85              | 
| 11      | 25387              |    866              | 
| 12      | 32723              |   2257              | 
| 13      | 24602              |   3003              | 
| 14      |  9575              |   3923              | 
| 15      |  2106              |   5333              | 
| 16      |   397              |   7575              | 
| 17      |    81              |  10638              | 
| 18      |    23              |  14471              | 
| 19      |     5              |  18817              | 
| 20      |     1              |  21387              | 
| 21      |     0              |  18263              | 
| 22      |     0              |  11346              | 
| 23      |     1              |   4421              | 
| 24      |     0              |    878              | 
| 25      |     0              |     88              |  
| 26      |     0              |      8              |  
| 27      |     0              |      2              |  
| 33      |     0              |      1              |  

Table: Quality scores for SRR28476579. ONT means
  converting to error rates and then finding the mean.
  Mean is the mean q-score for the read. For ONTs method I
  used my seqStats program. For mean I mapped the reads
  to a genome using minimap2, then used my filtsam program
  to get the mean q-scores for mapped an unmapped reads.

At this point you should be able to understand the fastq
  file. The final parts of this tutorial are on how to
  read a fastq file.

# Reading a fastq file

## Intro

When scripting or programming you will likely always have
  libraries to read in fastq files for you. There are also
  several programs to convert fastq files. However, if you
  need you own solution, here is what you do.

## Reading line by line

1. Read the header
2. Read in the sequence till a `+` is found
   - Keep track of the number of lines
3. Read in the spacer line (`+`)
4. Read in the same number of lines as in the sequence to
   get the quality score line

See the end of this file for an example in awk.

## Jumping in the middle of a fastq file

You should never need to jump into the middle of a fastq
  file. However, if you ever need to jump in the middle
  of a fastq file you can search for three patterns. These
  patterns should work for most cases. However, none of
  these three patterns are required. Instead no one has
  done anything that breaks these patterns.

1. A line with a single `+` means you are on the spacer
   entry
   - Move back till you find a line with a `@`
2. A line with a `+` at the start and a space or tab means
   you are on the spacer entry
   - Move back till you find a line with a `@`
   - `+ some_data` (SRA does this)
3. A line with a `@` at the start and a space or tab means
   you are on the header entry
   - `@read_id some meta data`

Here is an example of a valid fastq file that breaks these
  three patterns.

```
@read_id_1
atagc
+some_text_with_no_white_space_on_the_line
15at-
@read_id_2
atagc
gtggt
+some_text_with_no_white_space_on_the_line
?_-TA
::'40
```

Read id one has four lines, while read id two has six. So,
  you can not tell you position by line counts. Also, both
  read ids have no spaces, so a space can not be used to
  tell if you are on a header. The spacer has the same
  problem. Even worse the spacer has text so you can not
  tell if it is the quality score line or the spacer. This
  means you can not jump in the middle of this file. You
  can only read this file by starting with the first read
  and moving to the last. Thankfully no one ever does
  this, so you are safe.

## A line by line example

For example; here is an awk script to convert a fastq
  file to a fasta file. You can call it with
  `awk -f script.awk`. Before using this, you should use
  other peoples tools, such as seqkit to do this instead.
  This is here as an example of how to read a fastq file.

```
#!/usr/bin/awk -f

# in awk a # is a comment (for humans only)

# awk uses sections BEGIN, MAIN, and END. All the code
#  for these sections are between {}.
#  - BEGIN (BEGIN{<code>}) is before any file is read
#  - MAIN ({<code>}) is while all files are being read
#  - END (END{<code>}) is after all files have been read

{ # MAIN
   headerStr = $0;   # get the header line
   getline;          # get the first sequence line

   sequenceStr = ""; # make sure sequence is blank
   seqLinesSI = 0;   # set number lines read in to 0

   while($0 !~ /^+/)
   { # Loop: get the sequence entry
      sequenceStr = sequenceStr $0; # get the sequence
      seqLinesSI = seqLinesSI + 1; # count number of lines
      getline;                     # get the next line
   } # Loop: get the sequence entry
   # The $0 !~ /^+/ means run till the line has a + at
   #   the start.
   #   $0 means the entire line
   #     - $1 means column 1
   #     - $2 means column 2
   #     - $3 means column 3
   #     - .
   #     - .
   #     - .
   #     - $NF means the last column
   #   ! means not (for example: till not found)
   #   ~ means a regular expression (search for a pattern)
   #   !~ means run the loop till the pattern is found
   #   / / is my pattern to search for
   #   ^  means the pattern must be at the start of a line
   #   /^+/ means the + must be at the start of a line

   spacerStr = $0; # get spacer entry
   qScoreStr = ""; # blank the quality score entry

   # read in the quality score entry
   for(qLineSI = 1; qLineSI <= seqLinesSI; ++qLineSI)
   { # Loop: get the q-score entries
      getline; # move to the next q-score line
         # first time is off the spacer; the later times
         #  is of the previous quality score lines

      qScoreStr = qScoreStr $0; # get the quality scores
   } # Loop: get the q-score entries

   # in the header replace the @read_id with >read_id
   sub(/^@/, ">", headerStr);

   # print the fasta entry
   print headerStr;    # header for the fasta file
   print sequenceStr;  # sequence part of fasta file
   print "";           # blank line between sequences
} # MAIN
```
