#!/bin/bash

set -euo pipefail

userProfile="/mnt/c/users/v-martinjos" # wsl

scriptDirectory="$userProfile/bash/scripts"
gitDirectoryPath="$userProfile/git"

selfHelpContentDirectoryPath="$gitDirectoryPath/jm-247-ms/SelfHelpContent"
# articlesSelfHelpContentDirectoryPath="$selfHelpContentDirectoryPath/articles"

inputDirectory="$scriptDirectory/input"

# inputDirectoryTestFromExcelCsv="$inputDirectory/test-from-excel.csv"
inputDirectoryTestFromJsonMd="$inputDirectory/test-json.md"

metadataArray=( "service" "retirementFeatureName" "retirementDate" "recommendationCategory" "recommendationSubCategory" "dataSource" "refreshInterval" "schemaVersion" "streamNamespace" "recommendationMetadataState" "recommendationTypeId" "sourceProperties" "serviceRetirement" "dataSourceMetadata")


outputParameterValueFromJson() {
    local sourceJson="$1"
    local parameterName="$2"

    # use double quotes so $parameterName is expanded and escape internal quotes for the regex
    printf "%s" "$sourceJson" | grep -oP "\"$parameterName\":\s*\"\K[^\"]+"
}

loopThroughJsonArray() {
    for jsonElement in "${jsonInputArray[@]}"; do
        for metadata in "${metadataArray[@]}"; do
            local value

            value=$(outputParameterValueFromJson "$jsonElement" "$metadata")

            printf "%s: %s\n" "$metadata" "$value"
        done
    done
}

main() {
    if [ -f "$inputDirectoryTestFromJsonMd" ]; then
        jsonInput=$(cat "$inputDirectoryTestFromJsonMd")

        loopThroughJsonArray
    else
        printf "%s\n" "Input file $inputDirectoryTestFromJsonMd does not exist"

        return 1
    fi
}

time main
