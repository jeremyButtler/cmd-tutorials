# Goal:

Describe why the command line is important to me and why
  I think it is still relevant any one working in
  biology today.

# An important note

Using the command line is like using a bicycle. A bicycle
  is not easy at first. It takes months to learn. However,
  once you have spent the months or years to learn to ride
  a bike it comes naturally. At first command line is
  difficult, but with pratice it becomes second nature.

I can not teach you to be good at command line, because
  to be good requires using the command line a lot. I can
  only teach you the base skills for you to build off of.

# Reason:

I find three reasons for why I value the command line and
  why I think most people in biology should learn it.

1. The command line is reproducible
2. The command line is flexible
3. The command line is often more efficient

## Reproducible

When you write the methods section of a paper you must
   describe each step you used. For a GUI this would
   require mentioning every menu and every setting you
   changed. For example, in EPI2ME version XXX I used the
   kraken2 analysis. I changed the database to the
   pathogen plus database. Other settings go here.

For command line it would be, I used kraken2 version XXX
  and input the pathogen plus database using --db. The
  report was saved with --report and the output with
  --output. Other settings go here.

From the GUI description I have to figure out how to
  navigate the GUI. For the command line version I add in
  the flags (ex --db) and the files/settings they should
  have. After doing this I have rebuilt the original
  command.

```
kraken2 \
    --db <pathogen_plus_database> \
    --report <report.tsv> \
    --output <output.tsv> \
    <reads.fastq>;
```

For command line I can do even better by saving the
  kraken2 command in a markdown file. I can then post
  this markdown file on github for readers to look at.
  This allows the reader to see what I did.

Here is an example of a repository were I did this
  [https://github.com/jeremyButtler/2024-UKR-Banthracis](
   https://github.com/jeremyButtler/2024-UKR-Banthracis).

## Flexible

When I am run a GUI I am stuck with what the analysis
  does. I may be able to run additional programs, but I
  am limited to what the GUI(s) provided.

On the command line I can run an analysis or I can break
  it into the individual pecies and do my own custom
  analysis. Sometimes I may use Unix tools along the way
  to reformat files for the next step or do additional
  analysis's.

Once I get an analysis setup I can save it in a bash
  script. If I setup the bash script to process user
  input, then I can then rerun my new analysis on
  different files. This increases the tools I have in
  my tool kit.

## Efficient

Putting my analysis in a script that takes in user input
  allows me to reuse the analysis. In a GUI I would have
  to repeat the same steps every time. On command line I
  only need to call my script to run my analysis.

On the command line I can use a loop to go through all
  files in a directory. Every command in the loop will
  be run on each file. The loop allows me to run my
  analysis on all files in a directory. So, if I have a
  hundred fastq files to process, I can write a script
  to analize one fastq file. I can then call that script
  from a loop to analize all hundred fastq files. I can
  then walk away while the analysis is running.

To do this same thing by GUI often requires me to run each
  fastq file separately. This is very time consuming and
  tedious.

For example, I could get the stats for all fastq files in
  a directory using.

```
for fastq_file in ./"<path_to_fastq_directory>"/*.fastq;
do
  if [ ! -f "$fastq_file" ];
  then
     continue;
  fi;

  prefix="$(basename "$fastq_file" | sed 's/\.fastq//;')";
  NanoStat --fastq "$fastq_file" --prefix "$prefix-stats.tsv";
done;
```

Here is a version of the previous commands with comments
  (`#`) to explain what I am doing. I do not expect you
  to understand this.

```
# for loop loops for for each item in the condition
#  - "for" is the command to start a for loop
#  - "fastq_file" holds each fastq file, you can use any
#    name
#  - "in" means for all items in the next part
#  - "./<path_to_fastq_directory>"/*.fastq is all fastq
#    files in <path_to_fastq_directory"
#    - "./" means from you current location
#    - "./<path_to_fastq_directory>" is the location of
#       the fastq file from your current location
#    - "*.fastq" means all files ending in ".fastq"

for fastq_file in ./"<path_to_fastq_directory>"/*.fastq;
do # marks start of commands to use in the loop
  if [ ! -f "$fastq_file" ];
  then # commands in the if statement come after this
     continue; # fastq_file is not file, move to next file

     # -f: checks to see if the path is a file
     # ! -f: means if not a file
     # fastq_file: is the file we are using
     # the [ ] are used for conditionals. The spaces
     #   around the braces are needed
     # The logic for an if statement is
     #   if [ <conditional> ]; then <commands>; fi;
  fi; # need to mark the end of the if statement

  # The $ symbol is used to access a variables contents.
  #   In this case I want to get the file name stored in
  #   fastq_file, so I use $fastq_file.
  # Sometimes file names may have spaces (bad form), so
  #   we use "'s ("$fastq_file) to tell bash this is one
  #   item and not multiple.


  #______get the prefix from the input fastq file_________
  prefix="$(basename "$fastq_file" | sed 's/\.fastq//;')";
     # <variable>="value" means store this value in the
     #   variable
     # "$(<commands>)" means run this command and return
     #   the result
     # fastq_file has the file path to our fastq file
     # basenames gets the file name from the file path
     # sed removes the .fastq ending of the fastq file

  #_____get_the_stats_for_our_fastq_file__________________
  NanoStat --fastq "$fastq_file" --prefix "$prefix-stats.tsv";
     # NanoStat is a program to get N50, median Q-score,
     #   mean Q-score, and other stats from a fastq file.
     #   They say they are outdated, but the replacment
     #   they provide does not work on fastq files.
     # fastq_file is the file were are getting stats for
     # prefix is the file name we want to save the file as
done; # marks the end of the loop (move to next file)
```
