#! /usr/bin/bash
#
# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# ${PIPESTATUS[0]} with a simple $?, but I prefer safety.
set -o errexit -o pipefail -o noclobber -o nounset

# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test > /dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

# option --output/-o requires 1 argument
LONGOPTS=debug,force,output:,verbose
OPTIONS=dfo:v

# -regarding ! and PIPESTATUS see above
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    # then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

d=n f=n v=n outFile=-
# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -d|--debug)
            d=y
            shift
            ;;
        -f|--force)
            f=y
            shift
            ;;
        -v|--verbose)
            v=y
            shift
            ;;
        -o|--output)
            outFile="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

# handle non-option arguments
if [[ $# -ne 1 ]]; then
    echo "$0: A single input file is required."
    exit 4
fi

echo "verbose: $v, force: $f, debug: $d, in: $1, out: $outFile"
#

sourcedir=
destdir=

#for folder in (ls "$sourcedir"); do
#    echo "Creating $folder";
#    mkdir "$destdir/$folder";
#    for file in (ls "$destdir/$folder"); do
#        echo "Copying $file";
#        cp "$folder"/"$file" "$destdir"/"$folder"/;
#    done;
#done

#Actual script here
printf "Starting copy...\n"
for folder in (find -type d -print | sort | cut -c 3- | tail -n +2); do
    printf "\33[2K\r"
    printf "Creating folder $folder\n"
    mkdir "/run/media/arle/AUTORADIO/$folder"
    for file in (ls "$folder"); do
        printf "\33[2K\r"
        printf " Copying %s\r" $file
        cp "./$folder/$file" "/run/media/arle/AUTORADIO/$folder/" 2>/dev/null
    done

done
printf "\33[K2\r"
printf "Done!"
