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

# --- Utility: Get directory path of file ---
getPathForFile() {
    file="$1"

    if [ -f "$file" ]; then
        #directory=$(dirname "$file")
        directory="${file%/*}"

        "$searchAdvisorRecommendationsDirectory/log.sh" "Retrieved directory path: $directory for file: $file"

        printf "%s" "$directory"

        "$searchAdvisorRecommendationsDirectory/log.sh" "Returning directory path: $directory for file: $file"
    fi
}

main() {
    if [ -n "$1" ]; then
        path=$(getPathForFile "$1")

        if [ -n "$path" ]; then
            printf "%s\n" "Directory path: $path"
        else
            printf "%s\n" "No directory found for file: $1"
        fi
    else
        printf "%s\n" "No file provided"
    fi
}

main "$@"
