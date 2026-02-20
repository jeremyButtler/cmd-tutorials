# Goal:

Give an overview of how a biofinormatics workflow may look
  like.

# Introduction

Art has both a science side and art side. In a story the
  science is the mechanics, for example the grammar and
  the plot flow. The art is the creative parts, for
  example the characters and the story being told.

In Bioinformatics (and science in general) you often have
  both a science and an art. The science is the protocols
  and programs you use. The art is using your skills to
  figure out how to get everything to work. Or, making
  your own tools.

The task you will be given as a bioinfomatition will vary.
  In some labs you may be focused on figuring out the
  microbial community between sites, animals, or diseases
  in individuals. In other labs, such as the one I am in,
  you might be trying to figure out what pathogen killed
  an animal. Because of this my tutorials will not cover
  all programs or cases. Instead I focus on what I know.

Being a good bioinformatition is being able to explore
  your data. Then from your exploration to figure out a
  path to analyze the data.

# An 

You can think of data analysis in three steps.

1. Explore your data to see what you have
2. Analyze your data for results
3. Think about your results and plan the next steps
   - Possibly repeat steps 1 to 3

When you get a fastq file (or a pod5) from a metagmoic
  dataset you have a pile of reads. Those reads are not
  assigned to any bacteria, viruses, or any other life
  form. My goal is often to take that pile of reads and
  convert it to genomes. To do this I ca not just use one
  tool. I have to figure out what tools to use.

## Step one; visualize

My first step might be to visualize the data. For the read
  stats (N50, median Q-score, mean q-score) I might use
  nanoStat. If I have low quality score reads I might
  filter out those reads with a different tool. However,
  the basecaller already does this, so often I skip these
  steps. Though getting the stats is still good for the
  paper.

My next step is to explore my dataset or if it was a
  story, to find my list of suspects. Here you will want
  to plot the data in some way. For my work I often use
  kraken2 to get my list and Pavian (website) to
  visualize. However, if you are comparing communities
  your may use qime to compare the communities.

Kraken2 will classify reads. This is a way of saying it
  will assign a read to a species, family, gEnus, ....
  Kraken2 works by keeping a database of patterns. It then
  looks for these patterns in the reads. If enough
  patterns are present it will assign the read to the
  target.

Because the patterns kraken2 uses are in the database,
  kraken2 can only assign reads to what is in the
  database. So, kraken2 will not find novel or new
  species.

Another problem is shared genes between bacteria or
  viruses then will have similar patterns in the
  kraken2 database. This means that kraken2 can
  miss-assign reads. So, you should never take kraken2
  as the final word on if a species is present. However,
  what kraken2 does well is to give you an idea of what to
  look for. Kraken2 allows you to explore your dataset.

For the lab I am in, we are not often interested in the
  whole community. Instead we might be interested in a
  potential pathogen. This is were using the expertise
  of others comes in. I may be able to pull out a large
  suspect list, but someone else may be able to narrow it
  down for me.

My goal as a bioinformation is not to know everything. My
  goal is to know how to get from reads to our end goal.
  This may require me to do a lot of self learning along
  the way.

## Step two; plan your analysis

After you have your suspects or found that interesting
  gem you need to figure out how to confirm it is true.
  When comparing microbiomes this may require stats (a
  point I am very weak at). To confirm a pathogen or
  microbe of interest is present present you may need to
  assemble a genome. Or at least look at the reads.

There is no right way, but many better ways, none of which
  I know. I only know my own hacky method.

- Some tools:
  1. kraken tools:
     - Allows you to extract reads that kraken2 classified
     - I have had problems getting it to detect the pip
       installed biopython
  2. k2TaxaIds + seqById: (my own tools)
     - k2TaxaIds pulls out the read ideas for each taxa
     - seqById can pulls out reads by read ideas from a
       fastq file
       - seqkit (`seqkit grep`) can do the same task
  3. reference(s) + minimap2 + samtools:
     - You can map reads to a reference and filter out all
       the unmapped reads
     - I would recomened using multiple references in the
       community. This will reduce similar genes or
       sections in other microbes genomes being mapped to
       one reference.
       - use bamtools to split reads by reference
  4. flye or raven (metagenomic assembly)
     - Assemble genomes from the metagenomic community
       with a denovo assembler
  5. Method I have not thought of
     - Likely plenty of options, you figure this out

After you get the reads or genome the next step would be
  to build an assembly. For assemblies you have at least
  two methods, reference based or denovo.

Denovo assemblies use overlapping ends of reads to
  assemble reads into contigs (merge reads together). They
  do not need a reference genome and so have no reference
  bias. This allows them to detect large events, such as
  an large insertion or inversions. However, if other
  microbes are similar enough they can also insert parts
  of the other microbes genome into the assembly.

Reference based assemblies use a reference to guide the
  assembly. However, when there is low support the
  reference is often favored. This means they can pull
  the assembly towards the reference (make the assembly
  look more like the reference). All reference based
  assemblers will have some pull for insertions or
  deletions. However, some will have a pull for SNPs as
  by inserting non-anonymous bases when there is low
  confidence for a position. The low confidence can be
  from low read depth or a split between bases.

You can always use a reference bases assembler to polish
  an denovo assemblers output or another reference based
  assemblers output.

- Tools:
  1. flye is one of the better denove assemblers
     - slow and uses more memory
     - raven can be used instead (faster and less memory)
       at the cost of accuracy
     - there are many more I do not know about
  2. Ivar is a reference based assembler
     - no SNP pull
  3. Medaka is ONT's polisher
     - Often used to polish flye assemblies
     - a few years ago, it did have reference pull for
       SNPs, otherwise it was pretty good
     - The samtools line up, this will insert reference
       bases for low supported positions
       - make sure you mask by read depth
     - pain to install, but has gotten easier (maybe)
  4. Clair3 supposed to be an improved Medaka
     - I found in my own benchmarking that it was pretty
       good and may have had less of a reference pull on
       SNPs
     - It has been improved since I last used it
     - pain to install, no idea if has gotten easier
  5. vcftools, bcftools, samtools
     - The samtools line up, this will insert reference
       bases for low supported positions
       - make sure you mask by read depth
  6. `samtools depth`
     - provides read depth for every reference base
       position, which can be used to mask low depth bases

## Step 2 continued; annotation

Once you have a genome it is a good idea to remove errors
  that might remain. Normally this might require you to
  remove indels, inversion, or other odd looking
  mutations. I am not very good at this step and sometimes
  forget to do it.

One trick I am thinking of to catching some of these
  errors in known species is to annotate a genome. My
  method is to strip annotations from a known reference
  to my assembly (or consensus).
 
I do not know much about the denovo annotations like
  Glimer.

I know the tools for annotation at
  [www.bv-brc.org/app/Annotation](
   www.bv-brc.org/app/Annotation) will often work. Though
  I have had some virus that failed.

My other approach is to use my own script
  [www.github.com/jeremyButtler/annotateASFV](
   www.github.com/jeremyButtler/annotateASFV). This set
   of scripts and programs will spit out a feature table,
   but will also warn about incomplete reading frames.
   The input is a fasta file with each gene in the
   reference.

I can not tell you how to do a Manual curation, because it
  is about removing potential errors. This requires you to
  learn to recognize what an error might look like.
  Something I am not very good at.

Either way, annotation is helpful for removing errors and
  when it is time to upload the data to Genbank.

## step 2 cont; phylogenetics

A phylogenetic tree is a hypothesis about the relation of
  your genome to other species. It can give you an idea
  were your strain might have come from. The more genomes
  you have from all over the world the better the picture.

One catch is that different organisms use different
  methods. Smaller viruses will often use genes or groups
  of genes. Flu can use multiple trees for each segment.

For bacterial species the genomes may be to large. So,
  methods of finding lineages might use repeat lengths
  (MIRU), matches to a list of gene variants (Multi Locus
  Sequence Typing (MLST)), or a few key SNPs. They may
  also use other methods. It is up to you to find the
  methods used for your organism. This will require you
  to dig through the literature.

## step 3; are you done?

During step two you may notice weak points in your
  analysis or new things may come up. Maybe your sample
  had more then one strain of your organism, but you
  thought there was only one. Or maybe, there are more
  species you can be working on.

In these cases you might go back to step one or two. Try
  to figure out what is going on. And then figure out how
  to do the next analysis. You keep repeating this until
  you have finally got some understanding of what is going
  on, you run out of data, or you have no more ideas.
