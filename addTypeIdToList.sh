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

# --- Utility: Add type ID to category and state list ---
addTypeIdToList() {
    typeid="$1"
    category="$2"
    state="$3"

    printf "%s\n" "$typeid" >> "$temporaryDirectory/typeidlist-$category-$state.tmp.txt"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Added type ID to list: $typeid, category: $category, state: $state"
}

main() {
    if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
        addTypeIdToList "$1" "$2" "$3"
        printf "%s\n" "Added type ID: $1, category: $2, state: $3"
    else
        printf "%s\n" "Type ID, category, or state not provided"
    fi
}

main "$@"
