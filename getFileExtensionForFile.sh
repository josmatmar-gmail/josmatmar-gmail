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

# --- Utility: Get extension of file ---
getFileExtensionForFile() {
    file="$1"

    if [ -f "$file" ]; then
        printf "%s" "${file##*.}"

        "$searchAdvisorRecommendationsDirectory/log.sh" "Retrieved file extension: ${file##*.} for file: $file"
    fi
}

main() {
    if [ -n "$1" ]; then
        extension=$(getFileExtensionForFile "$1")

        if [ -n "$extension" ]; then
            printf "%s\n" "File extension: $extension"
        else
            printf "%s\n" "No extension found for file: $1"
        fi
    else
        printf "%s\n" "No file provided"
    fi
}

main "$@"
