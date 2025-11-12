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

# --- Patterns ---
guidPattern='^\{?[A-Za-z0-9]{8}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{12}\}?$'

# --- Process a single markdown file in parallel ---
processMarkdownFile() {
    file="$1"

    # Extract type ID, category, state
    typeid=$("$searchAdvisorRecommendationsDirectory/getMetadataValueInFile.sh" "$file" "recommendationTypeId")

    "$searchAdvisorRecommendationsDirectory/log.sh" "Retrieved type ID: $typeid from file: $file"

    category=$("$searchAdvisorRecommendationsDirectory/getMetadataValueInFile.sh" "$file" "recommendationCategory")

    "$searchAdvisorRecommendationsDirectory/log.sh" "Retrieved category: $category from file: $file"

    state=$("$searchAdvisorRecommendationsDirectory/getMetadataValueInFile.sh" "$file" "recommendationMetadataState")

    "$searchAdvisorRecommendationsDirectory/log.sh" "Retrieved state: $state from file: $file"

    # Only process if type ID is a GUID
    if [ "$typeid" != "nomatch" ] && printf "%s" "$typeid" | grep -Eq "$guidPattern"; then
        directory=$("$searchAdvisorRecommendationsDirectory/getPathForFile.sh" "$file")

        "$searchAdvisorRecommendationsDirectory/log.sh" "Retrieved directory path: $directory for file: $file"

        "$searchAdvisorRecommendationsDirectory/addDirectoryToList.sh" "$directory"

        "$searchAdvisorRecommendationsDirectory/log.sh" "Added directory to list: $directory"

        if [ "$category" != "nomatch" ] && [ "$state" != "nomatch" ]; then
            "$searchAdvisorRecommendationsDirectory/addTypeIdToList.sh" "$typeid" "$category" "$state"

            "$searchAdvisorRecommendationsDirectory/log.sh" "Added type ID to list: $typeid, category: $category, state: $state"
        fi
    fi
}

main() {
    if [ -n "$1" ]; then
        processMarkdownFile "$1"
    else
        printf "%s\n" "No file provided to process"
    fi
}

main "$@"
