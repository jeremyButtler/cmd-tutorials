# Goal:

Install some programs we will be using with the systems
  package manager. Also, download some data from the SRA.

# Package manager

## A quick overview

A package manager is a program that manages the programs
  on your computer. You can use a package manage to search
  for packages, install packages, remove packages, and
  update packages.

Mac does not come with a package mannager that installs
  command line tools. However, you can install the third
  party package manger `homebrew` on Mac. You can find
  `homebrew` at [https://brew.sh](https://brew.sh).

For Linux, your package manager depends on the flavor you
  installed. For Debian bases Linux's, such as Ubuntu,
  Zoronto, Debain, and Mint your package manager is `apt`.
  If your are not using a Debian based Linux you will
  be using a different package manger. Also, you may have
  to install many of the programs your self.

## Homebrew; installing and using 

### Homebrew; installing

On the homebrew home page there is a link you can copy
  to install homebrew.

1. Open a terminal (Applications->utilities->terminal
2. Run the homebrew Install command `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   - You will need to enter your password
3. Run the commands beneath to set homebrew in your path.
   - I am not sure what the
     `eval "$(/opt/homebrew/bin/brew shellenv)"` command
     does

```
# Add hombrew to your path
echo >> ~/.bash_profile;
    >> ~/.bash_profile;
echo 'PATH="$PATH:/opt/homebrew/bin"' \
    >> ~/.bash_profile;
source ~/.bash_profile;

# told to do at end of homebrew setup step
eval "$(/opt/homebrew/bin/brew shellenv)";
```

### Homebrew; using

Here are some basic commands to get you started using
  `homebrew`. There are many more commands. There are
  also multiple settings for the commands I listed here.

You can get the help message for `homebrew` by doing
  `brew help`.

You can search for packages in the home brew repository
  (what can be installed) using `brew search <package>`.
  For example, to find minimpa2 you can use
  `brew minimap2`.

To install a package do `brew install <package>`. For
  example to install minimap2 do `brew install minimap2`.

To remove a package you can do `brew uninstall <package>`.

To upgrade all installed packages you need two steps.
  First you need to update `homebrew` and the list of
  programs (packages) with `brew update`. Then you can
  upgrade all installed packages using `brew upgrade`.

## Debian and Ubuntu package install

For Debian based Linux's, such as Ubuntu, you can install
  and manage packages with `apt`. If you want a TUI (text
  user interface), were you can see all visible packages
  you can install aptitude.

### Debian based; apt

To find a package do `apt-cache search <package>`. For
  example you can search for the `aptitude` package with
  `apt-cache search aptitude`.

To install a package do `sudo apt-get install <package>`.
  You will need to enter your password to install anything
  since the install locations are in locations only the
  root (super user, can do anything) has access to.

To remove a package you can do
  `sudo apt remove <package>`.

To upgrade all packages in `apt` you will need update
  `apt` and its package list and then upgrade. To update
  `apt` do `sudo apt update`. You can then upgrade all
  packages with `sudo apt upgrade`.

### Debian based; aptitude

I have not sued aptitude in a while and some of the
  hotkeys are hard to find. So, I may be wrong on some
  parts of this section.

To search in `aptitude` you
  can start a search by typing `/`. Type what you want to
  search for and then hit enter.

To install a package with `aptitude` you will need to
  start `aptitude` with sudo (`sudo aptitude`). Then
  find your package and hit `+`. When you have selected
  all the packages you want hit `g` to see what you will
  be installing. If you are ok with everything hit `g`
  again. Do not be surprised if selecting one package
  results in installing many packages. This is normal.
 I am not sure how to remove
  packages in `aptitude`, but I suspect it would be
  finding the package and hitting `-`. You would then have
  to use `gg`.

For `aptitude` you will need to start `aptitude` as the
  root user (`sudo aptitude`). Then update `aptitude` and
  its package list by hitting `u`. You can then
  upgrade with `U` (I am not sure). I think you will have
  to hit `gg` to confirm.

# Moving on

Know that you have the commands to install packages, you
  should install some programs we will use in the future.

1. flye (denovo [no reference] assembler)
   - For Linux, I have had issues with the package manager
     not installing everything (fly-samtools). So, we may
     install this from source later.
2. kraken2 (read classifier [what species/family do the
   reads belong to])
   - Some pre-built databases for kraken2 can be found at
     [https://github.com/BenLangmead/aws-indexes/blob/master/docs/k2.md](https://github.com/BenLangmead/aws-indexes/blob/master/docs/k2.md)
   - Download the virus or pathogen plus 8Gb database
     - the pathogen plus 8Gb database is capped at 8Gb, so
       it is smaller, but should run on a Mac
3. minimap2 (read mapper [align reads to a reference])
4. The SRA tools from NCBI. We will want `fastqdump` and
   `prefetch` to download sequences from the SRA.
   - Mac `sratoolkit`
   - Debian based Linux it should be `sra-toolkit`
5. For Mac, download less (better then the default more
   on Mac)


**SOME DATASETS FOR FUTURE, FIND SMALLER TILLING DATASET**

SRA SRX24154503 [SRR28554929] (tiled R10.4 ASFV; also Illumina)
SRA SRX29165785 [SRR33967042] (full genome R9.4)
