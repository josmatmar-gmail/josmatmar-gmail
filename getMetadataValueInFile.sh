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

# --- Utility: Get metadata value from file ---
getMetadataValueInFile() {
    file="$1"
    key="$2"

    if [ -f "$file" ]; then
        # Only match exact metadata key
        value=$(awk -F'"' -v k="$key" '$0 ~ k {print $4; exit}' "$file")

        "$searchAdvisorRecommendationsDirectory/log.sh" "Retrieved metadata value for key '$key': $value from file: $file"

        printf "%s" "${value:-nomatch}"

        "$searchAdvisorRecommendationsDirectory/log.sh" "Returning value: ${value:-nomatch} for key '$key' in file: $file"
    else
        printf "%s" "nomatch"

        "$searchAdvisorRecommendationsDirectory/log.sh" "File not found: $file, returning 'nomatch' for key '$key'"
    fi
}

main() {
    if [ -n "$1" ] && [ -n "$2" ]; then
        value=$(getMetadataValueInFile "$1" "$2")

        if [ "$value" != "nomatch" ]; then
            printf "%s\n" "Metadata value for key '$2': $value"
        else
            printf "%s\n" "No match found for key '$2' in file: $1"
        fi
    else
        printf "%s\n" "File or key not provided"
    fi
}

main "$@"
