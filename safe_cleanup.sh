#!/bin/bash
shopt -s nullglob
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then 
    echo "Usage: Wrong number of arguments provided. At least one argument (directory path) has to be provided."
    exit 1
fi


directory_path=$1 
optional_arg=${2:-}

if [ ! -d "$directory_path" ]; then 
    echo "Usage: Provided path isn't a directory."
    exit 1 
fi

contents=("$directory_path"/*)

if [ ! -r "$directory_path" ] || [ ! -x "$directory_path" ] ; then
    echo "Directory cannot be accessed. Not enough rights"
    exit 1
fi

if [ ${#contents[@]} -eq 0 ]; then
    echo "Directory is empty"  
    exit 1
fi 

if [ ! -z "$optional_arg" ] && [ ! "$optional_arg" = --dry-run ]; then
    echo "Optional argument should be empty or '--dry-run'."
    exit 1
fi

temp_file=$(mktemp)
success=false
trap 'if [ "$success" = false ]; then 
        echo "Script did not complete successfully, removing $temp_file."         
       fi 
       rm -f -- "$temp_file" ' EXIT



count_removed=0

mapfile -d '' -t file_names < <(find "$directory_path" -type f -mtime +1 -print0)
printf '%s\n' "${file_names[@]}" > "$temp_file"
    for f in "${file_names[@]}" ; do
    if [ "$optional_arg" != "--dry-run" ]; then  
        if rm -- "$f" ; then 
        count_removed=$((count_removed+1))
        fi
    fi
    done 
    
case "$optional_arg" in 
    --dry-run) echo "[DRY-RUN] Would delete: ${#file_names[@]} files."; cat "$temp_file" ;;
    "") cat "$temp_file"; echo "[DELETED] $count_removed files were removed." ;;
esac
success=true



    