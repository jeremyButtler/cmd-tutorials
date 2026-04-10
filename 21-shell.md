# Goal:

Learn how shell scripts can be used to build pipelines and
  automate some of your analysis.

In this tutorial we will talk about setting up a shell
  script.

# Introduction:

One of the strengths of the command line is that you can
  store all the commands you use in a file. By using a
  file you can then share the steps you did in your
  analysis with someone else. That someone else can then
  repeat your analysis by then copy you commands into the
  command line.

You can even use those notes for your own personal use in
  the future. One example of future use might be to
  convert your analysis into a script. With this script
  you can turn your analysis from a one time analysis to
  a generalized tool that you use on other datasets.

Shell allows use to easily convert a series of commands
  into a shell script. You have already been using shell
  without even realizing it because shell is your command
  line. Shell is what takes in your commands and coverts
  them to something the computer can understand.

```
Your command -> shell -> computer language -> output
```

For example:

```
ls -> shell -> 10011010111 -> prints the files in the
                              current directory

The binary is just random numbers because I needed
  something quick to show something the computer might
  understand. In real life is would be many commands.
```

A shell script is a file that is run using the program
  that runs your shell. In this case it is often a program
  named sh (shell), bash (born again shell), zsh (Z shell
  [based off bash]), or the many other shells. Sh is the
  oldest currently used shell. Because of its age, sh is
  the most limited shell. However, the age of sh and the
  POSIX standard (part of what it means to be a Unix)
  means that you can always really on sh being present.
  For this tutorial we will focus on sh, since it is
  always present on a Unix.

To run a shell script we can do `sh <script_name>.sh`.

You can go to
  [https://freebsdfrau.gitbook.io/serious-shell-programming](
   https://freebsdfrau.gitbook.io/serious-shell-programming)
  for a good guide on sh programming.

To make a shell script you put everything you would
  normally type into the command line into a file. You
  can then make the script get get user input to make the
  file (script) reusable.

In this tutorial series we will go over how to make this
  script. In this episode we will show a quick and not
  ideal way to get user input and how to set up your
  script.

# The shebang, the start of a script:

The very first line in your shell script should always be
  a shebang (starts with `#!`). In Unix the shebang tells
  your computer were to look for the program to run your
  script.

In shell, python, and R the `#` symbol is a comment. A
  comment is a line that is for humans only and so, is
  skipped by the program running your script. You can use
  shebangs in any language that treats a `#` as a comment.

To use the sh (shell) language, your shebang should be
  `#!/bin/sh` or `#!/usr/bin/env sh`. Both methods have
  there pros and cons. I will not go into these here since
  I am not experienced enough to understand them.

The shebang with env will search your environment for the
  sh (or any other) program. This works on most systems
  (all modern). However, there is no guarantee that env
  is in `/usr/bin`.

Another problem with env is that it can not take flags.
  So, for example, you can not use
  `#!/usr/bin/env awk -f <awk_scirpt>.f` to run an awk
  script.

The shebang with `/bin/sh` (`#!/bin/bash`) is looking for
  sh in `/bin`. `/bin` is a common location were sh is
  often installed. Like evn, all modern OSs have sh or at
  least a link to sh in `/bin`. However, also like env
  there is no guarantee that sh is in `/bin`.

- Some other shebangs you might find useful:
  - `#!/usr/bin/env python3` to find python3
  - `#!/usr/bin/env Rscript` to find R
    - Rscript runs a script for R

After adding a shebang, you can give your script execute
  permission with `chmod a+x <your_script_name>.sh`. You
  can then run your script with `./<your_script_name>.sh`.

You can also always ignore the shebang and use
  `sh <script_name>.h` to run your script instead.

# Variables:

## Creating variables

In a script you will need to get and store the user input
  in something. Otherwise you will not be able to access
  it later. In programming we use variables to store data.
  For sh a variable can store strings (words) or numbers.

In sh you can declare a variable by doing
  `variable="value"`. Were variable is what you want to
  name the variable and value is what you want to store
  in the variable.

For example I can do: `prefixStr="some_prefix";` to store
  the prefix I expect to use for my output file names.

In sh spaces are treated as separators for arguments. So,
  you can not have spaces between the `variable`, the `=`,
  and the `"<value>"`.

- Examples of wrong and correct variable calls:
  - `variable="<value>";` is correct
  - `variable = "<value>";` is wrong
  - `variable= "<value>";` is wrong
  - `variable ="<value>";` is wrong

If we have spaces in the value we wish to use it will be
  treated as a separate argument or command. To avoid this
  we can use `"`'s around the to tell sh that the spaces
  are part of the value.

- Examples:
  - `variable="hi by";` is correct
  - `variable=hi by;` is wrong
    - I got `-bash: by: command not found`
  - `variable=hi printf "by\n";` is wrong
     - For me it ignored `variable=hi` and then ran
       `printf "by\n"` (print by to terminal)

## Getting values from a variable

I can get the contents of a variable by using the `$`
  symbol. For example I can do `printf "%s\n" "$variable"`
  to print the contents of a variable. In this case printf
  is an example of a command. Another example of a command
  might be `kraken2 --db "$dataBaseStr"`.

When accessing a variable (getting the contents) you
  should always make sure the variable is in `"`'s. The
  `"`'s are used to make sure that sh or other programs do
  not think spaces stored in the variable are separate
  arguments or commands.

- Accessing a variable:
  - `new_var="$variable";` correct
  - `new_var=$variable ;` could cause future problems
    - if the value in variable has no spaces then you
      would be safe. However, this is still a bad habit.

## Merging variables

In sh we can can merge variables together by having them
  in the same string.

```
#!/usr/bin/env sh

first="hello";
second="by";

printf "%s\n" "$first world. The world says $second.";
```
When merging variables you should be careful that the
  character after a variable is not a valid variable name
  (A-Z, a-z, 0-9, and `_`). Otherwise bash will merge the
  characters together to build a new variable name. This
  new variable will exits, but have nothing in it.

For example:

```
#!/bin/sh

first="hello";
second="by";

printf "%s\n" "$first_world. The world says $second.";
```

The shell will think I am accessing the variable
  `first_world` instead of `first`.  The problem is that
  `first_world` does not exist. As a result the variable
  `first_world` is created and the value is set to
  nothing. This gives me `. The world says by.`. To avoid
  this error we can put the variable names in `{}`'s.

For example:

```
#!/bin/sh

first="hello";
second="by";

printf "%s\n" "${first} world. The world says ${second}.";
```

This gives `hello word. The world says by.".

## Getting user input

The command line has a special set of variables reserved
  for getting user input. They start at one `$1` and end
  at the last user input item. The zeroth (`$0`) variable
  is reserved to hold the path to your script (your
  scripts name).

For example I can get user input for one item doing:

```
#!/bin/sh

userInput="$1";
printf "%s\n" "$1";
```

For example I can get user input for two items doing:

```
#!/bin/sh

userInput="$1";
userInputTwo="$2";
printf "%s\t%s\n" "$1" "$2";
```

## Printing messages

Since I brought up printf in this episode I should take
  some time to describe what printf does.

For the command line you have many methods of printing
  messages to the terminal. The two common methods are
  printf and echo.

Echo is easier to use `echo "<message>"`, however it does
  not offer the formatting options of printf. Also, unlike
  printf, echo is limited to shell, while printf is found
  in most programming languages.

Printf is used to print out a message to the user. Printf
  has two types of arguments. This first argument is the
  format string to print out. You will never access a
  variable in the first argument. Instead you use a flag
  (ex: `%s`) to mark that a variable should be inserted
  here.

- Some commands for the first argument in printf.
  - `%s` insert variable as a string
    - you can left or right pad strings with this
  - `%i` insert variable as a integer
    - you can use `%02i` to make sure every number has
      at least two digits (padded with 0).
  - `%f` insert variable as a real number (decimal)
    - you can use `%.2f` to only keep two digits past the
      decimal place
  - `\t` a tab
  - `\n` a new line (line break)
    - printf does not add a newline unless told
  - `\\` a `\`
  - `%%` a `%` symbol

The second and later arguments in printf are the variables
  to access.

```
#!/bin/env sh

userInput="hello word";
userInputTwo="1.52345";
printf "%s\t%.2f\n" "$1" "$2";

# the output of printf is "hellow world	1.52"
```

# Applying this

At this point you should have a good idea of how to make
  a basic bash script. Take what you have learned here to
  build a bash script the runs kraken2 and k2TaxaIds.

After you get the script made make sure to allow for the
  user to provide input. Think about the inputs you might
  need.

While doing this think about how you want to organize
  your files. Do you want a dozen k2TaxaId files in the
  main directory or do you want to store them in a folder.

Another thing you should do is to make sure your variable
  names mean something. They should be more then `a`, `b`,
  `c`, .... A future you (most important) or future user
  should be able to look at your variable names and
  understand them.

One helpful tip of advice; you can add a `\` to the end of
  a line to tell sh to merge the lines (treat as one
  line). This can be helpful when commands get to long.
  When breaking lines you should indent the next commands
  (use a tab or two to eight spaces) to tell future users
  that these commands are on the same line. The only rules
  for indenting are to keep it consistent (mostly) and not
  to mix tabs and spaces.

Not indented (do not do):

```
kraken2 \
--db "database"
```

Indented at four spaces:

```
kraken2 \
    --db "database"
```

# Final thoughts

At this point you should know how to make a very basic
  sh script. To see my script I made for this see
  21-myScript.sh.

We will cover the steps needed to add seqById, flye, and
  medaka in future tutorials. We will also go over how to
  check user input and get user input using flags. The
  flags will allow the user to input values in any order.
