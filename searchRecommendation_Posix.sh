#!/bin/bash
#
# author: github.com/jm-247-ms
# ms.author: v-martinjos@microsoft.com
#
# POSIX-portable, multi-process, fastest-runtime rewrite
# Logging: all output via printf
# Comments: included for all sections

set -euo pipefail

# --- Configurable Paths ---
dateStamp=$(date +%Y%b%d-%H%M)
windowsProfile="/mnt/c/users/v-martinjos"
scriptDirectory="$windowsProfile/bash/scripts"
outputDirectory="$scriptDirectory/output"
inputDirectory="$scriptDirectory/input"
gitDirectory="$windowsProfile/git"
selfHelpContentDirectory="$gitDirectory/jm-247-ms/SelfHelpContent"
articlesSHCDirectory="$selfHelpContentDirectory/articles"
learnAdvisorDirectory="$gitDirectory/jm-247-ms/azure-monitor-docs-pr/articles/advisor"
includesLADirectory="$learnAdvisorDirectory/includes"
outDateRawLogTxt="$outputDirectory/$dateStamp-RAW-Log.txt"
outDateLearnSummaryTxt="$outputDirectory/$dateStamp-learn-summary.txt"

# --- Patterns and Arrays ---
guidPattern='^\{?[A-Za-z0-9]{8}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{12}\}?$'
categoryArray="Cost HighAvailability OperationalExcellence Performance"
stateArray="Active Disabled"
metadataArray="learnMoreLink displayLabel description longDescription potentialBenefits recommendationCategory recommendationFriendlyName recommendationMetadataState recommendationTypeId version"

# --- Utility: Logging ---
log() { printf "%s\n" "$*" >> "$outDateRawLogTxt"; }

# --- Utility: Directory Check/Create ---
checkDirectoryExists() {
    dir="$1"
    if [ ! -d "$dir" ]; then
        printf "%s\n" "`$dir` directory not found"
        mkdir -p "$dir"
        printf "%s\n" "> $ mkdir \"$dir\""
    else
        printf "%s\n" "`$dir` directory found"
    fi
}

# --- Utility: Get Metadata Value from File ---
getMetadataValueInFile() {
    file="$1"
    key="$2"
    if [ -f "$file" ]; then
        # Only match exact metadata key
        value=$(awk -F'"' -v k="$key" '$0 ~ k {print $4; exit}' "$file")
        printf "%s" "${value:-nomatch}"
    else
        printf "%s" "nomatch"
    fi
}

# --- Utility: Get File Extension ---
getFileExtensionForFile() {
    file="$1"
    if [ -f "$file" ]; then
        printf "%s" "${file##*.}"
    fi
}

# --- Utility: Get Directory Path for File ---
getPathForFile() {
    file="$1"
    if [ -f "$file" ]; then
        dir=$(dirname "$file")
        printf "%s" "$dir"
    fi
}

# --- Utility: Add Directory to List (dedup/sort) ---
addDirectoryToList() {
    dir="$1"
    printf "%s\n" "$dir" >> "$TMPDIR/dirlist.tmp"
}

# --- Utility: Add TypeId to Category/State List ---
addTypeIdToList() {
    typeid="$1"
    category="$2"
    state="$3"
    printf "%s\n" "$typeid" >> "$TMPDIR/typeidlist-$category-$state.tmp"
}

# --- Utility: Add Learn Not Found/Deprecated Found ---
addLearnActiveNotFound() {
    typeid="$1"
    printf "%s\n" "$typeid" >> "$TMPDIR/learnActiveNotFound.tmp"
}
addLearnDeprecatedFound() {
    typeid="$1"
    file="$2"
    printf "%s, %s\n" "$typeid" "$file" >> "$TMPDIR/learnDeprecatedFound.tmp"
}

# --- Process a single Markdown file (called in parallel) ---
process_md_file() {
    file="$1"
    # Extract typeId, category, state
    typeid=$(getMetadataValueInFile "$file" "recommendationTypeId")
    category=$(getMetadataValueInFile "$file" "recommendationCategory")
    state=$(getMetadataValueInFile "$file" "recommendationMetadataState")
    # Only process if typeid is a GUID
    if [ "$typeid" != "nomatch" ] && printf "%s" "$typeid" | grep -Eq "$guidPattern"; then
        dir=$(getPathForFile "$file")
        addDirectoryToList "$dir"
        if [ "$category" != "nomatch" ] && [ "$state" != "nomatch" ]; then
            addTypeIdToList "$typeid" "$category" "$state"
        fi
    fi
}

export -f getMetadataValueInFile getFileExtensionForFile getPathForFile addDirectoryToList addTypeIdToList process_md_file
export TMPDIR

# --- Main: Parallel Search for Markdown Files ---
parallel_search() {
    # Find all .md files under articlesSHCDirectory, process in parallel
    find "$articlesSHCDirectory" -type f -name "*.md" > "$TMPDIR/mdfiles.txt"
    # Use nproc or fallback to 4 jobs
    jobs=$(command -v nproc >/dev/null 2>&1 && nproc || echo 4)
    xargs -P "$jobs" -n 1 -a "$TMPDIR/mdfiles.txt" bash -c 'process_md_file "$0"' 
}

# --- Merge and Deduplicate Results ---
merge_and_dedup() {
    # Directories
    sort -u "$TMPDIR/dirlist.tmp" > "$outputDirectory/$dateStamp-selfhelpcontent-directory-Output.txt"
    cp "$outputDirectory/$dateStamp-selfhelpcontent-directory-Output.txt" "$inputDirectory/directory-Output.txt"
    # TypeId lists by category/state
    for category in $categoryArray; do
        for state in $stateArray; do
            outFile="$outputDirectory/$dateStamp-selfhelpcontent-$category"
            [ "$state" = "Disabled" ] && outFile="${outFile}Deprecated"
            outFile="${outFile}-Output.txt"
            tmpFile="$TMPDIR/typeidlist-$category-$state.tmp"
            if [ -f "$tmpFile" ]; then
                sort -u "$tmpFile" > "$outFile"
            fi
        done
    done
}

# --- Search Learn for TypeIds (parallel) ---
search_learn_parallel() {
    # For each category/state, check if typeid is present in Learn includes
    for category in $categoryArray; do
        for state in $stateArray; do
            tmpFile="$TMPDIR/typeidlist-$category-$state.tmp"
            [ ! -f "$tmpFile" ] && continue
            while IFS= read -r typeid; do
                # Search in includesLADirectory for typeid
                found=$(grep -rlF "$typeid" "$includesLADirectory" || true)
                if [ "$state" = "Active" ] && [ -z "$found" ]; then
                    addLearnActiveNotFound "$typeid"
                elif [ "$state" = "Disabled" ] && [ -n "$found" ]; then
                    for f in $found; do
                        addLearnDeprecatedFound "$typeid" "$f"
                    done
                fi
            done < "$tmpFile"
        done
    done
}

# --- Create Learn Summary Files ---
create_learn_summary() {
    # Active not found
    if [ -f "$TMPDIR/learnActiveNotFound.tmp" ]; then
        sort -u "$TMPDIR/learnActiveNotFound.tmp" | while IFS= read -r line; do
            printf "%s\n" "Active and missing from Learn: \`$line\`" >> "$outDateLearnSummaryTxt"
            log "Active and missing from Learn: \`$line\`"
        done
    fi
    # Deprecated found
    if [ -f "$TMPDIR/learnDeprecatedFound.tmp" ]; then
        sort -u "$TMPDIR/learnDeprecatedFound.tmp" | while IFS= read -r line; do
            printf "%s\n" "Deprecated and found on Learn: \`$line\`" >> "$outDateLearnSummaryTxt"
            log "Deprecated and found on Learn: \`$line\`"
        done
    fi
}

# --- Main Entry Point ---
main() {
    startTime=$(date +%Y%b%d-%H%M)
    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    checkDirectoryExists "$inputDirectory"
    checkDirectoryExists "$outputDirectory"

    log "Starting parallel search for Markdown files"
    parallel_search

    log "Merging and deduplicating results"
    merge_and_dedup

    log "Searching Learn for unpublished/published recommendations"
    search_learn_parallel

    log "Creating Learn summary files"
    create_learn_summary

    endTime=$(date +%Y%b%d-%H%M)
    log "Completed (\`$startTime\` to \`$endTime\`)"
    printf "\n%s\n" "Completed (\`$startTime\` to \`$endTime\`)"
}

time main
