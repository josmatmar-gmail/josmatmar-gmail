#!/bin/bash
#
# author: github.com/jm-247-ms
# ms.author: v-martinjos@microsoft.com
#
# POSIX-portable, multi-process, fastest-runtime rewrite
# Logging: all output via printf
# Comments: included for all sections

set -euo pipefail

userProfile="/mnt/c/users/v-martinjos"

scriptDirectory="$userProfile/bash/scripts"
searchAdvisorRecommendationsDirectory="$scriptDirectory/searchAdvisorRecommendations"
temporaryDirectory="$scriptDirectory/temporaryFiles"

gitDirectory="$userProfile/git"
selfHelpContentDirectory="$gitDirectory/jm-247-ms/SelfHelpContent"
articlesSelfhelpcontentDirectory="$selfHelpContentDirectory/articles"

userProfile="/mnt/c/users/v-martinjos"

# --- Main: search for markdown files in parallel ---
parallelSearch() {
    # Find all .md files under articlesSelfhelpcontentDirectory, process in parallel
    find "$articlesSelfhelpcontentDirectory" -type f -name "*.md" > "$temporaryDirectory/markdownFiles.txt"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Found $(wc -l < "$temporaryDirectory/markdownFiles.txt") markdown files to process"

    # Use nproc or fallback to 4 jobs
    jobs=$(command -v nproc >/dev/null 2>&1 && nproc || echo 4)

    "$searchAdvisorRecommendationsDirectory/log.sh" "Using $jobs parallel jobs for processing"

    xargs -P "$jobs" -n 1 -a "$temporaryDirectory/markdownFiles.txt" bash -c "$("$searchAdvisorRecommendationsDirectory/processMarkdownFile.sh" "$0")"

    "$searchAdvisorRecommendationsDirectory/log.sh" "Parallel search completed for markdown files"
}

main() {
    parallelSearch
}

main "$@"
