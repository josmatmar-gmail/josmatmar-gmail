#!/bin/bash
#
# author: github.com/jm-247-ms
# ms.author: v-martinjos@microsoft.com
#
# POSIX-portable, multi-process, fastest-runtime rewrite
# Logging: all output via printf
# Comments: included for all sections

set -euo pipefail

# --- Configurable paths ---
userProfile="/mnt/c/users/v-martinjos"

scriptDirectory="$userProfile/bash/scripts"
searchAdvisorRecommendationsDirectory="$scriptDirectory/searchAdvisorRecommendations"
temporaryDirectory="$scriptDirectory/temporaryFiles"

# --- Utility: Add Directory to List and deduplicate and sort ---
addDirectoryToList() {
    directory="$1"
    
    printf "%s\n" "$directory" >> "$temporaryDirectory/directorylist.tmp.txt"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Added directory to list: $directory"
}

main() {
    if [ -n "$1" ]; then
        addDirectoryToList "$1"
    else
        printf "%s\n" "No directory provided"
    fi
}

main "$@"
