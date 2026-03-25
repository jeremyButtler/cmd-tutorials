# Goal:

Run through my command line tutorials without doing the
  reference pull step.

# Program versions

- kraken2: 2.1.3
- flye: 2.9.6-b1802
- medaka: 2.2.0
  - I used the medaka\_consensus script
- bioTools: 2026-03-04
  - seqById
  - k2TaxaIds

# 02 getting genus in reads

Get read ids for each Genus using kraken2 and k2TaxaIds.

```
if [ ! -d "02-k2" ];
then
   mkdir 02-k2;
fi;

kraken2 \
    --db ../k2_pluspf_8gb/ \
    --report 02-k2/02-k2-report.txt \
    --output 02-k2/02-k2-output.tsv \
    ../SRR28476579.fastq;
```

# 03 get reads for each Genus

Get the reads kraken2 assigned to each Genus using
  seqById.

```
if [ ! -d "03-reads" ];
then
   mkdir 03-reads;
fi;

for strId in 02-k2/02-k2-*.ids;
do
   if [ ! "$strId" ]; then continue; fi;

   outStr="$( \
       basename "$strId" |
       sed 's/02/03-reads\/03/; s/\.ids/.fq/;' \
    )";

    seqById \
       -id "$strId" \
       -fq ../SRR28476579.fastq \
       -out "$outStr";
done;
```

I also got the number of reads kraken2 assigned to each
  Genus.

**TODO: in tutorial 17 in flye install change python
  to python3.**

| Genus               | taxon id | reads  |
|:--------------------|:---------|:-------|
| Staphylococcus      | 1279     | 9443   |
| Enterococcus        | 1350     | 13355  |
| Bacillus            | 1386     | 14292  |
| Listeria            | 1637     | 14822  |
| Limosilactobacillus | 2742598  | 12930  |
| Pseudomonas         | 286      | 11206  |
| Saccharomyces       | 4930     | 1843   |
| Cryptococcus        | 5206     | 2542   |
| Citrobacter         | 544      | 6119   |
| Enterobacter        | 547      | 6088   |
| Escherichia         | 561      | 14998  |
| Klebsiella          | 570      | 6095   |
| Salmonella          | 590      | 21177  |
| Shigella            | 620      | 6307   |
| total               | NA       | 141217 |

Table: reads for each Genus. Found with
  `wc -l <fastq> | awk '{printf $2, $1 / 4;};'`

# 04 build assemblies for each Genus

I am using flye to build assemblies for each detected
  Genus. I am requiring that there be at least 5000 reads.

```
if [ ! -d "04-flye" ];
then
   mkdir 04-flye;
fi;

for strFq in 03-reads/*;
do
    if [ ! "$strFq" ]; then continue; fi;

    outStr="$( \
      basename "$strFq" |
      sed 's/03/04-flye\/04/;
           s/k2TaxaId-/&flye-/;
           s/\.fq//;' \
    )";

    readCntSI="$( \
      wc -l "$strFq" |
      awk '{print $1 / 4;};' \
    )";

    if [ "$readCntSI" -lt 5000 ];
    then
        printf "could not build assembly for %s\n\n" \
          "$outStr" \
          >> 04-flye/04-0flye-log.txt;
        printf "could not build assembly for %s\n\n" \
          "$outStr";
        continue;
    fi;

    printf "building assembly for %s\n" "$outStr" \
          >> 04-flye/04-0flye-log.txt;
    printf "building assembly for %s\n" "$outStr";

    /usr/bin/time \
        -f "\ttime=%e\tmemKb=%M\tcpuPerc=%P" \
        -a \
        -o "04-flye/04-0flye-log.txt" \
    flye \
        --nano-raw "$strFq" \
        --meta \
        --threads 12 \
        --iterations 2 \
        --out-dir "$outStr";

    # I am extracting data from the fly.log file.
    #  the {} group commands together
    #  the ; marks an end of a set command
    sed \
        -n \
        '/Total length:/,/Mean coverage/p; # get flye stats
         /INFO: Reads N50/{s/.*Reads[ \t]/\t/p;};
            # get read N50 (N90 is on same line)
        ' \
      "$outStr/flye.log" \
      >> 04-flye/04-0flye-log.txt;
done;
```

# 05 polish assemblies with medaka

To reduce the number of errors that make it into the
  final assembly I will polish each assembly with medaka.
  I am requiring at least 9x coverage because one assembly
  has 9x. I know that 10x is a good minimum and I suspect
  9x is still decent.

Flow cell used for the dataset was an R9.4.1.

The library was a SQK-RAD004 (rapid kit)

The group does not give me the model they used and the
  paper is not linked. If I had to guess it would be the
  high accuracy model. Nor do they give me the version of
  Guppy they used. When in doubt, go for the older version
  of Guppy. So, I am using the `r941_min_hac_g507` model.

```
if [ ! -d "05-polish" ];
then
   mkdir "05-polish";
fi;

medakaPathStr="${HOME}/Downloads/medaka";

. "$medakaPathStr/venv/bin/activate";

for strAsmDir in ./04-flye/*-flye-*;
do
    if [ ! "$strAsmDir" ]; then continue; fi;

    nameStr="$(basename "$strAsmDir")";

    # get the coverage for each assembly
    coverageSI="$( \
      sed \
        -n \
        "/$nameStr/,/Mean/{/Mean/{s/.*://; s/[ \t]*//g; p;}};" \
        "04-flye/04-0flye-log.txt" \
    )";
       # I get the lines from assembly name (nameStr)
       #   to the mean coverage (Mean)
       # I then only keep the mean coverage line (Mean)

    if [ "$coverageSI" -lt 9 ];
    then
       printf "assembly %s has to low covage (%sx)\n" \
              "$strAsmDir" \
              "$coverageSI";
       printf "assembly %s has to low covage (%sx)\n" \
              "$strAsmDir" \
              "$coverageSI" \
         >> "05-polish/05-0polish-log.txt";
       continue;
    fi;

    printf "polishing assembly %s (%sx coverage)\n" \
              "$strAsmDir" \
              "$coverageSI";
    printf "polishing assembly %s (%sx coverage)\n" \
              "$strAsmDir" \
              "$coverageSI" \
      >> "05-polish/05-0polish-log.txt";

    /usr/bin/time \
        -f "\ttime=%e\tmemKb=%M\tcpuPerc=%P" \
        -a \
        -o "05-polish/05-0polish-log.txt" \
   medaka_consensus \
      -i "../SRR28476579.fastq" \
      -d "$strAsmDir/assembly.fasta" \
      -t 4 \
      -m r941_min_hac_g507;

    if [ ! -d "medaka" ]; then
       continue; # medaka failed
    elif [ ! -f "medaka/consensus.fasta" ]; then
       rm -r "medaka";
       continue; # medaka did not polish
    fi;

    # medaka_consensus always makes a directory named
    #   medaka. Using `-p <prefix>` does not work
    nameStr="$( \
      printf "%s" "$nameStr" |
      sed 's/04/05-polish\/05/; s/flye-/&medaka-/;' \
    )";
    mv medaka/consensus.fasta "$nameStr.fasta";
    rm -r medaka;
done;

deactivate;
```
