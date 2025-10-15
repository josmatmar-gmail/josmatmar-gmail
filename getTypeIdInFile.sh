#!/bin/bash

set -euo pipefail

dateStamp=$(date +%Y%b%d-%H%M)

userProfile="/mnt/c/users/v-martinjos" # wsl

scriptDirectory="$userProfile/bash/scripts"
outputDirectory="$scriptDirectory/output"

gitDirectory="$userProfile/git"
selfHelpContentDirectory="$gitDirectory/jm-247-ms/SelfHelpContent"
articlesSelfHelpContentDirectory="$selfHelpContentDirectory/articles"

outputfileResourceTypesText="$outputDirectory/$dateStamp-resourceTypes.txt"
outputfileLogText="$outputDirectory/$dateStamp-getResourceTypes-log.txt"

searchFindPattern="*.md"
searchGrepPattern="^\s{0,}\"recommendationResourceType\":"

main() {
    echo "[$(date +%H:%M:%S)] Searching for markdown files..."
    mapfile -t resourceTypes < <(
        find "$articlesSelfHelpContentDirectory" -type f -name "$searchFindPattern" -print0 |
        xargs -0 grep -H -E "$searchGrepPattern" |
        sed -E 's/.*"recommendationResourceType":[[:space:]]*"([^"]*)".*/\1/' |
        sort |
        uniq
    )
    echo "[$(date +%H:%M:%S)] Extracted unique recommendationResourceType values."

    printf "%s\n" "${resourceTypes[@]}" > "$outputfileResourceTypesText"
    echo "[$(date +%H:%M:%S)] Saved results to $outputfileResourceTypesText."

    cat "$outputfileResourceTypesText" | tee -a "$outputfileLogText"
    echo "[$(date +%H:%M:%S)] Done. Log written to $outputfileLogText."
}

time main
