# Goal:

Do a denovo assembly with the reads we binned from
  kraken2.

# Introduction:

In the last episode we went over a general overview of
  assemblers. In this episode I plan to take our binned
  reads from kraken2 and build a denovo assembly.

There are several denovo assemblers for Nanopore
  sequencing. There are several I have not tried or head
  of. In this episode I am going to focus on the two
  assemblers I know.

1. Flye is one of the better denovo assemblers for
   Nanopore data. It can often build more accurate
   assemblies then Raven. However, flye also takes more
   time and ram. For the dataset we are looking at, flye
   will need more the 8Gb of ram.
   - [https://github.com/mikolmogorov/flye]
      https://github.com/mikolmogorov/flye)
2. Raven is less accurate then flye, but is also faster
   and takes less ram. Raven is also easier to install.
   - [https://github.com/lbcb-sci/raven](
      https://github.com/lbcb-sci/raven)

With Raven, you should always polish your assemblies to
  improve the accuracy. With flye polishing is still a
  good idea, but is less important.

For this episode I am going to be using flye. You should
  be able to figure out how to use raven from its help
  message. Take some time to try to figure out the
  install. If you can not see the installing flye on Linux
  section.

For Mac you should be able to install flye with homebrew.
  For Linux, apt does not always install flye correctly,
  so you may want to install from source. You can find
  the install instructions for flye under the install
  link in the README at flye's github page.

#  Installing flye on Linux

For Mac the homebrew install seems to work well. For
  Linux I have had some issues with the apt install
  missing samtools-flye. To deal with this I installed
  flye from source. These means I will have to manually
  update flye or write a script to update for me.

First clone (download) the flye repository.

```
cd ~/Downloads;
git clone https://github.com/mikolmogorov/flye flye;
```

Next build the flye program and then install flye:

```
cd flye;

# build the flye program
make;

# install flye in your computer
sudo python3 setup.py install;
```

# Using flye

As usual, take some time to read flye's help message. See
  if you can figure out how to use flye without me telling
  you. Lets try the reads kraken2 assigned Muvirus (taxon
  id 186777) and Salmonella (taxon id 590). From the
  report it looks like Muvirus has a lot of bacteria
  phages for detected bacteria in our sample. Most of
  the reads mapped to the Muvirus genus.

If you have less then 16Gb of ram, then I would recommend
  using raven instead. The Muvirus assembly took 9Gb to
  build.

Remember to include the version number of flye and the
  command you used in your notes.

When flye runs it creates many files. All of these files
  are saved to the output directory you tell flye to
  make `--out-dir <new-directory-name>`. The file
  I am interested is the file with the contigs
  (consensuses or sequences) that flye made. This file
  is named `assembly.fasta`.

Apart from the output directory, we need to provide a
  fastq file of reads. These reads can be provided with
  several flags. In this case we are using reads sequenced
  with 9.4 ONT flow cells, so we need the `--nano-raw`
  option.The format is `--nano-raw <reads.fastq>`.

If we had used a dataset that used R10 flow cells we
  would be using the `--nano-hq <reads.fastq>` setting
  instead. 

At this point you should all the needed input for flye.
  There are a lot more extra options, none of which I
  have touched. So, I do not know what most of them do.

I am also adding in the `--meta` flag for metagenomic
  (multiple species) assemblies. I am doing this because
  I do not fully trust my kraken2 bins.

- Here are some other options that you may or may not
  set:
  1. The number of iterations (times) flye polishes
     (`--iterations <number>`)
     - I have never used with this setting, so you will
       want to benchmark different settings before
       changing it (we will do this in a later tutorial)
  2. You should use `--meta` for metagenomic datasets
    - We hopefully used kraken2 to reduce our metagenomic
      dataset to a single isolate are using
  3. You can multithread using the `--threads <number>`
     setting.

Here is my flye example for the viral reads I pulled us
  k2TaxaId:

```
mkdir 05-flye-k2Pull;

# getting the virus (pull reads by classification)
flye \
    --meta \
    --nano-raw 03-k2-reads/03-zymo-k2viral-k2Taxa-186777-Muvirus-seqById.fq \
    --out-dir del;
```

Here is my example for the reads I pulled from kraken2
  with a reference.

```
mkdir 06-flye-refBin;

# getting the virus (pull reads by classification)
flye \
    --meta \
    --nano-raw 04-k2-readsByRef/04-zymo-k2-map-NC_000929.1.fq \
    --out-dir del;
```

# Final thoughts

## Thoughts on kraken2 accuracy

One problem with our test dataset is that it had low read
  depths of the zymo mock community. So, it is no surprise
  to see fragmented assemblies. Another problem we have
  is that there are more bacterial species found then in
  the actual community (excluding phages [no idea]). Two
  of the bacterial species have plasmids.

The actual community is:

| Genus         | Species       | type          |
|:--------------|---------------|:--------------|
| Bacillus      | subtilis      | bacteria      |
| Enterococcus  | faecalis      | bacteria      |
| Lactobacillus | fermentum     | bacteria      |
| Listeria      | monocytogenes | bacteria      |
| Escherichia   | coli          | bacteria      |
| Pseudomonas   | aeruginosa    | bacteria      |
| Salmonella    | enterica      | bacteria      |
| Staphylococcus| aureus        | bacteria      |
| Saccharomyces | cerevisiae    | fungi (yeast) |
| Cryptococcus  | neoformans    | fungi (yeast) |

Table: list of species in the zymo mock community.

### Pulling by kraken2 classification

The actual community is:

| Genus              | type          | Kraken2 Genus |
|:-------------------|:--------------|:--------------|
| Bacillus           | bacteria      | yes           |
| Enterococcus       | bacteria      | yes           |
| Lactobacillus      | bacteria      | no idea       |
| Listeria           | bacteria      | yes           |
| Escherichia        | bacteria      | yes           |
| Pseudomonas        | bacteria      | yes           |
| Salmonella         | bacteria      | yes           |
| Staphylococcus     | bacteria      | yes           |
| Saccharomyces      | fungi (yeast) | yes           |
| Cryptococcus       | fungi (yeast) | yes           |
| Limosilactobacilus | bacteria      | maybe         |
| Citrobacter        | bacteria      | no            |
| Klebsiella         | bacteria      | no            |
| Shigella           | bacteria      | no            |
| Leclercia          | bacteria      | no            |
| Muvirus            | phage         | no (??)       |

Table: list of species in the zymo mock community. In
  2020 the lactobacilus genus was split up, so it is
  possible that Limosilactobacilus is correct.

### Using kraken2 references for binning

By reference binning:

| Genus               | Accession | Genus in Zymo |
|:--------------------|:----------|:--------------|
| Bacillus            | JBUDHI    | yes           |
| Enterococcus        | CDYJSZ    | yes           |
| Escherichia         | JAQMZI    | yes           |
| Listeria            | JAKGMC    | yes           |
| Pseudomonas         | CM145526  | yes           |
| Salmonella          | JBVFYC    | yes           |
| Staphylococcus      | JASPCX    | yes           |
| Shigella            | AP040255  | no            |
| Limosilactobacillus | CDXGPJ    | maybe         |

Table: Genus we found by reference binning. In 2020 the
  lactobacilus genus was split up, so it is possible
  that Limosilactobacilus is correct.


However, we did not detect *Saccharomyces* or
  *Cryptococcus*.

### My thoughts on this

One thing I noticed is that the *Lactobacilus* family
  was split up in 2020. So, it is likely that
  *Limosilactobacillus* is a correct call.

With the reference based binning we only missed the yeast.
  The yeast genome is large and the read depths are low.
  So, it is no surprise we missed this.

One advantage the reference based method has is that many
  of the references were for the species (not Genus) in
  the community. This happened by chance and may have
  made the results better then they really would be.

The kraken2 classification (k2TaxaIds) pull method pulled
  out extra species. Other then the bacteria phage, these
  species are not in the community. It is possible with
  stricter settings kraken2 could do better. It is also
  possible we may even catch these mistakes by blasting
  the genomes.

The one exception may be the bacteria phages, which really
  could be present. However, most reads for the bacteria
  phage classified only to the Genus level (see the
  report). So, I suspect these reads are genes that the
  bacteria phage grabbed or inserted into a host genome.

This is an example were a better benchmarking step would
  be needed to make a better decision. We will not do
  that, but some variables we would look at would be
  stricture settings on kraken2, a close or distant
  reference, read depth. We also would use R10 flow cell
  data. R9 flow cells are no longer used.

## Final notes

At this point you should know how to use flye for simple
  cases. If you want to do a metagenomic (multiple
  species) assemblies you can run flye with the same
  settings.


Another assembler you might look into is viral flye. Viral
  flye is flye with settings better suited for viruses.

To see my notes see the 17-denovo-with-k2Reads-notebook.md
  file. My flye command will look a little different then
  here since I wanted to build an assembly for all genomes
  at once. We will get into this level of automation later
  on.
