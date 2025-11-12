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

# --- Utility: Add deprecated found on Learn ---
addLearnDeprecatedFound() {
    typeid="$1"
    file="$2"

    printf "%s, %s\n" "$typeid" "$file" >> "$temporaryDirectory/learnDeprecatedFound.tmp.txt"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Added deprecated found: type ID: $typeid, file: $file"
}

main() {
    if [ -n "$1" ] && [ -n "$2" ]; then
        addLearnDeprecatedFound "$1" "$2"
    else
        printf "%s\n" "Type ID or file not provided"
    fi
}

main "$@"
