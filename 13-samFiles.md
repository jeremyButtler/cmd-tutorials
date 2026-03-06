# Goal:

Lean about the sam file format.

# Introduction:

When we align reads to a reference (mapping) we need to
  store the output in a file. The sam (sequence alignment
  map) file format can be used to store these aligned
  reads. The sam file will store the read id, if the read
  was mapped, reference id, the alignment, sequence and
  quality scores for each base.

Unlike fastq files, a sam file allows only one line per
  read. Tabs (tsv file) are used to separate the entries
  for each read.

You can find the sam file format pdf at:
  [samtools.github.io/hts-specs/SAMv1.pdf](
   samtools.github.io/hts-specs/SAMv1.pdf
  ).

Wikipedia also has a good link.

Another similar file format is the `bam` and `cram`
  formats. From what I understand (I could be wrong) both
  `bam` and `cram` are compressed sam files. I have never
  dug into these formats.

# Comments:

The sam file allows comments at the top of the file. Each
  comment starts with a `@` symbol. The comments are often
  used to store information for other programs or keep
  track of the programs you used.

The header entry (first line) is `@HD`. The header can
  have multiple items, such as the version number
  `VN:<number>` of the sam format being used. Each item is
  separated by a tab. For more header entries check sam
  file format.

An example (simpler): `@HD	VN:1.6`


The sequence entry has information about the references
  used. It starts with `@SQ`. Like the header it can have
  multiple items separated by tabs. The two items I have
  seen are the reference name `SN:<name>` and the
  reference length `LN:<length>`. You will see more then
  one sequence entry if sam file has multiple references.

An example: `@SQ	SN:NC_000862.3	LN:4411532`

The last comment entry I often see is the program entry
  `@PG`. The program entry has the program used
  `ID:<program>` and `PN:<program>`, the version number
  `VN:<version>` and the command used `CL:<command>`. Each
  item is separated by a tab. The `CL:` (command) item
  should always come at the end.

An example: `@PG	ID:minimap2	PN:minimap2	VN:VN:2.28-r1209 CL:minimap2 -a NC000962.fa reads.fastq`

This is the end of what I often see in sam files for
  the comments. There are many more entries, none of which
  I know.

You can get or remove the header by looking for any line
  starting out with a `@`. From my experience these are
  only at the top of the file. Do not put comments in the
  middle (who knows what will break).

# Reads

The reads or sequences come after the header. Each read
  has 11 required items that are separated by tabs. As
  a rule, do not use spaces in a sam file. The reason why
  is because the command line treats spaces and tabs as
  the same (most of the time). If an item is blank it is
  filled in with a `*` if non-numeric or a 0 if numeric.

- The entries:
  1. Read id or sequence name (no spaces)
  2. Flag marking if unmapped (and more)
  3. Reference name (`*` if unmapped)
  4. First mapped reference base (0 if blank)
  5. Mapping quality (0 if blank or very low)
  6. CIGAR (compact idiosyncratic gapped alignment report)
     - Has the alignment for the sequence
     - blank is a `*`
  7. RNEXT no idea
     - From wiki I think it is next reference (still no
       idea)
     - For ONT reads, minimap2 leaves this blank (a `*`)
  8. PNEXT: no idea
     - Wiki says position of primary alignment of next
       read (no idea)
     - For ONT reads, minimap2 leaves this blank (a 0)
  9. TLEN (no idea, wiki says observed template length)
     - For ONT reads, minimap2 leaves this blank (a 0)
  10. The sequence
      - Always in the same direction as the reference
        - Is reverse complemented if needed
      - A, T, G, C, - (gaps), and anonymous bases
      - Maybe amino acids?
      - blank is `*`; often secondary alignments are set
        to blank to save space
  11. The quality score
      - Any visible character
      - blank is `*`; often secondary alignments are set
        to blank to save space
  12. And onwards; extra entries (not required)
      - Format is `<tag>:<data_type>:<value>`

For most of these entries you can figure then out from
  my list, I have no idea what they are for, or they
  are extra.

However, the flag entry, mapping quality, and CIGAR entry
  are worth going over.

## The flag

The number for the flag in a sam file can be one or more
  flags combined into a number. Each flag is a power of
  two (1, 2, 4, 8, 16 ...). The powers of two are added
  to get the final flag. For example, the flag 272 is
  256 (2^^9^^) (non-primary alignment) + 16 (2^^5^^)
  (reverse complement).

The flags being stored as powers of two seems odd.
  However, this systems leveraging how you computer stores
  numbers to speed up checks. In binary a 1 is a power of
  two that is present and 0 is a power of two that is
  missing (1 = 2^^0^^ = 1; 101 = 2^^2^^ + 2^^0^^ = 5).
  This makes checking powers of two very quick, since we
  only need to check if a bit is set to 1 or 0. In C we
  can do this with an `&`. For example, I could check if
  272 was a reverse complement alignment using
  (`if(272 & 16)`).

So, to check if a read is reverse complement (2^^5^^) I
  can check the 5th bit. For example, both 100010000 (272)
  and 000010000 (16) are reverse complement. But only
  100010000 is a secondary (not a primary (best))
  alignment.

I grabbed this table of sam file flags from Wikipedia
  ([https://en.wikipedia.org/wiki/SAM_(file_format)](
   https://en.wikipedia.org/wiki/SAM_(file_format))). I
  added in the flags I have seen for ONT reads.

| Flag | Binary flag  | I have seen |                              Description (Paired Read Interpretation)
|:-----|:-------------|:------------|------------------------------------------------------------------------------------|
| 1    | 000000000001 | no          | template having multiple templates in sequencing (read is paired)
| 2    | 000000000010 | no          | each segment properly aligned according to the aligner (read mapped in proper pair)
| 4    | 000000000100 | yes         | segment unmapped (read1 unmapped)
| 8    | 000000001000 | no          | next segment in the template unmapped (read2 unmapped)
| 16   | 000000010000 | yes         | SEQ being reverse complemented (read1 reverse complemented)
| 32   | 000000100000 | no          | SEQ of the next segment in the template being reverse complemented (read2 reverse complemented)
| 64   | 000001000000 | no          | the first segment in the template (is read1)
| 128  | 000010000000 | no          | the last segment in the template (is read2)
| 256  | 000100000000 | yes         | not primary alignment
| 512  | 001000000000 | no idea     | alignment fails quality checks
| 1024 | 010000000000 | no          | PCR or optical duplicate
| 2048 | 100000000000 | yes         | supplementary alignment (e.g. aligner specific, could be a portion of a split read or a tied region)

Table: flags for sam files (from wikipedia). I added in
  the "I have seen" column to mention if I have seen these
  flags. I work with ONT reads and I suspect many of these
  flags are for Illumina.

## The cigar

The cigar entry is the alignment for the read. Each item
  in the cigar entry has a number, and letter or symbol
  (`<number><letter>`, ex: `10M`). The letter or symbol is
  the mutation, while the number is the number of times
  the mutation is repeated. For example, 10M is 10 matches
  or mismatches.

- Common cigar symbols:
  - M: match or mismatch
  - I: insertion
  - D: deletion
  - H: hard mask
    - means the bases were trimmed for the sequence
    - typically only at the start or end of a read
  - S: soft mask
    - means the bases were not trimmed for the sequence,
      but should be ignored (think of it as skip)
    - typically only at the start or end of a read
  - X: a mismatch; only appears in eqx cigars, 
  - =: a match; only appears in eqx cigars, 

- For example `10S5M1D3M5S` would:
  1. 10 soft masked bases
  2. 5 matches or mismatches
  3. 1 deletion
  4. 3 matches
  5. 5 soft masks

```
Reference:        -----------TGCCGGCG-----
Read:             AAAAAAAAAAATGCC-GCGAAAAA
CIGAR (expanded): SSSSSSSSSSMMMMMDMMMSSSSS
```

## Mapping quality

I do not have a good grip on mapping quality. It is how
  likely a read was miss assigned to a reference genome.
  The score depends on the read mapper used. Some read
  mappers may not output anything.

Form minimap2 the mapping quality (mapq) ranges between 0
  (misplaced) to 60 (confident). I have found a mapping
  quality of 20 to work well for filtering. If you filter
  settings are set to high your reads will have to be to
  close to the reference and so you will loose real reads.
  At least that is how I understand it.

## Extra entries

The extra entries depend on the read mapper you used. Two
  common ones I have seen are `NM:i:<number>` and
  `AS:i:<number>`.

The `NM` entry is the edit distance (how many
  differences).

The `AS` entry is the score for the assembly. This is
  based off the scoring matrix the read mapper used.

The format for each extra item is in the format of
  `<tag>:<data_type>:<value>`. Tag what the item is. The
  data type is how to read in the entry. The two data
  types I know are `i` (a number) and `f` (a decimal
  number). I do not know what `A` means.

The man page for minimap2 (`man minimap2`) lists all the
  extra items minimap2 can output.
