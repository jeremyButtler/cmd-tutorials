Tools I have found that could be usefull. This is not a
  complete list, but might help you when selecting a
  task.

Some of these programs might be out of date.

# Read filtering and trimming:

Filter reads by some meteric.

1. chopper: trims and filters reads (made for ONT)
   - [https://github.com/wdecoster/chopper/](
      https://github.com/wdecoster/chopper/)
2. filtlong: keep best reads (ex: keep top 90% of reads)
   - Filtlong does not do a good job at read filtering,
     so I recomend to stay away from it
3. fastqc: this is designed for Illumina reads (not ideal
   for ONT) and is a GUI

# fastq manipulation (beyond filtering):

More then just filtering.

1. nanostat: get stats (total reads; n50, ect ...) for
  ONT fastq files
  - chopper might also be able to do this, no idea
  - [https://github.com/wdecoster/nanostat](
     https://github.com/wdecoster/nanostat)
2. seqkit: general tool kit that allows you to
   mainpulate fastq and fata files
   - I have only used the `grep` submodule
   - filtering by quality scores is likely not setup for
     ONT quality scores
   - [https://github.com/shenwei356/seqkit](
      https://github.com/shenwei356/seqkit)
   - `seqkit grep`: grab reads by read id or some other
     method

# General tool kits

Toolkits that are so broad they can not be classified.

1. emboss: has a lot of general tools includeing
   pairwise alingers (needleman and waterman)
  - [https://github.com/OryzaBioinformatics/emboss](
     https://github.com/OryzaBioinformatics/emboss)
  - see [http://emboss.open-bio.org/html/use/apbs04.html#EMBOSSAppsTableR6]
         http://emboss.open-bio.org/html/use/apbs04.html#EMBOSSAppsTableR6)
     for a list of tools
2. tablet: allows you to view many file formats (including
   sam and bam files) in a GUI
   - has not been updated in a while, but shoud still work
   - [https://github.com/cropgeeks/tablet](
      https://github.com/cropgeeks/tablet)

# Read mapping:

These will often output a sam file or can be made to
  output a sam file.

1. minimap2: the read mapper I was taught for ONT data
   - use `-a` for samfile output
   - [https://github.com/lh3/minimap2](
      https://github.com/lh3/minimap2)
2. bwa: for Illumina read mapping
   - [https://github.com/lh3/bwa](
      https://github.com/lh3/bwa)

# Sam and bam files manipulation:

Tools for mapipulating the sam files from read mappers

1. samtools: general samtools/bamtools manipulation
   - samtools depth: get depth of each base
   - samtools view: change same format to a bam format
     or filter by flags
     - some flags:
       1. unmapped: 4
       2. secondary: 256
       3. suplemental: 2048
     - see [https://broadinstitute.github.io/picard/explain-flags.html](
            https://broadinstitute.github.io/picard/explain-flags.html)
       for a list of flags
   - samtools fastq: convert a bam file to a fastq file
   - samtools sort: sort bam file by reads
   - samtools index: index a bam file for other programs
     - makes a `.bai` file (I think it is `.bai`)
   - many other modules you can use
2. bamtools: another toolkit for manipulating bam files
   - I have only used the `split` command to separate
     reads by mapped refrence, however, there are a lot
     more options
   - [https://github.com/pezmaster31/bamtools](
      https://github.com/pezmaster31/bamtools)
# Classification:

Tools for classifying reads or modifying the output.
  These tools are better for hypothesis generation then
  confirmation. Use them to figure out what might be in
  your dataset.

1. kraken2:
   - [https://github.com/DerrickWood/kraken2](
      https://github.com/DerrickWood/kraken2)
2. centerifuger:
   - used to be centerifuge
   - [https://github.com/mourisl/centrifuger]
      https://github.com/mourisl/centrifuger)
3. krakentools: getting reads by their taxa in the
   kraken2 report
   - I have had problems getting this to recognize
     biopython, but other then that it should work well
   - [https://github.com/jenniferlu717/KrakenTools](
      https://github.com/jenniferlu717/KrakenTools)
4. pavian: convert kraken2 reports to sankey plots
   - browser page:
     [https://fbreitwieser.shinyapps.io/pavian/](
      https://fbreitwieser.shinyapps.io/pavian/)
   - github page:
     [https://github.com/fbreitwieser/pavian](
      https://github.com/fbreitwieser/pavian)
5. korna: another way to view kraken2 output
   - I prefere the sankey diagrams from pavain so I have
     not use kornaTools
   - what looks like:
     [https://github.com/marbl/Krona/wiki](
      https://github.com/marbl/Krona/wiki)
   - install:
     [https://github.com/marbl/Krona/wiki/KronaTools](
      https://github.com/marbl/Krona/wiki/KronaTools)
7. braken: esitmate species abundance from kraken2 output
   - I have never used this tool
   - [https://github.com/jenniferlu717/Bracken](
      https://github.com/jenniferlu717/Bracken)

# Reference based assemblers:

1. Medaka: good for polishing a single read or contig
2. Clair3: similar to medaka 
   - [https://github.com/HKU-BAL/Clair3](
      https://github.com/HKU-BAL/Clair3)
3. ivar: reference based assembler
   - for reference based assemblies this is my prefered
     method
   - [https://github.com/andersen-lab/ivar](
      https://github.com/andersen-lab/ivar)
4. artic: the artic pipeline is designed to assembler
   genomes for sequence runs using tiling primers
   - [https://github.com/artic-network/fieldbioinformatics](
      https://github.com/artic-network/fieldbioinformatics)
5. lilo: uses medaka to polish reads and then stiches
   together amplicons with scaffold builder
   - I have had bad experiences with scaffold builder in
     the past, but rest seems pretty good
   - [https://github.com/amandawarr/Lilo(
      https://github.com/amandawarr/Lilo)

# Vcf files:

1. vcf and bcf tools are from the same group as
   samtools, never used much

# Denovo assemblers:

1. flye: one of the better denove assemblers for ONT
   data
   - [https://github.com/mikolmogorov/Flye](
      https://github.com/mikolmogorov/Flye)
   - the old standard was canu, but flye and canu are
     close nowdays, so flye is a better choice
2. hifiasm: another competor to flye. I have never used
   it or seen it used much, but it is supposed to be
   pretty good, but also take more time and memory
   - [https://github.com/chhylp123/hifiasm](
      https://github.com/chhylp123/hifiasm)
3. raven: not as good as flye, but uses less memory and
   is faster
   - raven sometimes works on OSs were you can not install
     flye
   - [https://github.com/lbcb-sci/raven}(
      https://github.com/lbcb-sci/raven)
4. miniasm: another fast assembler, I never used it much
   - [https://github.com/lh3/miniasm](
      https://github.com/lh3/miniasm)
5. redbean: do not use; raven is better and takes rougly
   the same time and memory

# multie-sequence alingers

1. mafft: what I was taught, works fairly well and is
   often present in respostiories
   - github:
     [https://github.com/GSLBiotech/mafft}(
      https://github.com/GSLBiotech/mafft)
   - web serve that will run it:
     [https://mafft.cbrc.jp/alignment/server/](
      https://mafft.cbrc.jp/alignment/server/)
2. clustal-omega: another multi-sequence aligner, I have
   used it a bit but not much. I think emboss uses it
   - github:
     [https://github.com/GSLBiotech/clustal-omega](
      https://github.com/GSLBiotech/clustal-omega)
   - web serve that will run it:
     [https://www.ebi.ac.uk/jdispatcher/msa/clustalo](
      https://www.ebi.ac.uk/jdispatcher/msa/clustalo)

# Trees:

The phylogenetic software is often complex. So, you will
  need to read manuals to understand it.

The flow for a tree is to align your sequences, then clean
  up the alignment (some GUI programs: aliview, jalview,
  bioedit, ect...). After that you need to use a model
  selection tool to find the best model for your tree.
  Then you can build your tree.

1. raxml: maximum liklihood
  - [https://github.com/amkozlov/raxml-ng](
     https://github.com/amkozlov/raxml-ng)
2. mrbayes: basian
   - [https://github.com/NBISweden/MrBayes](
      https://github.com/NBISweden/MrBayes)
3. iqtree: can build maximum likliehood trees and using
   ultrarapid boostrapping (bit faster)
   - also can do model prediction
   - [https://github.com/iqtree/iqtree2](
      https://github.com/iqtree/iqtree2)
4. beast: I have never used beast, but it is baysian and
   allows you to include dates, location, and other data
   - [https://github.com/beast-dev/beast-mcmc](
      https://github.com/beast-dev/beast-mcmc)
5. graptree: this is a minimum spanning tree, it is not
   good for sequence data, but is good when your data is
   linages (ex: allele 1 or portland strain)
   - An examples of data that works with a minimum
     spanning tree is MLST (multi locus sequence typeing)
     data.
   - there are no models, so you do not need a selection
     step
   - [https://github.com/achtman-lab/GrapeTree](
      https://github.com/achtman-lab/GrapeTree)

# Tree model selection

You need to find a model that fits your data before
  building a tree. Here are some programs that can do
  that.

1. jmodeltest: search for a good tree model, you should
   do this before building a tree
   - [https://github.com/ddarriba/jmodeltest2](
      https://github.com/ddarriba/jmodeltest2)
2. iqtree: can find models (also builds trees), see entry
   in trees section
3. partionfinder: allows having models that split data
   into sections that can have different models
   - [https://github.com/brettc/partitionfinder](
      https://github.com/brettc/partitionfinder)

# AMR detection:

Detect AMRs in sequence data (often consensus). The only
  program I have used in this list is amrFinderPlus. Most
  of these programs were listed on abricates github page.

1. abricate: AMR dection in contigs
   - I never used, but does list several other tools
     from other people that can be used
   - uses consensuses
   - [https://github.com/tseemann/abricate](
      https://github.com/tseemann/abricate)
2. amrFinderPlus or amrFinder: NCBI's amr detection tool
   - Does not install on Mac and likely not Windows
   - uses consensuses
   - [https://github.com/ncbi/amr}(
      https://github.com/ncbi/amr)
3. resfinder: set up for Illumina reads or consensuses
   - [https://github.com/cadms/resfinder](
     https://github.com/cadms/resfinder)
4. srst2: Illumina AMR and MLST (multi locus sequence
   typing)
   - can work with reads
   - [https://github.com/katholt/srst2](
     https://github.com/katholt/srst2)
5. ariba: AMRs in Illumina paired reads and MLST (multi
   locus sequence typing)
   - [https://github.com/sanger-pathogens/ariba](
      https://github.com/sanger-pathogens/ariba)
6. rgi: amr detection in consensus (web portal)
   - [https://card.mcmaster.ca/analyze/rgi](
      https://card.mcmaster.ca/analyze/rgi)

# Compare assemblies:

Some times you need to compare assemblies. Here I do not
  now much.

1. quast or metaquast: is an assembly benchmarking tool
