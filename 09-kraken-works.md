# Goal:

Learn how kraken2 can help in data exploration. Why you
  should be careful with read classifiers. And how to use
  kraken2.

# Intro:

Kraken2 is a read classifier. Read classifiers can be used
  to identify which species your reads belong to. If a
  species can not be found then the family is assigned. If
  the family can no be assigned then the Genus. This
  continues on until the after kingdom, past which there
  is only the unclassified bin to assign a read to.

To understand how kraken2 can error out we should first
  talk about how kraken2 works. My understanding is not
  very good here, so I will likely get some points wrong.

## Kmers and minimizers

Kraken2 and works by using kmers. A kmer is a sequence of
  characters, such as nucleotides. The `k` in kmer is the
  number of items in the sequence. For example to codon
  table uses three bases per amino acid. Each codon is a
  3mer.

Kraken2 uses unique kmers between genomes to identify what
  species or other taxonomic level a read belongs to. This
  allows use to not store entire genomes, but this also
  reduces the amount of information we have. For example,
  if we used 3mers we would only have 64 combinations.
  With 64 3mers We could never assign a single 3mer to
  anything over 64 bases long. To solve this kraken2 uses
  35mers, which have 4^^35^^ combinations.

I have not been able to fully figure out minimizers. From
  what I can see, one way to think of them is to think of
  a kmer as a system were each base is assigned a number.
  Say a is 0, T is 1, G is 2, and C is 3. You can combine
  the numbers for each base to get a unique number for
  each kmer.

An example of converting a codon going to a number would
  be ctg. In our example c will go to 3 (binary 11), t
  will go to 1 (binary 01), and g will go to 2 (binary
  10). Combing all bases together we get the binary number
  `11 01 10`. In base 10 `11 01 10` is
  `32 + 16 + 4 + 2 = 54`.

To find a 31mer minimizer for a 35mer, we compare the
  number of minimizers for all 31mers in the 35mer (four
  total). The 31mer with the lowest value in the 35mer is
  the minimizer. Kraken2 has a few more conditions on the
  minimizer, but this is the basics of minimizers (I
  think).

After getting the 31mer minimizers, kraken2 then checks if
  the 31mer is distinct (unique to a species, family,
  ...). 31mers that are not unique for a call are
  discarded. This leaves us with a database that has
  multiple unique 31mers for each species. We can hunt for
  these 31mer minimizers in the read. If enough 31mers are
  found the read is assigned to a species, family, ...,
  or kingdom. If to few minimizers are found or a read can
  not be assigned, the read is unclassified.

## Hashing for more speed

It is ok if you do not understand minimizers. I am also
  having a hard time with this concept. If you also having
  a hard time replace the word minimizers with kmers.

At this point we have a database of unique 31mer
  minimizers.  However, we still need to scan through each
  read and find the matching 31mers. Think of this problem
  like a library of books. Each book has a title and the
  species, family, ..., or kingdom call for that
  31mer. Our goal is to get the titles (31mers) in the
  read and then find their books which have the species
  to assign.

| title | species or family |
|:------|:------------------|
| ttt   | *Escherichia*     |
| tga   | *Bacillus*        |
| atg   | *E. coli*         |
| ccc   | *B. anthracis*    |
| ccg   | *B. canis*        |

Table: Using a random species assigned to random 3mers
  as an example. Each 3mer is the title of the species
  book. The contents of each book is the species name.
  Kraken2 uses 31mers (3mers would never work).

At a first glance we could sort the titles alphabetically
  and make a catalog. However, this can become slow when
  we have thousands of reads and each read has tens or
  hundreds of titles. A quicker method would be to convert
  each title to a number and have that number be the
  location of the book. The problem we have is that we
  need 4^^31^^ titles to cover all possible 31mers. This
  is well beyond our library (computer hard drive) size.
  It also includes many many titles that we will never
  see.

A solution to this potential title problem is to reduced
  the titles number down to the number of books. We can do
  this by finding the titles number and then keeping only
  the number of digits of books in our library.

Lets say we have a library of five books. Each title is
  made of three letters (nucleotides). Three nucleotides
  would mean we need our library to be able to hold
  4^^3^^ (64) books. This is not an good use of space.

| title | assignment     | binary   | number |
|:------|:---------------|:---------|:-------|
| ttt   | *Escherichia*  | 01 01 01 | 21     |
| tga   | *Bacillus*     | 01 10 00 | 24     |
| atg   | *E. coli*      | 00 01 10 | 6      |
| ccc   | *B. anthracis* | 11 11 11 | 63     |
| ccg   | *B. canis*     | 11 11 10 | 62     |

Table: Some random species as an example with the title
  numbers. Notice how we have 63 possible titles, but
  only have three books. We would like to have a smaller
  library. For binary, a = 00 (0), t = 01 (1), g = 10 (2),
  and c = 11 (3).

We could reduce our library of five books down to four
  shelf's by taking the modulo of kmers number and 4. We
  then assign the result of the modulo to the shelf. A
  modulo is the remainder (ex: 3 mod 4 = 1; 9 mod 4 = 1).

| title | assignment     | binary   | number | number mod 4 |
|:------|:---------------|:---------|:-------|:-------------|
| ttt   | *Escherichia*  | 01 01 01 | 21     | 1 (21 - 4x5) |
| tga   | *Bacillus*     | 01 10 00 | 24     | 0 (24 - 4x6) |
| atg   | *E. coli*      | 00 01 10 | 6      | 2 (6 - 4)    |
| ccc   | *B. anthracis* | 11 11 11 | 63     | 3 (63 - 4x15)|
| ccg   | *B. canis*     | 11 11 10 | 62     | 2 (62 - 4x15)|

Table: The example books reduced to a hash (binary).
  Notice how *E. coli* and *B. canis* get the same hash.

Once we have the modulo, we can setup our library (hash
  table) with four shelf's. In this library (hash table)
  not all shelf's will have a book.

| book shelf | title | contents       | title | contents   |
|:-----------|:------|:---------------|:------|:-----------|
| 0          | tga   | *Escherichia*  | none  | empty      |
| 1          | ttt   | *Bacillus*     | none  | empty      |
| 2          | atg   | *E. coli*      | ccg   | *B. canis* |
| 3          | ccc   | *B. anthracis* | none  | empty      |

Table: The example book shelf with hashing.

One problem that can come from hashing is there are times
  when more then one book may be assigned to a single
  shelf. For example, we assigned the codons atg
  (*E. coli*) and ccg (*B. canis*) to shelf 2 (a
  collision). When we find a read that has the atg or ccg
  kmers (title) we will need to look through all titles on
  the shelf (linear probing) to see if the kmer was from
  *E. coli* or *B. canis*.

In our simple case hashing may not seem very fast.
  However, when you have thousands of titles spread across
  thousands of shelf's with only a few collisions, hashing
  can be very fast.

This book shelf example is an example of hashing. Kraken2
  uses hashing to speed up the search time for not 3
  books, but thousands.

## Compact hashing for smaller databases

kraken2 has one  more trick up its sleeve. To reduce
  memory usage kraken2 will reduce the 31mer title down to
  a much smaller title (roughly 32000 possible titles or
  15 bits). Kraken2 does this by saving only highest five
  digits of the title (a compact hash). This compact
  hashed title is what is in the database.

To build a compact hash for our bookshelf example lets
  take the last letter of each codon and make that our
  title.

| book shelf | title | contents                 |
|:-----------|:------|:-------------------------|
| 0          | a     | *Escherichia*            |
| 1          | t     | *Bacillus*               |
| 2          | g     | *E. coli* or *B. canis*  |
| 3          | c     | *B. anthracis*           |

Table: We compact hashed the title by taking the last base
       in the codon. atg and ccg goes to g, ccc goes to
       c, tga goes to a, while ttt goes to t. This is an
       extreme example of a compact hash (smaller title)
       collision. Most of the time you would have have
       more then one compact hash (shortened title) per
       self.

For the next part, I am likely wrong here, but this is how
  I understand it.

By using compact hashes there is a small chance of one
  title can represent multiple species. To reduce this
  chance kraken2 finds all possible titles in a read. Then
  kraken2 can use all the titles in the read to make a
  decision about the read.

For example, a read may have a title belonging to the
  *Escherichia* family (shelf 0). The other title in the
  read may belong to the *E. coli*  and *B. canis* species
  (shelf 2). Kraken2 could use the family title to decide
  which species title the read belongs to. In this case
  *E. coli* belongs to the *Escherichia* family, but
  *B. canis* does not. So, the read belongs to *E. coli*.

| book shelf | title | contents                | in read |
|:-----------|:------|:------------------------|:--------|
| 0          | a     | *Escherichia*           | yes     |
| 1          | t     | *Bacillus*              | no      |
| 2          | g     | *E. coli* or *B. canis* | yes     |
| 3          | c     | *B. anthracis*          | no      |

Table: Since the read is in both the *Escherichia* family
  and the *E. coli* species or *B. canis* species.
  *B. canis* is not in the *Escherichia* family so the
  read can not be from the *B. canis* species. This means
  the read it must be from the *E. coli* species since
  *E. coli* is in the *Escherichia* family.
  
I am pretty sure I have parts of kraken2 wrong. However, I
  hope this less then accurate example gives you an idea
  of how kraken2 works.

## Masking

The final thing I know about in kraken2 is the masking
  step. I am not sure what this fully does, but my
  impression is that it sets certain positions at the end
  of the minimizer to any value. When the look up is done,
  multiple keys are looked up instead of one.

```
ctgacc
 |         find minimizer
 v
tgac
 |         mask
 V
t*ac

Look up any key of four bases that starts with a "t" and
  ends with a "ac".
```

Again, I am not really sure what is going on here, but
  this is how I understand masking. I am likely wrong.

# Possible errors

Kraken2 is limited by what is in its database. For
  example, if you used a database of only viruses you will
  never detect bacteria. So, kraken2 can not detect new
  species. Or at least those new species must be close
  enough to be miss-assigned to the old species.

The other problem is that horizontal gene transfer can
  transfer genes or sections of a genome between species.
  For example a bacteria phage might take parts of the
  host genome. In these cases kraken2 would have a hard
  time distinguishing between host and viral reads.

# A solution

Because kraken2 can miss-classify you should not use it
  for the "final answer". Instead kraken2 is tool that is
  good for exploring your dataset. Kraken2 is good for
  seeing what species may be in your community. It is your
  job to confirm if kraken2 is right or wrong. Think of
  kraken2 as a tool to make hypotheses about what you
  have.

Using kraken2 for exploration in this way is better then
  having a pile of reads that you have no idea what belong
  to. Once you have a list of potential microbes in your
  community you can start to test if these community
  members are really there. The method I use for this is
  to pull out reads and build assemblies or consensuses.
  However, there are likely many more methods.
