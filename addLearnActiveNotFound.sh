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

# --- Utility: Add active not found on Learn ---
addLearnActiveNotFound() {
    typeid="$1"

    printf "%s\n" "$typeid" >> "$temporaryDirectory/learnActiveNotFound.tmp.txt"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Added Learn active not found for type ID: $typeid"
}

main() {
    if [ -n "$1" ]; then
        addLearnActiveNotFound "$1"
    else
        printf "%s\n" "No type ID provided"
    fi
}

main "$@"
