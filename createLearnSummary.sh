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
outputDirectory="$scriptDirectory/output"
searchAdvisorRecommendationsDirectory="$scriptDirectory/searchAdvisorRecommendations"
temporaryDirectory="$scriptDirectory/temporaryFiles"
outDateLearnSummaryTxt="$outputDirectory/$dateStamp-learn-summary.txt"

# --- Create Learn summary files ---
createLearnSummary() {
    # Active not found
    if [ -f "$temporaryDirectory/learnActiveNotFound.tmp.txt" ]; then
        sort -u "$temporaryDirectory/learnActiveNotFound.tmp.txt" | while IFS= read -r line; do
            printf "%s\n" "Active and missing from Learn: \`$line\`" >> "$outDateLearnSummaryTxt"

            "$searchAdvisorRecommendationsDirectory/log.sh" "Active and missing from Learn: \`$line\`"
        done
    fi
    # Deprecated found
    if [ -f "$temporaryDirectory/learnDeprecatedFound.tmp.txt" ]; then
        sort -u "$temporaryDirectory/learnDeprecatedFound.tmp.txt" | while IFS= read -r line; do
            printf "%s\n" "Deprecated and found on Learn: \`$line\`" >> "$outDateLearnSummaryTxt"

            "$searchAdvisorRecommendationsDirectory/log.sh" "Deprecated and found on Learn: \`$line\`"
        done
    fi
}

main() {
    # Ensure output directory exists
    mkdir -p "$outputDirectory"

    # Create or clear the output file
    : > "$outDateLearnSummaryTxt"

    # Create Learn summary
    createLearnSummary

    # Log completion
    printf "\n%s\n" "Learn summary created at: $outDateLearnSummaryTxt"
}

main "$@"
