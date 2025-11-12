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
dateStamp=$(date +%Y%b%d-%H%M)

userProfile="/mnt/c/users/v-martinjos"

scriptDirectory="$userProfile/bash/scripts"
inputDirectory="$scriptDirectory/input"
outputDirectory="$scriptDirectory/output"
searchAdvisorRecommendationsDirectory="$scriptDirectory/searchAdvisorRecommendations"
temporaryDirectory="$scriptDirectory/temporaryFiles"

# --- Arrays ---
categoryArray="Cost HighAvailability OperationalExcellence Performance"
stateArray="Active Disabled"

# --- Merge and deduplicate results ---
mergeAndDeduplicate() {
    # Directories
    sort -u "$temporaryDirectory/directorylist.tmp.txt" > "$outputDirectory/$dateStamp-selfhelpcontent-directory-Output.txt"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Merged and deduplicated directory list: $outputDirectory/$dateStamp-selfhelpcontent-directory-Output.txt"

    cp "$outputDirectory/$dateStamp-selfhelpcontent-directory-Output.txt" "$inputDirectory/directory-Output.txt"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Copied directory output to input directory: $inputDirectory/directory-Output.txt"

    # Type ID lists by category and state
    for category in $categoryArray; do
        for state in $stateArray; do
            outFile="$outputDirectory/$dateStamp-selfhelpcontent-$category"

            "$searchAdvisorRecommendationsDirectory/log.sh" "Processing category: $category, state: $state"

            [ "$state" = "Disabled" ] && outFile="${outFile}Deprecated"

            "$searchAdvisorRecommendationsDirectory/log.sh" "Output file for category: $category, state: $state is $outFile"

            outFile="${outFile}-Output.txt"

            "$searchAdvisorRecommendationsDirectory/log.sh" "Final output file: $outFile"

            tmpFile="$temporaryDirectory/typeidlist-$category-$state.tmp.txt"

            "$searchAdvisorRecommendationsDirectory/log.sh" "Temporary file for category: $category, state: $state is $tmpFile"

            if [ -f "$tmpFile" ]; then
                sort -u "$tmpFile" > "$outFile"

                "$searchAdvisorRecommendationsDirectory/log.sh" "Merged and deduplicated type ID list: $outFile"
            fi
        done
    done
}

main() {
    # Ensure output directory exists
    mkdir -p "$outputDirectory"

    # Create or clear the output files
    : > "$outputDirectory/$dateStamp-selfhelpcontent-directory-Output.txt"

    for category in $categoryArray; do
        for state in $stateArray; do
            outFile="$outputDirectory/$dateStamp-selfhelpcontent-$category"

            [ "$state" = "Disabled" ] && outFile="${outFile}Deprecated"

            outFile="${outFile}-Output.txt"

            : > "$outFile"
        done
    done

    # Merge and deduplicate results
    mergeAndDeduplicate

    # Log completion
    printf "\n%s\n" "Merge and deduplication completed at: $outputDirectory/$dateStamp-selfhelpcontent-directory-Output.txt"
}

main "$@"
