#!/usr/bin/env sh

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# getRefsByTaxon.sh SOF: Start Of File
#   - get references using taxon ids
#   o sec01:
#     - variable declarations
#   o sec02:
#     - get user input
#   o sec03:
#     - get references from kraken ids
#   o sec04:
#     - merge references into a single fasta file
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec01:
#   - variable declarations
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

taxonIdsStr="";
prefixStr="out";
refDbDirStr="${HOME}/Documents/getAmrsRef";

urlPrefStr="https://eutils.ncbi.nlm.nih.gov/entrez/eutils";

helpStr="$(basename "$0") -taxon <kraken2_taxon_ids>
  - downloads a references for each kraken2 taxon id
Input:
  -taxon <kraken2_taxon_ids>: [Required]
    o taxon ids from kraken2
  -prefix $prefixStr: [Optional]
    o prefix to assign to output (non-database download)
  -ref-db $refDbDirStr: [Optional]
    o database of past references used and current
      references will be downloaded
      * This can take up space, but also is reused on
        future calls
Output:
  - if new reference sequences were downloaded they are
    put into the reference database (-ref-db)
  - <prefix>-refs.fa.gz has the reference sequences for
    each taxon (gziped compressed)
Requires:
  - standard unix tools (curl, sed, gzip, gunzip, ect ...)
  - an internet connection
"

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec02:
#   - get and check user input
#   o sec02 sub01:
#     - get user input
#   o sec02 sub02:
#     - check user input
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#*********************************************************
# Sec02 Sub01:
#   - get user input
#*********************************************************

while [ $# -gt 0 ];
do   # Loop: get user input
   if [ "$1" = "-taxon" ]; then
      shift;
      taxonIdsStr="$1";
   elif [ "$1" = "-prefix" ]; then
      shift;
      prefixStr="$1";
   elif [ "$1" = "-ref-db" ]; then
      shift;
      refDbDirStr="$1";

   elif [ "$1" = "-h" ]; then
      printf "%s\n" "$helpStr";
      exit;
   elif [ "$1" = "--h" ]; then
      printf "%s\n" "$helpStr";
      exit;
   elif [ "$1" = "help" ]; then
      printf "%s\n" "$helpStr";
      exit;
   elif [ "$1" = "-help" ]; then
      printf "%s\n" "$helpStr";
      exit;
   elif [ "$1" = "--help" ]; then
      printf "%s\n" "$helpStr";
      exit;

   else
      printf "%s is not recgonized\n" "$1";
      exit;
   fi;

   shift;
done # Loop: get user input

#*********************************************************
# Sec02 Sub02:
#   - check user input
#*********************************************************

if [ ! -f "$taxonIdsStr" ]; then
   printf "no kraken2 taxon ids for -taxon\n";
   exit;
fi;

if [ "$prefixStr" = "" ]; then
   prefixStr="out";
fi;

if [ "$refDbDirStr" = "" ]; then
   {
      printf "no -ref-db; setting reference database to";
      printf " %s/Documents/getAmrsRef\n" "${HOME}";
   }
   refDbDirStr="${HOME}/Documents/getAmrsRef";
fi;

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec03:
#   - get references from kraken ids
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

while read -r idStr;
do # Loop: get references from genbank
   idStr="$( \
       printf "%s" "$idStr" |
       sed 's/^[ \t]*//; s/[ \t].*//;'
   )"; # remove white space and trailing characters

   if [ "$idStr" = "" ]; then
      continue; # blank line
   fi;

   {
      printf "\n\ngetting a reference for taxid id";
      printf " %s\n\n" "$idStr";
   }

   # get GI ids
   if [ ! -f "$refDbDirStr/$idStr.gi.gz" ];
   then # If: need to get accesion number
      urlStr="$urlPrefStr/esearch.fcgi";
      urlStr="$urlStr?db=nuccore";
      urlStr="$urlStr&term=complete[porgn:__txid$idStr"
      urlStr="$urlStr]refseq[filter]";
      urlStr="$urlStr&idtype=acc"
      curl -g "$urlStr" |
        sed -n 's/^<Id>\([^<]*\).*/\1/p;' |
        gzip -c \
        > "$refDbDirStr/$idStr.gi.gz" ||
      { rm "$refDbDirStr/$idStr.gi.gz";
        printf "chrashed downloading reference\n";
        exit 1;
      };
        # curl grabs converted ids
        # sed removes the filler so I only have
        # accesions gzip compress to reduce file size
   fi;
   
   #***************************************************
   # Sec04 Sub03:
   #   - use first GI id to get the assembly id
   #***************************************************

   giIdStr="$( \
      gunzip -c "$refDbDirStr/$idStr.gi.gz" |
        head -n 1 \
   )";
   # now need to pick one genome from the list, I am
   #  assuming the first will generally be good

   if [ ! -f "$refDbDirStr/$giIdStr.asmId" ];
   then # If: need to get the assembly id
      urlStr="$urlPrefStr/efetch.fcgi";
      urlStr="$urlStr?db=nuccore";
      urlStr="$urlStr&id=$giIdStr"

      curl -g "$urlStr" |
         sed -n \
           '/^[ \t][ \t]*"\(GCF_[^"]*\).*/{
               s/.*\(GCF_[^"]*\).*/\1/p; # assembly id
               q;                        # quit
            }' \
         > "$refDbDirStr/$giIdStr.asmId" ||
      { rm "$refDbDirStr/$giIdStr.asmId";
        printf "chrashed downloading reference\n";
        exit 1;
      };

      asmIdStr="$(cat "$refDbDirStr/$giIdStr.asmId")";

      if [ "$asmIdStr" = "" ];
      then # If: accesion does not have an assembly id
        printf "none\n" > "$refDbDirStr/$giIdStr.asmId";
      fi;  # If: accesion does not have an assembly id
   fi;  # If: need to get the assembly id

   #***************************************************
   # Sec04 Sub04:
   #   - use the assembly id to get all contigs ids
   #***************************************************

   asmIdStr="$( \
      head -n 1 "$refDbDirStr/$giIdStr.asmId" \
   )";

   if [ "$asmIdStr" = "none" ];
   then # If: not downloading a set of genomes
      asmIdStr="$giIdStr";
   fi; # not downloading a set of genomes

   if [ -f "$refDbDirStr/$asmIdStr.fa.gz" ];
   then # If: already have needed fasta file
     {
         printf "already downloaded fasta for taxid";
         printf " %s, which is id\n" "$idStr";
         printf " %s\n" "$asmIdStr";
      }
   else
   # Else: need to still get the genome
      {
         printf "sleep for one second before download";
         printf " to respect NCBI's request of three";
         printf " querys per second\n";
      }
      sleep 1; # sleep for 1 second between downloads

      # get the uid's to download
      urlStr="$urlPrefStr/esearch.fcgi";
      urlStr="$urlStr?db=nuccore";
      urlStr="$urlStr&term=$asmIdStr";
      urlStr="$urlStr&usehistory=y";
      urlStr="$urlStr&retmax=100000";
      curl \
          -g "$urlStr" \
        > "$refDbDirStr/$asmIdStr.xml" ||
        { rm "$refDbDirStr/$asmIdStr.xml";
          printf "chrashed downloading reference\n";
          exit 1;
        };

      #************************************************
      # Sec04 Sub05:
      #   - download all contigs to a fasta file
      #************************************************

      # get the web key and env for the web history and
      # use that to download the fasta files
      webStr="$(\
         sed -n 's/.*<WebEnv>\([^<]*\).*/\1/p;' \
           "$refDbDirStr/$asmIdStr.xml" \
      )";
      keyStr="$(\
         sed -n 's/.*<QueryKey>\([^<]*\).*/\1/p;' \
           "$refDbDirStr/$asmIdStr.xml"\
      )";

      urlStr="$urlPrefStr/efetch.fcgi";
      urlStr="$urlStr?db=nuccore";
      urlStr="$urlStr&query_key=$keyStr";
      urlStr="$urlStr&WebEnv=$webStr";
      urlStr="$urlStr&rettype=fasta";
      urlStr="$urlStr&retmode=text";
      printf "%s\n" "$urlStr";
      
      curl -g "$urlStr" |
        gzip -c \
        > "$refDbDirStr/$asmIdStr.fa.gz" ||
        { rm "$refDbDirStr/$asmIdStr.xml";
          rm "$refDbDirStr/$asmIdStr.fa.gz";
          printf "chrashed downloading reference\n";
          exit 1;
        };

      rm "$refDbDirStr/$asmIdStr.xml";
         # this is a one use file
      {
         printf "sleep for one second to respect\n";
         printf " NCBI's request of three querys per";
         printf " second\n";
      }
      sleep 1; # sleep for 1 second between downloads
   fi; # check if I need to download the genome

   #***************************************************
   # Sec04 Sub06:
   #   - sleep for 1 second between downloads
   #***************************************************

   # add the genome to my list of genomes
   refsStr="$refsStr $refDbDirStr/$asmIdStr.fa.gz";
done < "$taxonIdsStr"
# Loop: get the references

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec04:
#   - merge references into a single fasta file
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

if [ "$refsStr" = "" ]; then
   printf "No references were present\n";
else
   cat $refsStr > "$prefixStr-refs.fa.gz";
   # refsStr is not double qouted because I want expansion
fi;
