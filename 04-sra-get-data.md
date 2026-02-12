# Goal:

Setup your notebook for your bioinformatics run.

# Introduction

To use do bioinformatics we first need some biology data
  to do bioinformatics on. We can get data that past
  researchers have submitted to NCBI's sequence read
  archive (SRA). However, even before that we first should
  setup our notebook and go over text editors.

# Setting up your notebook

Before downloading data we should take some time to set
  up our electronic notebook. Hopefully you have taken
  some time to think about how to organize your notebook.
  If not, you can follow along with my format.

## Make the notebook folder

First, create a new directory to hold your files. Using
  the date of creation at the start of the name will allow
  easier organization later, but is not needed. If you
  have forgotten the commands, use the notes from a
  episode 01, a search engine, or a LLM (large language
  model [ex: a chat bot]) to figure the command out.

Here is the command I did. I added in a few extra
  directories that I always use. Only view this command
  after you have made your own directory or can not figure
  it out.

```
# everything after a `#` symbol is a comment and is
#   ignored by the command. These comments are here for
#   your
cd ~/Downloads; # ~ gets me to my home directory
mkdir 2026-02-11-demo;
  # mk = MaKe; dir = DIRectory; mkdir = make directory
  # using the year-month-day format means the years are
  #   grouped with the same years and the months are
  #   always grouped with the same months
cd 2026-02-11-demo;
mkdir 00-scripts; # holds any scripts I used that would
                  # be difficult to get or are custom
mkdir 01-input;   # holds my input files
```

## Make the notes file

You will also want to add a file to keep notes in. For
  this it will help to have two terminals open. You can
  likely open a new terminal if you go to the menu bar
  in your terminal.

In the new terminal you start in your home directory. Move
  to the notebooks directory you made.

At this point we can make (or open) the notes file using
  a command line text editor. In this case I will be using
  `nano`. You can open a file (including a new file) with
  nano by doing `nano <file_name>`. If you want mouse
  support in `nano` you can do `nano --mouse <file_name>`. 

Open your notes file with nano. For me this is
  `nano 00-notes.md`.

At the bottom of nano you have two lines that show the
  most common options you can use. Any command starting
  with a `^` uses the control key (ex: `^k` is control k).
  Any command starting with `M-` uses the the alt key
  (ex: `M-U` is alt u).

To type text in nano you start typing. You can move around
  (up, down, right, and left) with the arrow keys.

You can copy a line by using `M-6` (alt 6). Or you can cut
  a line using `^K` (control k). You then paste the copied
  or cut text using `^U` (control u).

You can save a file with `^O` (control o).

You can exit nano with `^X` (control x). When you exit and
  have unsaved changes nano will ask you if you want to
  save. Hit `y` for yes, `n` for no, and `^C` (control c)
  for cancel.

Nano is not my normal text editor, vim is. However, nano
  is simpler then vim. So, nano is a better fit for the
  tutorials. Vim has a very steep learning curve. So if
  you do want to try it plan on taking two to three weeks
  to get used to vim. An easier option is Emacs, which
  starts out with a lower learning curve but gets more
  complex as you go.

For nano I am going to start my notes with these three
  lines. In this the syntax is markdown, so a `#` means a
  header.

```
# Goal:

Show new command line users how to run kraken2, flye
  and other bioinformatic tools.

# Programs

# 01 input

Download the ASFV data set from the SRA the new
  users will use to learn flye and kraken2.
```
