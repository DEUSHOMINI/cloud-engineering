#!/bin/bash
shopt -s nullglob
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then 
    echo "Usage: Wrong number of argumetns provided. At least one argument (directory path) has to be provided."
    exit 1
fi


directory_path=$1 
optional_arg=${2:-}
contents=("$directory_path"/*)

if [ ! -d "$directory_path" ]; then 
    echo "Usage: Provided path isn't a directory."
    exit 1 
fi

if ! ls "$directory_path" 2>&1 ; then
    echo "Directory cannot be accessed. Not enough rights"
    exit 1
fi

if [ ${#contents[@]} -eq 0 ]; then
    echo "Dirrectory is empty"  
    exit 1
fi 

if [ ! -z "$optional_arg" ] && [ ! "$optional_arg" = --dry-run ]; then
    echo "Optional argument should be empty or '--dry-run'."
    exit 1
fi

temp_file=$(mktemp)
success=false
trap ' if [ "$success" = false ]; then 
        echo "Script did not complete successfully, removing $temp_file."         
       fi 
       rm -rf "$temp_file" ' EXIT



count_found=0
count_removed=0


while read -r -d '' file_name; do
    echo "$file_name" >> "$temp_file"
    if [ -z "$optional_arg" ]; then  
        rm -rf "$file_name"
        count_removed=$((count_removed+1))
    elif [ "$optional_arg" = --dry-run ] ;then 
        count_found=$((count_found+1))
    fi
    

done < <(find "$directory_path" -type f -mtime +1 -print0)

case "$optional_arg" in 
    --dry-run) echo "[DRY-RUN] Would delete: $count_found files."; cat "$temp_file" ;;
    "") cat "$temp_file"; echo "[DELETED] $count_removed files were removed." ;;
esac
success=true



    