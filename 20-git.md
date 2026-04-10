# Goal:

Learn how to use git to update a repository

# Introduction:

At some point you will have to share your analysis notes
  with others. While the SRA (sequence read archive) may
  offer a place to share data and Genbank (nuccore) offers
  a place to share genomes, they do not offer a place
  to share your notes.

Github, gitlab, codeberg are examples of places were
  programmers put code they wish to share with others. We
  can also use these places to share our notes.

Github is the most popular of the three I mentioned. The
  others (more then listed) are used by the foss (free and
  open source software) community wishing to get away from
  github.

# Set up your ssh key:

For github and likely the others you will need to setup
  your ssh session. Otherwise you will not be able to
  update your repositories from the command line. Also,
  you will not be able to access private repositories.

- For github see:
  - [https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent](
     https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
  - [https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account](
     https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
- For codeberg see:
  - [https://docs.codeberg.org/security/ssh-key/](
     https://docs.codeberg.org/security/ssh-key/)

# Add your repository:

For ssh you can not use the url (starts with `https://`).
  Instead you need to do `git@<site>`.

For github you need to make a new repository on the
  webpage and then follow the instructions. For any
  instruction that uses
  `https://github.com/<user_name/<repository_name>` change
  it to `git@github.com:<user_name>/<repository_name>`.

If you mess up you can do `rm -r .git*` to reset
  everything.

You will also want to add a License to your repository. If
  you do not use a license then you are using the most
  restrictive license possible.

This is an area were you have to figure out what each
  license means before using it.

# Ignoring files

It is likely you will have some large files in your
  repository (ex fastq files). At the end of your project
  these files should be put on the SRA. Since these files
  are large you will not want to store these on github
  also. Instead you can provide the SRA accession number
  in your notes.

To avoid large files, such as fastq files, getting pushed
  into your repository you can use a `.gitignore` file.
  The `.gitignore` file tells git what files to not send.
  The `.` at the start means it is a hidden file.

The `.gitingore` file lists the files or directories you
  wish to ignore. You can use globs (`*`) to get multiple
  files. You can use `#` to start a comment
  (human only lines).

An example of a `.gitingore` file:

```
# avoid uploading the fastq file
01-input/01-SRR28476579.fastq
03-k2-reads/*.fq

# I want to ignore the entire directory
04-k2-readsByRef


# flye outputs a lot of files I will not use. These can
#   take up a lot of space, so best to ignore these

# k2TaxaId read id pull flye assemblies
05-flye-k2Pull/*/00*
05-flye-k2Pull/*/10*
05-flye-k2Pull/*/20*
05-flye-k2Pull/*/30*
05-flye-k2Pull/*/40*
05-flye-k2Pull/*/.g*
05-flye-k2Pull/*/*.txt
05-flye-k2Pull/*/*.json
05-flye-k2Pull/*/*.log

# the flye output has a lot of heavy data
06-flye-k2Pull/*/00*
06-flye-k2Pull/*/10*
06-flye-k2Pull/*/20*
06-flye-k2Pull/*/30*
06-flye-k2Pull/*/40*
06-flye-k2Pull/*/.g*
06-flye-k2Pull/*/*.txt
06-flye-k2Pull/*/*.json
06-flye-k2Pull/*/*.log
```

# Adding files

You can add files or directories with `git add <file>`.
  To add all files and directories do `git add *`.

You can then use `git commit -m "<message>"` to commit
  the changes. You can also select the files to add using
  `git commit`. The files that are not being pushed will
  be commented out (start with a `#`). In vi use `:q` to
  quite and `x` to delete a `#`. If you are in a mode
  (you will see visual or insert at the bottom left of
  your screen) hit escape to get out of the mode.

If you need to delete a file from a commit list you can do
  `git rm -f <file>`. The `-f` forces the delete. If the
  file is not in your your commit list you can do
  `git rm <file>`.

If you need to remove a file from your commit list, but
  not delete it you can use `git rm --cached <file>`.

After setting up your commits you can push your updates
  using `git push` (your ssh key must be configured
  first).

# Final thoughts

At this point you should be able to maintain a repository
  on a site like github. This will act as a place to store
  your notes. For problems you will encounter with git
  (there will be problems) it is best to do a web search.
