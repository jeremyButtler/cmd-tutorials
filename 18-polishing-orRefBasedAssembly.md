# Goal:

Learn how to polish an assembly using reference based
  assemblers. You can do a similar method to build
  reference based assemblies.

# Introduction:

In the last episode we went over how to build a denovo
  assembly. The next step you might do is to polish your
  assembly using a reference based assembly.

Polishing an assembly uses the same steps as making a
  reference based assembly. The only difference is in
  polishing the assembly is used as the reference. In
  an reference based assembly a reference sequence is
  used.

Another method for building an assembly would be to polish
  reads. This method works well if your organism, such as
  a virus, is small enough for a single read to cover the
  genome. Another area it may work well for is when you
  know were each read belongs, such as when sequencing
  tiling primer amplicons.

Tiling primers are primers that overlap. The primers are
  split into at least two pools to prevent the overlap
  regions from amplifying. With tiling you can amplify
  smaller genomes (Ex: 29kb in SARS-Cov2). The con is
  that your primers may not always be good matches for
  every variant, thus they may not always work. The other
  problem is the sequence samples must have a similar
  genome structure (genes in similar places) as the
  reference.

An example of tiling primers:

```
Genome  : atgccagctagacctgattgaaggctgcattaaaagcccctt
Primer 1: ^-------------^
Primer 2:          ^-------------^
Primer 3:                   ^-------------^
Primer 4:                            ^-------------^

Pool 1: Primer_1, Primer_3
Pool 2: Primer_2, Primer_4
```

- Here is an example of building a genome by polishing
  reads
  1. Pick a long read that covers the genome
     - Or pick a set of long reads you can merge
  2. Polish read or reads
  3. If you have more then one read you will need to
     stitch them together to get an assembly
     - You can use a somewhat close reference to find were
       the polished reads might be on the genome, then
       use the coordinates to merge the reads

# Assemblers:

There are many reference based assemblers (I am including
  tools to make vcf (variant calling files) out there.
  Here is a list of the few I happen to know of.

- Non-tiling
  - Medaka: ONTs large language variant caller pipeline,
    can be used to build a consensus with the Medaka
    consensus script
    - From my experience this tool is good for read
      polishing, but can have a reference pull for SNPs
    - [https://github.com/nanoporetech/medaka](
       https://github.com/nanoporetech/medaka)
  - Clair3: A large language variant caller
    - From my experience clair3 has similar performance
      to Medaka
    - Installation can be a pain
      - The docker install is a pain to use
    - [https://github.com/HKU-BAL/Clair3](
       https://github.com/HKU-BAL/Clair3)
  - Longshot: variant caller (you convert vcf to sequence)
    - easy to install
    - From my experience longshot has more reference pull
      then clair3
    - [https://github.com/pjedge/longshot](
       https://github.com/pjedge/longshot)
  - Ivar: Uses output from samtoosl mpileup to make a
    consensus
    - From my experience ivar is not good for read
      polishing, but it is ok for consensus polishing or
      reference based assemblies
    - Has no SNP bias because ivar has no idea what the
      reference sequence looks like.
    - Has a reference pull on insertions and deletions
    - Bit more complicated to use (more program calls),
      but I trust it more for reference based assemblies
    - [https://github.com/andersen-lab/ivar](
       https://github.com/andersen-lab/ivar)
- Tiling:
  1. Artic: uses a reference to build the assembly
     - Uses Clair3 (used to include medaka)
     - Filters out amplicons that may be transcripts
       by requiring both primer sites (an no more) be
       present
     - Can have reference pull for SNPs, so make sure your
       genome is at least 95% similar (very likely is)
     - [https://github.com/artic-network/fieldbioinformatics](
        https://github.com/artic-network/fieldbioinformatics)
  2. Lilo: polishes a read for each amplicons then
     stitches the polished reads with scaffold builder
     - Scaffold builder uses the reference genome to
       stitch the amplicons together
       - Make sure your reference is at least 95% similar
         to your target or use a different program to
         stitch the amplicons together
       - Scaffold builder has a Needleman alignment step
         that kicks in if the reference is two different
         (around 10%). In one case I have seen this
         Needleman step create a large number of
         insertions.
     - [https://github.com/amandawarr/Lilo](
        https://github.com/amandawarr/Lilo)

For me, I do not do tilling systems that much. I know
  Artic is popular, however, the small amount of reference
  pull on SNPs does worry me.

For read polishing, I would recommend Medaka or Clair3.
  From my past tries I have found ivar does poorly here.
  I have not tested using racon to polish a read and then
  ivar to polish the consensus.

For assembly polishing I would recommend Medaka or clair3.

# Installing Medaka

Look at the install section of medaka's github repository
  [https://github.com/nanoporetech/medaka](
   https://github.com/nanoporetech/medaka) to figure out
  how to install medaka. The first install (uses pip)
  should work for you.

I am installing medaka to my downloads directory. You can
   do this by changing `python3 -m venv medaka` to
   `python3 -m venv ~/Downloads/medaka`.

If you can not install medaka after you can check to see
  my install notes beneath. A good habit for Linux is to
  keep track of the steps you did to install each program.
  You notes will help you when you get a new computer or
  reinstall Linux. Instead of trying to remember what you
  did, you can check your notes.

My install:

I followed ONTs instructions and made a python virtual
  environment using `python -m venv <location>`. I made
  the virtual environment in my Downloads folder.
  `python -m venv ~/Downloads/medaka`

A virtual environment is a lunchbox or container for
  programs.  Each lunchbox or container has its own lunch
  (programs) inside it. The idea is that no lunchbox
  overlaps (each has its own lunch). You can activate
  (open the lunchbox) a python virtual environment by
  running the activate script.

```
If a programs lunchbox is open, then we are using the
  program.
        __ ___
        \_^ _/        ____ 
        /_v_/|       /-B-/|
     ___| ^ ||_______|   ||___________
    /   |___|/       |___|/          /|
   / Medaka lunch  Flye lunch       /||
  /     open         closed        / ||
 /  rest of system is always open /|_|/
/________________________________/
| ||                          | || 
| ||                          | || 
|_|/                          |_|/ 

```

I then activated the virtual environment (opened the
  medaka lunchbox) with medaka using
  `. ~/Downloads/medaka/bin/venv/activate`. If this does
  not work on Mac, then try
  `. ~/Downloads/medaka/bin/activate`.

I next updated the pip in the medaka environment using
  ONTs instructions (`pip install --upgrade pip`).

Finally I used ONTs instructions to install medaka with
  pip (`pip install medaka`). You can exit out of a
  virtual environment using `deactivate`.

All the commands together look like:

```
python -m venv ~/Downloads/medaka;
. ~/Downloads/medaka/bin/venv/activate;
  # for Mac may be: . ~/Downloads/medaka/bin/activate;
pip install --upgrade pip;
pip install medaka;
deactivate; # get out of the medaka environment
```

# Using Medaka

There are several programs that come with medaka. I only
  have used the `medaka_consensus` script. This script
  takes a fastq file and reference sequence. The output
  is a folder with the consensus sequence.

Before running medaka you will have to activate the medaka
  environment using
  `. <path/to/medaka>/bin/venv/medaka/activate`. For Mac
  it path may be `. <path/to/medaka>/bin/medaka/activate`.

You can exit the medaka environment using `deactivate`.

Get the help message for `medaka_consensus` (the help
  message uses the `help` flag). The help message will
  take a few seconds to print. Once you get the help
  message see if you can figure out how to use medaka to
  polish our assembles. I have listed what the models for
  medaka mean in the next couple paragraphs.

Our dataset was run on minion with a R9.4 flow cell. We do
  not have the model used for basecalling in the fastq
  header (SRA removes this), so you will have to pick the
  model.

Most models names I see in in are based of the parameters
  used in dorado (older guppy). Here is the basic
  template I often see
  `<flow_cell>_<device>_<model_accuracy>_<guppy_version>`.

- The flow cell does not have dots in the name, so for
  example, `r9.4.1` becomes `r941`
- For devices, ONT shortens the name, so minion becomes
  `min` and promethion becomes `pro`
- For the model, `hac` is the high accuracy model and
  `sup` is the supper accuracy model
  - I can not remember what the fast model is
- For guppy version, it starts with a `g` and then the
  version number (ex: `g507`)
  - If medaka does not have your version of guppy, it is
    often better to go with an older guppy version then
    a guppy that is newer then  your data
    then a version 

Sadly the version of guppy used was not listed on the SRA.
  Nor was the paper linked in. So, I am assuming they used
  high accuracy base calling. I also went with the 507
  model, which was for an older version of guppy.

## My medaka command

The first step I did was to look up the model I needed to
  use with medaka. I need a model for a minion (min)
  R9.4.1 flow cell (r941) that was basecalled with the
  high accuracy model (hac). I also need an older version
  up guppy (g507). Combing this together I get the
  `r941_min_hac_g507 model`.

For my reference sequence I am using the denovo assembly
  I made with flye.

For medaka\_consensus the flags I need to use are; `-i`
  for the fastq file, `-d` for the reference sequence, and
  `-m` for the model. I can also add more threads with the
  `-t` flag.

In my case I was a bit lazy and used the full set of reads
  instead of the reads I pulled using minimap2 and
  k2TaxaId. This might improve depth, but also could allow
  similar species to be included in the polishing step.
  So, there is a chance I am adding error by not using
  the pulled reads.

Putting this all together for the reference pulled
  assembly I get:

```
mkdir 07-polish
. ~/Downloads/medaka/bin/venv/activate;
   # open the medaka environment (lunch box)
medaka_consensus \
   -i 01-input/01-SRR28476579.fastq \
   -d 06-flye-refBin/06-zymo-k2-map-NC000929-flye.fa \
   -m r941_min_hac_g507;
mv \
    medaka/consensus.fasta \
    07-polish/07-zymo-k2-map-NC000929-flye-polish.fa;
rm -r medaka; # remove other files and old directory.
```

# Final thoughts

At this point you should have an idea of what polishing is
  and how to polish a genome with medaka. The goal of
  polishing is to improve the accuracy of an assembly.

You can see the polish-notes.md file for something close
  to my current notes. It is a bit different because I
  had to redo this tutorial. It also is less commented
  then I might do for this tutorial.
