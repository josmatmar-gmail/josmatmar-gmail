#!/bin/bash
#
# author: github.com/jm-247-ms
# ms.author: v-martinjos@microsoft.com

set -euo pipefail

# --- Directories and variables ---
userProfile="/mnt/c/users/v-martinjos" # wsl
scriptDirectory="$userProfile/bash/scripts"
outputDirectory="$scriptDirectory/output"
inputDirectory="$scriptDirectory/input"
dateStamp=$(date +%Y%b%d-%H%M)
dateStampEpoch=$(date +%s)

gitDirectory="$userProfile/git"
selfHelpContentDirectory="$gitDirectory/jm-247-ms/SelfHelpContent"
articlesSelfhelpcontentDirectory="$selfHelpContentDirectory/articles"

outDateRawLogTxt="$outputDirectory/$dateStamp-RAW-Log.txt"

# --- Metadata keys and patterns ---
metadataKeyArray=("recommendationTypeId" "recommendationCategory" "recommendationMetadataState")
guidPattern='^\{?[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12}\}?$'

# --- Arrays to store results ---
declare -A categoryStateMatrixArray   # key: category|state, value: list of unique typeIds
declare -a matchedDirectoriesArray   # directories with matched files

outputToLogFile() {
    # Print message to log file
    printf "%s\n" "$1" >> "$outDateRawLogTxt"
}

getMetadataValueForFile() {
    # string "path to the markdown file" gmvff_parameter_1
    # string "metadata key" gmvff_parameter_2

    outputToLogFile "\`> $ getMetadataValueForFile() \"$1\" \"$2\"\`"

    local gmvff_parameter_1="$1"
    local gmvff_parameter_2="$2"

    local gmvff_metadataValue

    gmvff_metadataValue=$(grep -oP "\"$gmvff_parameter_2\"\s*:\s*\"\K[^\"]+" "$gmvff_parameter_1" | head -n1)

    printf "%s" "$gmvff_metadataValue"

    outputToLogFile "\`> $gmvff_metadataValue\`"
}

getMatrixForArrayByCategoryState() {
    # string "path to the markdown file" ganbcs_parameter_1

    outputToLogFile "\`> $ getMatrixForArrayByCategoryState() \"$1\"\`"

    local ganbcs_parameter_1="$1"

    local ganbcs_category ganbcs_state

    ganbcs_category="$(getMetadataValueForFile "$ganbcs_parameter_1" "${metadataKeyArray[1]}")"

    ganbcs_state="$(getMetadataValueForFile "$ganbcs_parameter_1" "${metadataKeyArray[2]}")"

    local ganbcs_arrayName="${ganbcs_category}|${ganbcs_state}"

    printf "%s" "$ganbcs_arrayName"

    outputToLogFile "\`> $ganbcs_arrayName\`"
}

addDirectoryToArray() {
    # string "path to the markdown file" adta_parameter_1

    outputToLogFile "\`> $ addDirectoryToArray() \"$1\"\`"

    local adta_parameter_1="$1"

    local emff_directory

    emff_directory=$(dirname "$adta_parameter_1")

    emff_directoryPatternTemp=" ${emff_directory} "

    if [[ ! " ${matchedDirectoriesArray[@]} " =~ $emff_directoryPatternTemp ]]; then
        matchedDirectoriesArray+=("$emff_directory")
    fi
}

addMetadataValuesToMatrixArray() {
    # string "path to the markdown file" emff_parameter_1

    outputToLogFile "\`> $ addMetadataValuesToMatrixArray() \"$1\"\`"

    local emff_parameter_1="$1"

    # Extract recommendationTypeId values (may be multiple per file)
    local emff_typeId

    emff_typeId=$(getMetadataValueForFile "$emff_parameter_1" "${metadataKeyArray[0]}")

    # Only proceed if at least one valid GUID found
    local emff_foundValid=0

    while read -r emff_typeId; do
        printf "%s" ". "

        if [[ "$emff_typeId" =~ $guidPattern ]]; then
            emff_foundValid=1

            # Extract category and state
            local emff_matrixKey=$(getMatrixForArrayByCategoryState "$emff_parameter_1")

            # Store unique type ID in matrix
            if [[ -z "${categoryStateMatrixArray[$emff_matrixKey]+x}" ]]; then
                categoryStateMatrixArray["$emff_matrixKey"]="$emff_typeId"
            else
                # Only add if not already present
                if ! grep -q "$emff_typeId" <<< "${categoryStateMatrixArray[$emff_matrixKey]}"; then
                    categoryStateMatrixArray["$emff_matrixKey"]+=$'\n'"$emff_typeId"
                fi
            fi
        fi
    done <<< "$emff_typeId"

     # Store directory if at least one valid type ID found
    if (( emff_foundValid )); then
        addDirectoryToArray "$emff_parameter_1"
    fi
}

searchDirectoriesForRecommendationFiles() {
    # ----

    outputToLogFile "\`> $ searchDirectoriesForRecommendationFiles()\`"

    # Search for recommendationTypeId in the files
    while IFS= read -r -d '' sdfrf_markdownFile; do
        printf "%s" ". "

        if grep -q "\"${metadataKeyArray[0]}\"" "$sdfrf_markdownFile"; then
            addMetadataValuesToMatrixArray "$sdfrf_markdownFile"
        fi
    done < <(find "$articlesSelfhelpcontentDirectory" -type f -name "*.md" -print0)
}

outputToDirectoryFile() {
    # ----

    outputToLogFile "\`> $ outputToDirectoryFile()\`"

    local otdf_outputFile="$outputDirectory/$dateStamp-directory-output.txt"
    
    local otdf_outputFileForSearch="$inputDirectory/latest-directory-output.txt"

    # printf "# Directories with recommendation files\n" > "$otdf_outputFile"

    for otdf_directory in "${matchedDirectoriesArray[@]}"; do
        printf "%s" ". "

        printf "%s\n" "$otdf_directory" >> "$otdf_outputFile"
    done

    cp "$otdf_outputFile" "$otdf_outputFileForSearch"
}

outputToCategoryStateFile() {
    # ----

    outputToLogFile "\`> $ outputToCategoryStateFile()\`"

    for otcsf_key in "${!categoryStateMatrixArray[@]}"; do
        printf "%s" ". "

        local otcsf_category="${otcsf_key%%|*}"

        local otcsf_state="${otcsf_key##*|}"

        local otcsf_outputFile="$outputDirectory/$dateStamp-${otcsf_category// /_}${otcsf_state// /_}-output.txt"

        # printf "# Unique type IDs for %s state and %s category\n" "$otcsf_state" "$otcsf_category" > "$otcsf_outputFile"

        printf "%s\n" "${categoryStateMatrixArray[$otcsf_key]}" >> "$otcsf_outputFile"
    done
}

main() {
    # ----

    startEpochTime="$dateStampEpoch"

    outputToLogFile "\`> $ main()\`"

    # --- Search all markdown files for recommendationTypeId in JSON format ---
    searchDirectoriesForRecommendationFiles

    # --- Output: Directories with matched files ---
    outputToDirectoryFile

    # --- Output: Unique recommendationTypeIds grouped by category and state ---
    outputToCategoryStateFile

    endEpochTime="$dateStampEpoch"

    printf "Completed in %d seconds\n" "$((endEpochTime - startEpochTime))"

    outputToLogFile "Completed in $((endEpochTime - startEpochTime)) seconds"
}

time main
