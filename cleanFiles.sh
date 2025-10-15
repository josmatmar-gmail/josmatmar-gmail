#!/bin/bash

windowsProfile="/mnt/c/users/v-martinjos"
workingDirectory="$windowsProfile/git/jm-247-ms/selfhelpcontent/articles"
scriptDirectory="$windowsProfile/bash/scripts"
outputDirectory="$scriptDirectory/output"

dateStamp=$(printf "%s" "$(date +%Y%b%d-%H)00")

main() {
    for file in "$outputDirectory/*"; do
        
        currentPath=${file%/*} 
        currentFileLong="${file##*/}"
        currentFileExtension="${currentFileLong##*.}"
        currentFileShort="${currentFileLong%.*}"
        
        lines=`cat $file`
        oldLine=""
        arrayLines=()

        # search each line for value
        # add one value when multiples are grouped
        for line in $lines; do
            if [[ "$oldLine" != "$line" ]]; then
                arrayLines+=("$line")

                if [[ "$debug" -gt "0" ]]; then
                    printf "%s\n" "$line"
                fi

                oldLine=$line
            else
                if [[ "$debug" -gt "0" ]]; then
                    printf "%s\n" "\`$oldLine\` matches \`$line\`"
                fi
            fi
        done

        # remove duplicates and sort array
        readarray -td '' arrayLineSorted < <(printf "%s\0" "${arrayLines[@]}" | sort -uz)

        # output sorted and cleaned list to file
        for sortValue in "${arrayLineSorted[@]}"; do
            printf "%s\n" "$sortValue" >> $currentPath/clean_$currentFileShort.txt
        done
    done
}

main
