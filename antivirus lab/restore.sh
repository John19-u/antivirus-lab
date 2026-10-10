#!/bin/bash
dir="$1"
malicious_dir="$2"

if [ -z "$(ls -A "$malicious_dir")" ]; then
    echo "No malicious files to review."
    exit 0
fi

while true
do
    if [ -z "$(ls -A "$malicious_dir")" ]; then
        echo "No malicious files to review."
        exit 0
    fi

    echo ""
    n=1
    for path in "$malicious_dir"/*; do
        echo "$n) $(basename "$path")"
        n=$((n + 1))
    done
    total=$((n - 1))

    read -p "Pick a file number (0 to quit): " num

    if [ "$num" = "0" ]; then
        exit 0
    fi

    if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "$total" ]; then
        echo "Invalid number."
        continue
    fi

    n=1
    for path in "$malicious_dir"/*; do
        if [ $n -eq "$num" ]; then
            file=$(basename "$path")
        fi
        n=$((n + 1))
    done

    echo "1) Restore $file back to $dir"
    echo "2) Permanently delete $file"
    echo "3) Leave it and go back"
    read -p "Choose 1, 2 or 3: " choice

    if [ "$choice" = "1" ]; then
        mv "$malicious_dir/$file" "$dir/$file"
        echo "$file" >> whitelist.txt
        echo "Restored $file to $dir."
    elif [ "$choice" = "2" ]; then
        rm "$malicious_dir/$file"
        echo "$file permanently deleted."
    elif [ "$choice" = "3" ]; then
        continue
    else
        echo "Invalid choice."
    fi
done
