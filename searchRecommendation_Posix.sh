#!/bin/bash
#
# author: github.com/jm-247-ms
# ms.author: v-martinjos@microsoft.com
#
# POSIX-portable, multi-process, fastest-runtime rewrite
# Logging: all output via printf
# Comments: included for all sections
#
# lastrun 2025-08-04
# ---
# real    8m45.870s
# user    7m46.277s
# sys     4m13.753s

set -euo pipefail

# --- Configurable paths ---
userProfile="/mnt/c/users/v-martinjos"

scriptDirectory="$userProfile/bash/scripts"
inputDirectory="$scriptDirectory/input"
outputDirectory="$scriptDirectory/output"
searchAdvisorRecommendationsDirectory="$scriptDirectory/searchAdvisorRecommendations"
temporaryDirectory="$scriptDirectory/temporaryFiles"

# --- Main entry point ---
searchRecommendation() {
    startTime=$(date +%Y%b%d-%H%M)

    "$searchAdvisorRecommendationsDirectory/checkDirectoryExists.sh" "$inputDirectory"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Start processing Markdown files in input directory: $inputDirectory"

    "$searchAdvisorRecommendationsDirectory/checkDirectoryExists.sh" "$outputDirectory"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Start processing Markdown files in output directory: $outputDirectory"

    "$searchAdvisorRecommendationsDirectory/checkDirectoryExists.sh" "$temporaryDirectory"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Start processing temporary files in directory: $temporaryDirectory"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Start parallel search for markdown files"
    "$searchAdvisorRecommendationsDirectory/parallelSearch.sh"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Merge and deduplicate results"
    "$searchAdvisorRecommendationsDirectory/mergeAndDeduplicate.sh"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Search Learn for unpublished active and published deprecated recommendations"
    "$searchAdvisorRecommendationsDirectory/searchLearnParallel.sh"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Create Learn summary files"
    "$searchAdvisorRecommendationsDirectory/createLearnSummary.sh"

    endTime=$(date +%Y%b%d-%H%M)

    "$searchAdvisorRecommendationsDirectory/log.sh" "Completed (\`$startTime\` to \`$endTime\`)"

    printf "\n%s\n" "Completed (\`$startTime\` to \`$endTime\`)"
}

main() {
    searchRecommendation
}

time main "$@"
