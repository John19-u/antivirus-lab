#!/bin/bash
dir="$1"
malicious_dir="$2"

cd "$(dirname "$0")"

extensions="exe bat vbs scr ps1"
keywords="virus trojan malware worm ransomware"

mkdir -p "$malicious_dir"

scan() {
    for path in "$dir"/*; do
        if [ ! -f "$path" ]; then
            continue
        fi

        file=$(basename "$path")

        if [ -f whitelist.txt ] && grep -qxF "$file" whitelist.txt; then
            continue
        fi

        bad=0

        ext="${file##*.}"
        for e in $extensions; do
            if [ "$file" != "$ext" ] && [ "$ext" = "$e" ]; then
                bad=1
            fi
        done

        for k in $keywords; do
            if grep -qi "$k" "$path"; then
                bad=1
            fi
        done

        if [ $bad -eq 1 ]; then
            echo "$file is malicious and it is DELETED"
            cp "$path" "$malicious_dir/$file"
            rm "$path"
        fi
    done
}

ls -l "$dir" > directory-info.new

if [ ! -f directory-info.last ] || ! diff -q directory-info.last directory-info.new > /dev/null; then
    scan
    cp directory-info.new directory-info.last
fi
