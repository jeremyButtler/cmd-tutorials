# Goal:

Talk about how to make an electronic notebook.

# Notebook basics

In your course work you have likely taken science lab. In
  these labs you were required to keep a notebook of what
  you did. Possibly at the end of your lab you had to
  write a paper of what you did. Likely, you found you
  needed your notebook to write key parts of the paper.

For bioinformatics, your notebook is likely not on paper,
  but instead may be a text file. This electronic notebook
  will have all the information needed to write your
  paper. However, like any lab notebook it can be for more
  then your paper. You can use the notebook to figure out
  how you did an analysis. Also, you can post it on github
  and provide a link in your paper so others can see what
  what you did.

This means you want your notebook to cover three things.

1. It must be organized
   - You and others do not want to have to dig through a
     mess. It should be easy to see what you did and how.
2. It must include program names and version numbers
   - In your paper you will need to included the programs
     you used and their version numbers. Keeping these in
     your notebooks means you can easily find the version
     later.
3. The obvious, it must include the code you did.
   - Also, it is worth saying what you are trying to do
     with each line of code. This makes it so you can
     understand why you did what you did.

Keeping a notebook is not something that comes naturally.
  To get a good notebook you will need sit down and take
  some time to think about how to organize it. Also, it
  is a format you will develop over time.

# An example

I have my own system. It is not the best system, but it
  is what I found works for me. A better example from me
  is at
  [https://github.com/jeremyButtler/2024-UKR-Banthracis](
   https://github.com/jeremyButtler/2024-UKR-Banthracis).

## My directory organization 

To keep my workflow organized I use the computers sorting
  system to keep files in the order I want to see. In
  sorting the numbers (0 to 9) comes first, then the
  uppercase letters (A to Z), and finally the lowercase
  letters (a to z). Every directory has a number assigned.
  Sorting compares digits (not full numbers), so I make
  sure every number has at least two digits
  (01, 02, 03, ... 10, 11, 12, ... 99). This ensures that
  the folder `00` comes first, then `01`, then `02`.

- Directories and files by numbers
  - `00-scripts` has all the scripts I used or made
  - `00-notes.md` is the markdown file with  my notes
    - for a github it may be renamed to `README.md`
  - `01-input` has all data I downloaded or was given
    - pod5 files or fastq files; if one or more fastq
      files were sent to me
    - Reference sequences
    - Databases (cgMLST, MIRU, others)
  - `02-<name>` to `99-<name>` a step in my analysis, were
    `<name>` is the name of the step

## My notes file

### quick notes on markdown

I use markdown syntax for my notes. Here are some quick
  commands for the markdown syntax.

- In markdown a `#` symbol marks a header
  - The number of `#` symbols tells the level of the
    header
    - Main header `# <header_text>`
    - Sub header `## <header_text>`
    - Sub-sub header `### <header_text>`
- To write bold text do `**<text>**`
- To write italic text do `*<text>*`
- You point list with `- <text>`, were each line in the
  list starts with the `- <text` format
  - you can make a nested list by indenting the `-` to
    the first character in the text
    (add 2 spaces `  - <text>)
  - You can also indent using numbers (`number.` (`1.`))
    or letters (`letter.` (`a.`))
- You can start a code blocks with three graves (\`\`\`\)
  - end a markdown block with three graves (\`\`\`)

Each paragraph in markdown is separated by a blank line.

### My notes

For my notes, the first entry is a brief task. Often this
  is not very good or well worded.

```
# Goal:

Analysis the *B. anthracis* genome sequenced in Ukraine
  during 2024
```

My second entry lists the programs and databases I used
  and there version numbers. When possible I include
  github links or download locations.

```
# Programs

- flye version 2.9.4
- minimap2 2.28-r1209
```

If I am really good I will include a citations section,
  but I often do not do this.

I then have each steps header include the directory number
  and the goal.

```
# 02 assembly

Use flye to build a denov assembly for the *B. anthracis*
  genome from Ukraine.

<code block start>
flye \
    --nano-raw 01-input/01-Banthracis-reads.fastq \
    --out-dir 02-assembly/02-Banthracis-flye;
mv \
    02-assembly/02-Banthracis-flye/assembly.fasta \
    02-assembly/02-Banthracis-flye.fasta;
<code block end>
```

In command line you can break a command into multiple
  lines by adding a `\` symbol to the end of the line.
I am using `<code block start>` and `<code block end>`
  because I can not put three graves (\`\`\`) in a code
  block (it would end it).

The rest of the file is the same format. If I have results
  that I think are important I will add those to the
  markdown file.

# Final comments

Your electronic notebook has three main uses.

1. It tells you what you did so you can write your paper
2. It tells others what you did so they can replicate
   what you did
   - or check if you did a good job
3. It is here to see what you did in the past, allowing
   you to repeat the same analysis in the future
   - or write scripts to do the analysis in the future

Keeping it organized is the most important thing you can
  do. First for you, and then for others. Making sure
  you explain what you do is both for your future self
  and others.
