# Goal:

Describe how to move around and delete files in the
  command line.

# Starting

## Open the command line

In a Mac you can open a terminal (the command line) by
  going to Applications->Utilities->terminal. For Windows
  start WSL (should be Ubuntu). I think you can find the
  WSL in start_menu->Ubuntu.

For Linux; the terminal is likely in applications. It may
  be in a folder named system tools or utilities. It may
  also be named xterm.

For Windows, if you need to install WSL, open a
  powershell as administrator. You can do this by
  searching  for powershell, then right click the
  powershell icon and select run as administrator. Then
  type `wsl --install` and hit enter. When the install
  is finished reboot your system and start you Ubuntu
  session (you can search for Ubuntu). For your first time
  you will be prompted for a username and password. You
  will want to remember the password.

# Commands

The command line works by text. You type in a command, hit
  enter, and the command line try's to run the command.
  Remembering all the commands you can enter is difficult
  at first. However, with regular use you start to
  memorize the most used commands. So, To get good at
  command line you have to use command line regularly.

The first thing you will notice in your terminal is your
  user name and computer
  name `<user_name>$<computer_name>`. You may also notice
  a `~` and that the line ends with a `$` or a `:`. The
  `~` means you are in your home directory. The last `$`
  or `:` marks the start of the text you type in.

## Showing files

In a fresh terminal we always start out in our home
  directory (folder). Do `ls` (LiSt) to see what files and
  directories are in here.

You will notice that our Desktop, Downloads, and Documents
  folders are all located in this home directory. There
  are also several hidden files (the file name always
  starts with a `.`) `ls` does not show. These
  are often configuration files, so we will not mess with
  them. You can use `ls -a` to show the non-hidden and
  hidden files.

## Moving around

We can change our working directory (directory we are in)
  to a different directory with `cd` (Change Directory).
  To provide a directory we need to add a space between
  `cd` and the new location (directory).

For the command line, arguments (settings or paths [were
  to go]) are separated by spaces (or tabs). File names
  or directory names with spaces are treated as two
  separate arguments. This is why you should never use
  spaces in file or directory names. You can get around
  this by using the `"`'s (`"<file_name>"`).

Move into the Downloads directory.

Notice how the `<user_name>$<computer_name> ~$` changes
  the `~` to `Downloads`
  (`<user_name>$<computer_name> Downloads$`). This value
  shows at least which folder you are in.

If you ever need to  move back a directory you can do
  `cd ..`. To  move to your home directory you can do
  `cd ~` or `cd "${HOME}"`. These shortcuts do not just
  apply to `cd`, but also apply to other commands, such
  as `ls`, `rm`, `mkdir`, ect ....

For `cd` you can move more then one directory at once. For
  example I can use `cd Downloads/<some_directory>` to
  move from home to some_directory in Downloads.

For `cd` or any other command hitting the tab key once
  will try to autocomplete the command. In cases were
  there is more then one possible file, hitting the tab
  key twice will show all possible files.

## Viewing files

You should use `less` (Mac `more`) to view files you do
  not want to edit. You can open a file
  with `less <file>`. To view commands you can use in less
  you can use `h` (when viewing a file). If you want to
  see the commands for `less` without opening a file use
  `less --help`. This help message is shown in less, so
  you can try each command in real time. When you are done
  with `less` you can use `q` to quite less.

For the command line programs you can generally get a help
  message (how to use) using `--help`, `-h`, `--h`,
  `help`, or `-help`. These messages will often list
  settings you can change. For standard Linux tools the
  help message will be printed with `--help`.

# other commands

I have only showed three commands here. However, there
  are a few more commands you might want to know. Using
  them is similar to `ls` and `cd`. You type the command
  and provide one or more files. You will want to take
  some time to learn these commands.

- Here is a list of some (not all) basic commands:
  - `ls`
    - list all files and directories (folders) in the
      current location
    - use `ls -a` to also show hidden files
  - `cd <new_location>`
    - change from the current directory (folder) to a
      different directory
    - `cd ..` move up one directory
    - `cd ~` or `cd "${HOME}"` move to your home directory
  - `rm <file>`:
    - delete a file
    - use `rm -r <folder>`: to delete a file or folder
  - `cp <file> <new_location>`:
    - copy a file to a new location
    - use `cp -r <directory> <new_location>` to copy a
      folder
    - you can change the name of the copied file or
      directory by doing `<new_location>/<new_name>`
  - `mv <file> <new_location>`:
    - move a file or directory to a new location
  - `mkdir <new_directory_name>`: make a new directory
  - `less <file>`:
    - view a file
    - for Mac use `more <file>` (unless you install less)
  - `pwd`
    - list the location you are at

# Final notes

As always, there is much more to learn and even more
  commands that can be used. We will get into some other
  commands as we continue on. However, we will not cover
  all the commands (only a small part). So, you will have
  to do some of your own self learning to become good at
  command line.

The best way to learn command line is to make command line
  a part of your daily life.
