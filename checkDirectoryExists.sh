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

# --- Utility: Directory verification and creation ---
checkDirectoryExists() {
    directory="$1"

    if [ ! -d "$directory" ]; then
        printf "%s\n" "\`$directory\` directory not found"

        "$searchAdvisorRecommendationsDirectory/log.sh" "Directory not found: $directory"

        mkdir -p "$directory"

        "$searchAdvisorRecommendationsDirectory/log.sh" "Created directory: $directory"

        printf "%s\n" "> $ mkdir \"$directory\""

        "$searchAdvisorRecommendationsDirectory/log.sh" "Directory created: $directory"
    else
        printf "%s\n" "\`$directory\` directory found"

        "$searchAdvisorRecommendationsDirectory/log.sh" "Directory exists: $directory"
    fi
}

main() {
    if [ -n "$1" ]; then
        checkDirectoryExists "$1"
    else
        printf "%s\n" "No directory provided"
    fi
}

main "$@"
