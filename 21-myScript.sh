#!/bin/sh

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 20-myScript.sh SOF: Start Of File
#   - quick example script to run kraken2 and k2TaxaIds in
#     sh
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

fqFileStr="$1";     # fastq file the user should input
dbDirStr="$2";      # database for kraken2
prefixStr="delete"; # what to call everything; in this
                    #  this is a demo script so I want to
                    #  remind my self to delete the files

kraken2 \
    --db "$dbDirStr" \
    --output "$prefixStr-k2-output.tsv" \
    --report "$prefixStr-k2-report.txt" \
    "$fqFileStr";

k2TaxaIds \
    -report "$prefixStr-k2-report.txt" \
    -id "$prefixStr-k2-output.tsv" \
    -out "$prefixStr-k2-taxaId";

# I often put something to about the program in the file
#   name so I can keep track of what programs were used
#   to get the file. That is why you see me using k2 and
#   taxaId.
