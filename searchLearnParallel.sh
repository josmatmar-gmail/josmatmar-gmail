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

gitDirectory="$userProfile/git"
learnAdvisorDirectory="$gitDirectory/jm-247-ms/azure-monitor-docs-pr/articles/advisor"
includesAdvisorLearnDirectory="$learnAdvisorDirectory/includes"

# --- Arrays ---
categoryArray="Cost HighAvailability OperationalExcellence Performance"
stateArray="Active Disabled"

# --- Search for type IDs on Learn in parallel ---
searchLearnParallel() {
    # For each category andstate, check if type ID is present in Learn includes
    for category in $categoryArray; do
        for state in $stateArray; do
            tmpFile="$temporaryDirectory/typeidlist-$category-$state.tmp.txt"
            
            "$searchAdvisorRecommendationsDirectory/log.sh" "Processing category: $category, state: $state with temporary file: $tmpFile"

            [ ! -f "$tmpFile" ] && continue

            while IFS= read -r typeid; do
                # Search in includesAdvisorLearnDirectory for type ID
                found=$(grep -rlF "$typeid" "$includesAdvisorLearnDirectory" || true)

                "$searchAdvisorRecommendationsDirectory/log.sh" "Searching for type ID: $typeid in includes directory, found: $found"

                if [ "$state" = "Active" ] && [ -z "$found" ]; then
                    "$searchAdvisorRecommendationsDirectory/addLearnActiveNotFound.sh" "$typeid"

                    "$searchAdvisorRecommendationsDirectory/log.sh" "Added Learn active not found for type ID: $typeid"
                elif [ "$state" = "Disabled" ] && [ -n "$found" ]; then
                    for foundItem in $found; do
                        "$searchAdvisorRecommendationsDirectory/addLearnDeprecatedFound.sh" "$typeid" "$foundItem"

                        "$searchAdvisorRecommendationsDirectory/log.sh" "Added deprecated found for type ID: $typeid, file: $foundItem"
                    done
                fi
            done < "$tmpFile"
        done
    done
}

main() {
    # Ensure temporary directory exists
    mkdir -p "$temporaryDirectory"

    # Clear previous temporary files
    rm -f "$temporaryDirectory/typeidlist-"*.tmp.txt

    # Start parallel search
    searchLearnParallel

    # Merge and deduplicate results
    "$searchAdvisorRecommendationsDirectory/mergeAndDeduplicate.sh"
}

main "$@"
