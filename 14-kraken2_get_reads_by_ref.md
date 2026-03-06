# Goal:

Learn how to extract the reads using the references
  kraken2 found. This will also require you to learn how
  to map and filter reads.

# Introduction:

On reason to know more ways of doing things is that one
  method may not always be the best approach. Having more
  then one method allows you to figure out the best way to
  handle a problem.

You have seen how to extract the classified reads from
  kraken2. However, this method can also miss unclassified
  reads and relies on kraken2 to have done a good job.

Another method you can use to extract reads is to map
  (align) reads to a reference. Then remove the reads that
  did not map to the reference. We can find a set of
  references by using the taxon ids for each reference
  (kraken2 outputs this).

The advantages of extracting reads by references is that
  we can mine the unclassified reads. We also know that 
  a read belongs to the reference or at least to a similar
  reference.

A disadvantage is that it is still possible for a read to
  be assigned to the wrong genome if two species have a
  similar genome. You can reduce this a bit by using a
  reference for each taxon id that kraken2 found.

Another problem is that reads with large insertion or
  deletion may not map to a reference. This could be a
  problem if we picked a reference that was more distant
  from our reads. In this case we might lose large
  variants or more variable parts of the genome.

There are likely more pros and cons, but that is all I
  could think of.

# The task

You do not need to understand the file formats in these
  next steps. I will go over a sam file (read alignments
  to the reference) later. A bam file is a compressed sam
  file.

- You task can be divided into several steps:
  1. Find taxon ids for kraken2
  2. Get the reference names for each taxon and get a
     genome for the taxon
  3. Map reads to your set of references
     - minimap2 can map reads
  4. Filter (remove) unmapped reads
     - samtools view can filter reads (also can convert a
       sam file to bam file)
     - get the help message
       `samtools veiw help 2>&1 | less`[^1]
  5. Bin reads by reference
     - bamtools (needs a bam file; better) or binSam
  6. Convert the output sam file to a fastq file
     - `samtools fastq` can do this for a bam file
     - get the help message with
       `samtools fastq help 2>&1 | less`[^1]

Take some time and work out how you will get the
  reference genomes. I will use a different solution, but
  it is worth the time to figure this out. Also, take some
  time to figure out the settings you want to use with
  each program. See if you can get a full workflow done.

[^1]: Your terminal has two output types. `1` is
      stdout and is passed to other programs. `2` is
      stderr and is not passed to other programs. Stderr
      is used to report errors or status updates. You can
      put stderr into stdout with `2>&1`. samtools puts
      its help messages to stderr.

# Getting references

I cheated here. I used `k2TaxaIds` to spit the read ids.
  I then extracted the taxon ids from the file names
  using sed. After that I called the `getRefsByTaxon.sh`
  script in the `00-scripts` repository.

The downside of my shortcut is I might not get a good
  reference.

My first trick was to get the file names using
  find to find the valid files. Find will search for files
  at the location I specify. In my case I did
  `find . -name *.ids` to find all files ending in `.ids`.
  I used the `*` to find any file that had k2TaxaId in the
  name and ended in `.ids`.

My next trick was to use the pipe (`|`) to pass the output
  from find to sed. I then used a regular expression to
  remove the prefix from each files name and the ending.
  This left only the taxid id.

In sed, you can do a substitution using
  `sed 's/<pattern>/<replace>/'`. You can combine
  substitution commands together by adding a `;` to the
  end of each command. For example you could use
  `sed s/<pattern>/<replace>/; s/<pattern2>/<replace2>/s;'`
  to do two substitutions. If you leave `<replace>` blank
  then you will remove the pattern. See if you combine
  find and sed to get the taxon ids from the k2TaxaId
  output. Save the ids it to a separate file.

I am also removing the file path with the sed 's/.*\///;'`
  command. The `.*\/` replaces everything before the
  last `/`.

Remember to add the commands you used to your notebook.

Here is my command:

```
mkdir 04-k2-readsByRef;
find ./03-k2-reads -name *.ids |
  sed 's/.*\///; s/03-zymo-.*k2Taxa-//; s/-.*\.ids//;' \
  > 04-k2-readsByRef/04-zymo-k2-taxidIds.txt;

  # .* means replace any number of characters
  # I am merging the viral and plusPF16 ids
  # basename extracts the file name from the file path
```

After I had the taxid ids I could use the
  getRefsByTaxon.sh script in this tutorial repository
  [https://github.com/jeremybuttler/cmd-tutorials](
   https://github.com/jeremybuttler/cmd-tutorials
  ). Copy or move this script from the `00-scripts`
  direcotry to your Downloads directory to make your
  life easier. Then get its help message with
  `sh ~/Downloads/getRefsByTaxon.sh -h`.

The getRefsByTaxon.sh script is a script I made to
  download a (first found) reference for a taxid id. It
  uses the entrez system to talk with NCBIs Genbank. This
  is not a system I am very used to and I have forgotten
  most of what I learned.

The problem with getRefsByTaxon.sh is that it is not very
  picky about the reference used. It will pick the first
  assembly on the list, even if it is a fragmented
  assembly. However, it does make my life easier. All
  references will be stored in the
  `~/Documents/getAmrRefs` directory.

Here is my command:

```
sh ~/Downloads/getRefsByTaxon.sh \
    -taxon 04-k2-readsByRef/04-zymo-k2-taxidIds.txt \
    -prefix 04-k2-readsByRef/04-zymo-k2;
```

# Get reads

## quick setup

Normally I would suggest using bamtools to bin reads.
  However, in this case the getRefsByTaxon.sh will
  often select fragmented assemblies. These assemblies
  have a accession number for each contig (fragment). This
  means that I need a program that can figure out if two
  or more references belong to the same bin. binSam looks
  for NCBI accesions that might have multiple contigs and
  treats them as one bin. I am not sure if bamtools can
  do this, it might be able to.

BinSam is from the same repository as k2TaxaId. So, the
  source code should be in your Downloads folder. After
  making `binSam` put it in your Downloads folder like we
  did with `k2TaxaId`.

```
cd ~/Downloads/bioTools/binSamSrc;
make -f mkfile.unix;
mv binSam ~/Downloads;
chmod a+x ~/Downloads/binSam; # give execute permision
```

## You task; get reads

To map (align) reads to a reference we can use minimap2.
  If you have not already, take some time to view the
  help message and figure minimap2 out. If you want to
  avoid a temporary file you can pass the output of
  minimap2 to `samtools view` and `binSam` using `|`'s.

Minimap2 can read gziped files. So, do not worry about
  files with a `.gz` ending.

See if you can figure out how to remove unmapped reads
  with `samtools view` and then bin the reads with
  `binSam`.

Remember to keep track what you did and version numbers in
  your notes.
 
## My code

For minimap2, you need to use `-a` to output a sam file.
  At the end of your command you will also add the
  fasta file with your references and the fastq files. You
  can have more then one fastq file.

For `samtools view` I can use a `-F 0x4` to remove
  unmapped reads. I will also use `-` to tell samtools I
  am using input from another program.

For binSam you only need to provide the sam file with
  `-sam`. We can use `-sam -` for stdin (input from
  another program). I am also using `-out-fq` to convert
  the output sam file to a fastq file.

Putting it all together gives me something like this:

```
minimap2 \
    -a \
    04-k2-readsByRef/04-zymo-k2-refs.fa.gz \
    01-input/01-SRR28476579.fastq |
  samtools view -F 4 |
  binSam \
    -sam - \
    -fq-out \
    -prefix "04-k2-readsByRef/04-k2-reads";
```

# Final thoughts

At this point you know two ways to extract reads using the
  results of kraken2. Both methods have their weaknesses
  and strengths.

You should also know how to map reads and removed unmapped
  reads. To see a list of other flags you can filter with
  see [https://broadinstitute.github.io/picard/explain-flags.html](
         https://broadinstitute.github.io/picard/explain-flags.html).

To see how my notes look by the end of this tutorial see
  the 14-kraken2\_get\_reads\_by\_ref-notebook.md file.
