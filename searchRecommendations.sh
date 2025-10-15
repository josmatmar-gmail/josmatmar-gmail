#!/bin/bash
#
# author: github.com/jm-247-ms
# ms.author: v-martinjos@microsoft.com
#
# full-lastrun 2025.08.12
# ---
# real    79m54.189s
# user    1m40.339s
# sys     1m13.896s
#
# list-lastrun 2025.08.06
# ---
# real    37m46.804s
# user    1m13.648s
# sys     0m56.436s

set -euo pipefail

dateStamp=$(printf "%s" "$(date +%Y%b%d-%H%M)")

# userProfile="/home/v-martinjos" # linux
# userProfile="/Users/v-martinjos" # macOS
userProfile="/mnt/c/users/v-martinjos" # wsl

scriptDirectory="$userProfile/bash/scripts"
outputDirectory="$scriptDirectory/output"
inputDirectory="$scriptDirectory/input"

gitDirectory="$userProfile/git"

selfHelpContentDirectory="$gitDirectory/jm-247-ms/SelfHelpContent"
articlesSelfhelpcontentDirectory="$selfHelpContentDirectory/articles"

learnAdvisorDirectory="$gitDirectory/jm-247-ms/azure-monitor-docs-pr/articles/advisor"
includesAdvisorLearnDirectory="$learnAdvisorDirectory/includes"

outDateRawLogTxt="$outputDirectory/$dateStamp-RAW-Log.txt"

# outDateLearnSummaryTxt="$outputDirectory/$dateStamp-learn-summary.txt"

outDateFoundLearnSummaryTxt="$outputDirectory/$dateStamp-learn-foundDeprecated-summary.txt"
outDateFoundLearnSummaryRegExText="$outputDirectory/$dateStamp-learn-foundDeprecated-regex-summary.txt"

outDateMissingLearnSummaryTxt="$outputDirectory/$dateStamp-learn-missingActive-summary.txt"
outDateMissingLearnSummaryRegExText="$outputDirectory/$dateStamp-learn-missingActive-regex-summary.txt"

guidPattern='^\{?[A-Z0-9a-z]{8}-[A-Z0-9a-z]{4}-[A-Z0-9a-z]{4}-[A-Z0-9a-z]{4}-[A-Z0-9a-z]{12}\}?$'
# integerPattern='^\{?[0-9]+\}?$'

actionVerbsArray=( "add" "get" "output" "remove" "search" "set" "update" )
categoryArray=( "Cost" "HighAvailability" "OperationalExcellence" "Performance" )
metadataArray=( "learnMoreLink" "displayLabel" "description" "longDescription" "potentialBenefits" "recommendationCategory" "recommendationFriendlyName" "recommendationMetadataState" "recommendationTypeId" "version" )
stateArray=( "Active" "Disabled" )
loadArray=( "directory" "learnAdvisor" "selfHelpContent" )

directoryOutputArray=()
# learnActiveArray=()
# learnDisabledArray=()

trimPathForDisplay() {
    # string path tpfd_parameter_1

    outputToLogFile "\`> $ trimPathForDisplay() \"$1\"\`"

    tpfd_parameter_1="$1"

    tpfd_shortPath=$(printf "%s\n" "$tpfd_parameter_1" | cut -b $((${#userProfile}+1))-)

    printf "%s%s" "~" "$tpfd_shortPath"
}

outputToLogFile() {
    # string message otlf_parameter_1

    otlf_parameter_1="$1"

    printf "%s\n" "$otlf_parameter_1" >> "$outDateRawLogTxt"
}

checkDirectoryExists() {
    # string directory cde_parameter_1

    printf "%s\n" "\`> $ checkDirectoryExists() \"$1\"\`"

    cde_parameter_1="$1"

    if [[ ! -d "$cde_parameter_1" ]]; then
        printf "%s\n" "\`$cde_parameter_1\` directory not found"

        mkdir "$cde_parameter_1"

        printf "%s\n" \`"> $ mkdir \"$cde_parameter_1\"\`"
    else
        printf "%s\n" "\`$cde_parameter_1\` directory found"
    fi
}

loadSearchArray() {
    #

    outputToLogFile "\`> $ loadSearchArray()\`"
    outputToLogFile "\`> $ searchLines=\$(cat \"$inputDirectory\"/directory-Output.txt)\`"

    searchLines=$(cat "$inputDirectory"/directory-Output.txt)

    # add each line to array
    for searchLine in $searchLines; do
        outputToLogFile "\`> $ directoryInputArray+=(\"$searchLine\")\`"

        directoryInputArray+=("$searchLine")
    done
}

loadActionArray() {
    # usage:
    #   loadActionArray directory
    #   loadActionArray learnAdvisor
    #   loadActionArray selfHelpContent
    # string action lfa_parameter_1

    outputToLogFile "\`> $ loadActionArray()\`"

    laa_actionPattern=" $2 "

    if [[ " ${loadArray[*]} " =~ $laa_actionPattern ]]; then
        lfa_parameter_1="$1"

        for laa_categoryTemp in "${categoryArray[@]}"; do
            for laa_stateTemp in "${stateArray[@]}"; do
                if [[ "$lfa_parameter_1" == "${loadArray[0]}" ]]; then
                    laa_fileNameTemp="directory-Output.txt"
                    laa_actionModifier1Temp="$laa_categoryTemp"
                    laa_actionModifier2Temp="${loadArray[0]}"
                elif [[ "$lfa_parameter_1" == "${loadArray[1]}" ]]; then
                    laa_fileNameTemp="learn-$laa_stateTemp-Output.txt"
                    laa_actionModifier1Temp="learnSearch"
                    laa_actionModifier2Temp="$laa_stateTemp"
                elif [[ "$lfa_parameter_1" == "${loadArray[2]}" ]]; then
                    laa_fileNameTemp="selfhelpcontent-$laa_stateTemp$laa_categoryTemp-Output.txt"
                    laa_actionModifier1Temp="azureSearch"
                    laa_actionModifier2Temp="$laa_stateTemp$laa_categoryTemp"
                fi

                laa_searchFileTemp=$(cat "$inputDirectory/$laa_fileNameTemp")

                # add each line to array
                for laa_searchLineTemp in $laa_searchFileTemp; do
                    outputToLogFile "\`> $ addValueToArray \"$laa_searchLineTemp\" \"$laa_actionModifier1Temp\" \"$laa_actionModifier2Temp\"\`"

                    addValueToArray "$laa_searchLineTemp" "$laa_actionModifier1Temp" "$laa_actionModifier2Temp"
                done
            done
        done
    fi
}

getMetadataValueInFile() {
    # string file smvif_parameter_1
    # string metadata index smvif_parameter_2

    outputToLogFile "\`> $ getMetadataValueInFile() \"$1\" \"$2\"\`"

    if [[ -f $1 ]]; then
        smvif_parameter_1="$1"

        outputToLogFile "\`> $ smvif_patternTemp=\" $2 \"\`"

        smvif_patternTemp=" $2 "
            
        outputToLogFile "\`> $ \" \${metadataArray[*]} \" =~ $smvif_patternTemp\`"

        if [[ " ${metadataArray[*]} " =~ $smvif_patternTemp ]]; then
            smvif_parameter_2="$2"

            outputToLogFile "\`> $ smvif_valueMetadata=\$(grep \"$smvif_parameter_2\" \"$smvif_parameter_1\" | cut -d '\"' -f 4)\`"

            smvif_valueMetadata=$(grep "$smvif_parameter_2" "$smvif_parameter_1" | cut -d '"' -f 4)

            printf "%s" "$smvif_valueMetadata"
        else
            printf "%s" "nomatch"

            outputToLogFile "ERROR: \`metadata index\` not provided to \`getMetadataValueInFile()\`"
        fi
    else
        printf "%s" "nomatch"

        outputToLogFile "ERROR: \`file\` not provided to \`getMetadataValueInFile()\`"
    fi
}

searchStringInFilesInDirectory() {
    # string directory ssifid_parameter_1
    # string search string ssifid_parameter_2

    outputToLogFile "\`> $ searchStringInFilesInDirectory() \"$1\" \"$2\"\`"

    if [[ -d $1 ]]; then
        ssifid_parameter_1="$1"
        ssifid_parameter_2="$2"

        outputToLogFile "\`> $ find \"$ssifid_parameter_1\" -type f -name \"*.md\" -exec grep -q \"$ssifid_parameter_2\" {} +\`"

        if find "$ssifid_parameter_1" -type f -name "*.md" -exec grep -q "$ssifid_parameter_2" {} +; then
            printf "%s" "match"
        else
            printf "%s" "nomatch"
        fi
    else
        printf "%s" "nomatch"

        outputToLogFile "ERROR: \`directory\` not provided to \`searchStringInFilesInDirectory()\`"
    fi
}

checkRecommendationInDirectory() {
    # string directory crid_parameter_1

    outputToLogFile "\`> $ checkRecommendationInDirectory() \"$1\"\`"

    if [[ -d $1 ]]; then
        crid_parameter_1="$1"

        crid_returnValue="match"
        
        for crid_metadataKey in "${metadataArray[@]}"; do
            outputToLogFile "\`> $ crid_metadataKeyFound=\"\$(searchStringInFilesInDirectory \"$crid_parameter_1\" \"$crid_metadataKey\")\"\`"

            crid_metadataKeyFound="$(searchStringInFilesInDirectory "$crid_parameter_1" "$crid_metadataKey")"

            outputToLogFile "\`> $ [[ \"$crid_returnValue\" == \"match\" ]] && [[ \"$crid_metadataKeyFound\" == \"match\" ]]\`"

            if [[ "$crid_returnValue" == "match" ]] && [[ "$crid_metadataKeyFound" == "match" ]]; then
                outputToLogFile "\`> $ \"$crid_returnValue\"=\"match\"\`"
            else
                outputToLogFile "\`> $ \"$crid_returnValue\"=\"nomatch\"\`"

                crid_returnValue="nomatch"

                outputToLogFile "\`> $ break\`"

                break
            fi
        done
        printf "%s" "$crid_returnValue"
    else
        printf "%s" "nomatch"

        outputToLogFile "ERROR: \`directory\` not provided to \`checkRecommendationInDirectory()\`"
    fi
}

getPathForFile() {
    # string file gpff_parameter_1

    outputToLogFile "\`> $ getPathForFile() \"$1\"\`"

    if [[ -f $1 ]]; then
        gpff_parameter="$1"

        outputToLogFile "\`> $ gpff_path=\"\${gpff_parameter%/*}\"\`"

        gpff_path="${gpff_parameter%/*}"

        printf "%s" "$gpff_path"

        outputToLogFile "\`$gpff_path\`"
    else
        outputToLogFile "ERROR: \`file\` not provided to \`getPathForFile()\`"
    fi
}

getArrayVariableNameByCategoryState() {
    # string category gavnbcs_parameter_1
    # string state gavnbcs_parameter_2

    outputToLogFile "\`> $ getArrayVariableNameByCategoryState() \"$1\" \"$2\"\`"

    gavnbcs_parameter_1="$1"
    gavnbcs_parameter_2="$2"

    gavnbcs_categoryPatternTemp=" $1 "
    gavnbcs_statePatternTemp=" $2 "

    if [[ " ${categoryArray[*]} " =~ $gavnbcs_categoryPatternTemp ]] && [[ " ${stateArray[*]} " =~ $gavnbcs_statePatternTemp ]]; then
       printf "%s%s%s" "$gavnbcs_parameter_2" "$gavnbcs_parameter_1" "Array"
    fi
}

getSetArrayByName() {
    # Usage:
    #   getSetArrayByName get gsabn_parameter_2
    #   getSetArrayByName set gsabn_parameter_2 value1 value2 ...
    #
    # string action gsabn_parameter_1 ("get" or "set")
    # string array variable name gsabn_parameter_2

    gsabn_actionPatternTemp=" $1 "

    if [[ " ${actionVerbsArray[*]} " =~ $gsabn_actionPatternTemp ]]; then
        gsabn_parameter_1="$1"
        gsabn_parameter_2="$2"

        shift 2

        outputToLogFile "\`> $ getSetArrayByName() \"$gsabn_parameter_1\" \"$gsabn_parameter_2\" \"\$@\"\`"

        if [[ "$gsabn_parameter_1" == "get" ]]; then
            # Print array values, one per line
            outputToLogFile "Get values from \`$gsabn_parameter_2\` array"

            if declare -p "$gsabn_parameter_2" &>/dev/null; then

                declare -n gsgsabn_arrayTemp="$gsabn_parameter_2"

                for gsabn_valueTemp in "${gsgsabn_arrayTemp[@]}"; do
                    printf "%s\n" "$gsabn_valueTemp"
                done
            fi
        elif [[ "$gsabn_parameter_1" == "set" ]]; then
            outputToLogFile "Set values for \`$gsabn_parameter_2\` array"

            unset "$gsabn_parameter_2"

            declare -g -a "$gsabn_parameter_2"

            for gsabn_valueTemp in "$@"; do
                # shellcheck disable=SC1083
                eval "$gsabn_parameter_2+=(\"\$gsabn_valueTemp\")"
            done
        fi
    else
        outputToLogFile "ERROR: \`$gsabn_parameter_1\` action is not valid for \`getSetArrayByName()\`"
    fi
}

addValueToArray() {
    # Usage:
    #   addValueToArray avtabcs_parameter_1 directory directory
    #   addValueToArray avtabcs_parameter_1 avtabcs_parameter_2 avtabcs_parameter_3
    #   addValueToArray avtabcs_parameter_1 azureSearch avtabcs_parameter_3
    #   addValueToArray avtabcs_parameter_1 learnSearch avtabcs_parameter_3
    #
    # string value avtabcs_parameter_1
    # string category avtabcs_parameter_2
    # string state avtabcs_parameter_3

    outputToLogFile "\`> $ addValueToArray() \"$1\" \"$2\" \"$3\"\`"

    avtabcs_parameter_1="$1"
    avtabcs_parameter_2="$2"
    avtabcs_parameter_3="$3"

    if [[ "$2" == "${loadArray[0]}" ]] || [[ "$3" == "${loadArray[0]}" ]]; then
        avtabcs_arrayTempVariableTemp="directoryOutputArray"

    elif [[ "$2" == "azureSearch" ]]; then
        avtabcs_arrayTempVariableTemp="($avtabcs_parameter_3)Array"

    elif [[ "$2" == "learnSearch" ]]; then
        avtabcs_arrayTempVariableTemp="learn$($avtabcs_parameter_3)Array"

        outputToLogFile "\`> $ avtabcs_arrayTempVariableTemp=\"learn\$($avtabcs_parameter_3)Array\"\`"
    else
        avtabcs_arrayTempVariableTemp="$(getArrayVariableNameByCategoryState "$avtabcs_parameter_2" "$avtabcs_parameter_3")"

        outputToLogFile "\`> $ avtabcs_arrayTempVariableTemp=\"$avtabcs_arrayTempVariableTemp\"\`"
    fi

    # Get current array values
    mapfile -t avtabcs_arrayTemp < <(getSetArrayByName "${actionVerbsArray[1]}" "$avtabcs_arrayTempVariableTemp")

    outputToLogFile "\`> $ avtabcs_arrayTemp=(\"\${avtabcs_arrayTemp[@]}\")\`"

    # Add new value
    avtabcs_arrayTemp+=("$avtabcs_parameter_1")

    outputToLogFile "\`> $ avtabcs_arrayTemp+=(\"$avtabcs_parameter_1\")\`"

    # Deduplicate and sort
    readarray -td '' avtabcs_arrayTempSorted < <(printf "%s\0" "${avtabcs_arrayTemp[@]}" | sort -uz)

    outputToLogFile "\`> $ readarray -td '' avtabcs_arrayTempSorted < <(printf \"%s\\0\" \"\${avtabcs_arrayTemp[@]}\" | sort -uz)\`"

    # Set array back
    getSetArrayByName "${actionVerbsArray[5]}" "$avtabcs_arrayTempVariableTemp" "${avtabcs_arrayTempSorted[@]}"

    outputToLogFile "\`> $ getSetArrayByName \"${actionVerbsArray[5]}\" \"$avtabcs_arrayTempVariableTemp\" \"\${avtabcs_arrayTempSorted[@]}\"\`"

    # Clear temp arrays
    unset avtabcs_arrayTemp avtabcs_arrayTempSorted
}

outputArrayToFileByCategoryState() {
    # string category oatfbcs_parameter_1
    # string state oatfbcs_parameter_2
    # string dateStamp oatfbcs_parameter_3
    # string outputDirectory oatfbcs_parameter_4

    outputToLogFile "\`> $ outputArrayToFileByCategoryState() \"$1\" \"$2\" \"$3\" \"$4\"\`"

    oatfbcs_parameter_1="$1"
    oatfbcs_parameter_2="$2"
    oatfbcs_parameter_3="$3"
    oatfbcs_parameter_4="$4"

    oatfbcs_arrayTempVariableTemp="$(getArrayVariableNameByCategoryState "$oatfbcs_parameter_1" "$oatfbcs_parameter_2")"

    outputToLogFile "\`> $ oatfbcs_arrayTempVariableTemp=\"$oatfbcs_arrayTempVariableTemp\"\`"

    mapfile -t oatfbcs_arrayTemp < <(getSetArrayByName "${actionVerbsArray[1]}" "$oatfbcs_arrayTempVariableTemp")

    if [[ "$oatfbcs_parameter_2" == "${stateArray[0]}" ]]; then
        oatfbcs_outputFileNameTemp="$oatfbcs_parameter_4/$oatfbcs_parameter_3-selfhelpcontent-$oatfbcs_parameter_1-Output.txt"
    else
        oatfbcs_outputFileNameTemp="$oatfbcs_parameter_4/$oatfbcs_parameter_3-selfhelpcontent-${oatfbcs_parameter_1}Deprecated-Output.txt"
    fi

    for oatfbcs_item in "${oatfbcs_arrayTemp[@]}"; do
        printf "%s\n" "$oatfbcs_item" >> "$oatfbcs_outputFileNameTemp"

        outputToLogFile "\`$oatfbcs_item\` written to \`$oatfbcs_outputFileNameTemp\`"
    done

    unset oatfbcs_arrayTemp
}

searchLearnFileForTypeID() {
    # string category slffti_parameter_1
    # string state slffti_parameter_2
    # string type ID slffti_parameter_3

    outputToLogFile "\`> $ searchLearnFileForTypeID \"$1\" \"$2\" \"$3\"\`"

    local slffti_parameter_1="$1"
    local slffti_parameter_2="$2"
    local slffti_parameter_3="$3"

    for slffti_includeFile in "$includesAdvisorLearnDirectory/$slffti_parameter_1"*; do
        outputToLogFile "\`$slffti_includeFile\`"
        printf "%s " "."

        slffti_notFoundCount=0

        if (grep -q "$slffti_parameter_3" "$slffti_includeFile") && [[ "$slffti_parameter_2" == "${stateArray[1]}" ]]; then
            foundDeprecatedArray+=("$slffti_parameter_3")

            printf "%s    " "*"

            break
        elif (! grep -q "$slffti_parameter_3" "$slffti_includeFile") &&[[ "$slffti_parameter_2" == "${stateArray[0]}" ]]; then
            slffti_notFoundCount=$((slffti_notFoundCount + 1))

            if [[ "$slffti_notFoundCount" -gt 0 ]]; then
                missingActiveArray+=("$slffti_parameter_3")

                printf "%s    " "+"

                break
            fi
        fi
    done
}

addOutputSearchValuesInArray() {
    # Usage:
    #   addOutputSearchValuesInArray add gsvia_parameter_2 gsvia_parameter_3 gsvia_parameter_4
    #   addOutputSearchValuesInArray output --- gsvia_parameter_3 gsvia_parameter_4
    #   addOutputSearchValuesInArray search --- gsvia_parameter_3 gsvia_parameter_4
    #
    # string action gsvia_parameter_1
    # string type id gsvia_parameter_2
    # string category gsvia_parameter_3
    # string state gsvia_parameter_4

    outputToLogFile "\`> $ addOutputSearchValuesInArray() \"$1\" \"$2\" \"$3\" \"$4\"\`"

    gsvia_parameter_1="$1"
    gsvia_parameter_2="$2"
    gsvia_parameter_3="$3"
    gsvia_parameter_4="$4"

    gsvia_arrayVariableTemp="$(getArrayVariableNameByCategoryState "$gsvia_parameter_3" "$gsvia_parameter_4")"

    outputToLogFile "\`> $ gsvia_arrayVariableTemp=\"$gsvia_arrayVariableTemp\"\`"

    mapfile -t gsvia_arrayTemp < <(getSetArrayByName "${actionVerbsArray[1]}" "$gsvia_arrayVariableTemp")

    outputToLogFile "\`> $ gsvia_arrayTemp=(\"\${gsvia_arrayTemp[@]}\")\`"

    if [[ "$gsvia_parameter_1" == "${actionVerbsArray[0]}" ]]; then
        addValueToArray "$gsvia_parameter_2" "$gsvia_parameter_3" "$gsvia_parameter_4"
    else
        for gsvia_item in "${gsvia_arrayTemp[@]}"; do
            if [[ "$gsvia_parameter_1" == "${actionVerbsArray[2]}" ]]; then
                printf "%s" ". "

                outputToLogFile "\`> $ \"$gsvia_parameter_1\" == \"${actionVerbsArray[2]}\"\`"
                outputToLogFile "\`> $ \"$gsvia_item\" \`"
                outputToLogFile "\`> $ \"$gsvia_parameter_4\" == \"${stateArray[0]}\"\`"

                if [[ "$gsvia_parameter_4" == "${stateArray[0]}" ]]; then
                    outputToLogFile "\`$gsvia_item\` is active"
                elif [[ "$gsvia_parameter_4" == "${stateArray[1]}" ]]; then
                    outputToLogFile "\`$gsvia_item\` is deprecated"
                fi

                printf "%s\n" "$gsvia_item" >> "$outputDirectory"/"$dateStamp"-selfhelpcontent-"$gsvia_parameter_4""$gsvia_parameter_3"-Output.txt
            elif [[ "$gsvia_parameter_1" == "${actionVerbsArray[4]}" ]]; then
                printf "%s" ". "

                outputToLogFile "\`> $ rnFileForTypeID \"$gsvia_parameter_3\" \"$gsvia_parameter_4\" \"$gsvia_parameter_2\"\`"

                searchLearnFileForTypeID "$gsvia_parameter_3" "$gsvia_parameter_4" "$gsvia_parameter_2"
            else
                outputToLogFile "ERROR: \`action\` not provided to \`addOutputSearchValuesInArray()\`"

                printf "%s\n" "nomatch"
            fi
        done
    fi

    # Clear temporary array
    unset gsvia_arrayTemp
}

addValuesToArrays() {
    # string file avta_parameter_1

    outputToLogFile "\`> $ addValuesToArrays() \"$1\"\`"

    if [[ -f $1 ]]; then
        avta_parameter_1="$1"

        outputToLogFile "\`> $ avta_typeIdTemp=\$(getMetadataValueInFile \"$avta_parameter_1\" \"${metadataArray[8]}\")\`"

        avta_typeIdTemp=$(getMetadataValueInFile "$avta_parameter_1" "${metadataArray[8]}")

        outputToLogFile "\`> $ \"$avta_typeIdTemp\" != \"nomatch\"\`"

        if [[ "$avta_typeIdTemp" != "nomatch" ]]; then
            outputToLogFile "\`> $ avta_categoryTemp=\$(getMetadataValueInFile \"$avta_parameter_1\" \"${metadataArray[5]}\")\`"

            avta_categoryTemp=$(getMetadataValueInFile "$avta_parameter_1" "${metadataArray[5]}")

            if [[ "$avta_categoryTemp" =~ "nomatch" ]]; then
                outputToLogFile "ERROR: \`category\` not found in \`$avta_parameter_1\` file"

                return 1
            fi

            avta_categoryPatternTemp=" $avta_categoryTemp "

            if [[ " ${categoryArray[*]} " =~ $avta_categoryPatternTemp ]]; then
                outputToLogFile "\`> $ avta_stateTemp=\$(getMetadataValueInFile \"$avta_parameter_1\" \"${metadataArray[7]}\")\`"

                avta_stateTemp=$(getMetadataValueInFile "$avta_parameter_1" "${metadataArray[7]}")
        
                outputToLogFile "\`> $ addOutputSearchValuesInArray \"${actionVerbsArray[0]}\" \"$avta_typeIdTemp\" \"$avta_categoryTemp\" \"$avta_stateTemp\"\`"

                addOutputSearchValuesInArray "${actionVerbsArray[0]}" "$avta_typeIdTemp" "$avta_categoryTemp" "$avta_stateTemp"
            fi
        fi
    else
        outputToLogFile "ERROR: \`file\` not provided to \`addValuesToArrays()\`"
    fi
}

searchContentInFile() {
    # string file scif_parameter_1

    outputToLogFile "\`> $ searchContentInFile() \"$1\"\`"

    if [[ -f $1 ]]; then
        scif_parameter_1="$1"

        outputToLogFile "\`> $ scif_typeIdTemp=\"\$(getMetadataValueInFile \"$scif_parameter_1\" \"\${metadataArray[8]}\")\"\`"

        scif_typeIdTemp="$(getMetadataValueInFile "$scif_parameter_1" "${metadataArray[8]}")"

        outputToLogFile "\`> $ [[ \"$scif_typeIdTemp\" != \"nomatch\" ]] && [[ \"$scif_typeIdTemp\" =~ $guidPattern ]]\`"

        if [[ "$scif_typeIdTemp" != "nomatch" ]] && [[ "$scif_typeIdTemp" =~ $guidPattern ]]; then
            outputToLogFile "\`> $ scif_currentPath=\"\$(getPathForFile \"$scif_parameter_1\")\"\`"

            scif_currentPath="$(getPathForFile "$scif_parameter_1")"
            
            outputToLogFile "\`> $ addValueToArray \"$scif_currentPath\" \"directory\" \"directory\"\`"

            addValueToArray "$scif_currentPath" "${loadArray[0]}" "${loadArray[0]}"

            outputToLogFile "\`> $ addValuesToArrays \"$scif_parameter_1\"\`"

            addValuesToArrays "$scif_parameter_1"
        else
            outputToLogFile "\`$scif_typeIdTemp\` is not a GUID or UUID"
        fi
    else
        outputToLogFile "ERROR: \`file\` not provided to \`searchCountInFile()\`"
    fi
}

searchFilesInDirectory() {
    # string directory or directory and letter sfid_parameter_1

    outputToLogFile "\`> $ searchFilesInDirectory() \"$1\"\`"

    sfid_parameter_1="$1"

    for sfid_currentChild in "$sfid_parameter_1"* ; do

        if [[ -d $sfid_currentChild ]]; then
            printf "\n%s" "Search \`$(trimPathForDisplay "$sfid_currentChild")\`"

            outputToLogFile "Search \`$sfid_currentChild\` directory"

            outputToLogFile "\`> $ sfid_containsRecommendation=\$(checkRecommendationInDirectory \"$sfid_currentChild/\")\`"

            sfid_containsRecommendation=$(checkRecommendationInDirectory "$sfid_currentChild/")

            outputToLogFile "\`> $ \"$sfid_containsRecommendation\" == \"match\"\`"

            if [[ "$sfid_containsRecommendation" == "match" ]]; then

                outputToLogFile "\`> $ searchFilesInDirectory \"$sfid_currentChild/\"\`"

                searchFilesInDirectory "$sfid_currentChild/"
            fi
        elif [[ -f $sfid_currentChild ]]; then
            printf "%s" ". "

            outputToLogFile "Search \`$sfid_currentChild\` file"

            outputToLogFile "\`> $ sfid_tempFileExtension=\$(getFileExtensionForFile \"$sfid_currentChild\")\`"

            sfid_tempFileExtension=$(getFileExtensionForFile "$sfid_currentChild")

            outputToLogFile "\`> $ \"$sfid_tempFileExtension\" == \"md\"\`"

            if [[ "$sfid_tempFileExtension" == "md" ]]; then
                outputToLogFile "\`> $ searchContentInFile \"$sfid_currentChild\"\`"

                searchContentInFile "$sfid_currentChild"
            fi
        fi
    done
}

searchDirectoriesByLetter() {
    # string directory sdbl_parameter_1

    outputToLogFile "\`> $ searchDirectoriesByLetter() \"$1\"\`"

    if [[ -d $1 ]]; then
        sdbl_parameter_1="$1"

        for letter in {a..z}; do
            printf "%s" "Search \`$(trimPathForDisplay "$sdbl_parameter_1/$letter*")\`"

            for sdbl_directory in "$sdbl_parameter_1"/"$letter"*; do
                outputToLogFile "\`> $ [ -d \"$sdbl_directory\" ] || continue\`"

                [ -d "$sdbl_directory" ] || continue

                outputToLogFile "\`> $ sdbl_found=\$((sdbl_found + 1))\`"

                sdbl_found=0

                for sdbl_metadataItem in "${metadataArray[@]}"; do
                    printf "%s" ". "

                    outputToLogFile "\`> $ find \"$sdbl_directory\" -type f -name \"*.md\" -exec grep -q \"$sdbl_metadataItem\" {} +\`"

                    if find "$sdbl_directory" -type f -name "*.md" -exec grep -q "$sdbl_metadataItem" {} +; then
                        outputToLogFile "\`> $ sdbl_found=\$((sdbl_found + 1))\`"

                        sdbl_found=$((sdbl_found + 1))
                    else
                        outputToLogFile "\`> $ break\`"

                        break
                    fi
                done
                if [ "$sdbl_found" -eq "${#metadataArray[@]}" ]; then
                    searchFilesInDirectory "$sdbl_directory"
                fi
            done
            printf "%s\n" ""
        done
    else
        outputToLogFile "ERROR: \`directory\` not provided to \`searchDirectoriesByLetter()\`"
        printf "%s" "nomatch"
    fi
}

selectDirectoriesToSearch() {
    # ----

    outputToLogFile "\`> $ selectDirectoriesToSearch()\`"

    if test -f "$inputDirectory/directory-Output.txt"; then
        printf "%s\n" "Search list in \`$(trimPathForDisplay "$inputDirectory/directory-Output.txt")\`"

        outputToLogFile "Search list in \`$inputDirectory/directory-Output.txt\`"
       
        loadSearchArray

        for sdts_searchDirectory in "${directoryInputArray[@]}"; do
            if [[ -d $sdts_searchDirectory/ ]]; then
                printf "%s" "Search \`$(trimPathForDisplay "$sdts_searchDirectory")\`"

                outputToLogFile "\`$sdts_searchDirectory\`"

                outputToLogFile "\`> $ searchFilesInDirectory \"$sdts_searchDirectory/\"\`"

                searchFilesInDirectory "$sdts_searchDirectory/"
            fi

            printf "%s\n" ""
        done
    else
        searchDirectoriesByLetter "$articlesSelfhelpcontentDirectory"
    fi
}

clearInputDirectory() {
    # ----

    outputToLogFile "\`> $ clearInputDirectory()\`"
    outputToLogFile "\`> $ test -d \"$inputDirectory\"\`"

    if test -d "$inputDirectory"; then
        outputToLogFile "\`> $ rm -rf \"$inputDirectory\"\`"

        rm -rf "$inputDirectory"

        outputToLogFile "\`> $ mkdir \"$inputDirectory\"\`"

        mkdir "$inputDirectory"
    fi
}

createListFiles() {
    # ----

    outputToLogFile "\`> $ createListFiles()\`"

    printf "\n\n%s" "Create files for \`Azure/SelfHelpContent\` repo..."

    outputToLogFile "Create files for \`Azure/SelfHelpContent\` repo..."

    # output array of directories
    for clf_directoryItem in "${directoryOutputArray[@]}"; do
        outputToLogFile "\`$clf_directoryItem\`"

        printf "%s\n" "$clf_directoryItem" >> "$outputDirectory"/"$dateStamp"-selfhelpcontent-directory-Output.txt
        printf "%s\n" "$clf_directoryItem" >> "$inputDirectory"/directory-Output.txt
    done

    printf "%s\n" ""

    # output arrays of type ID for state and category combinations
    for clf_category in "${categoryArray[@]}"; do
        outputToLogFile "\`$clf_category\`"

        for clf_state in "${stateArray[@]}"; do
            printf "%s" ". "

            outputToLogFile "\`$clf_state\`"

            addOutputSearchValuesInArray "${actionVerbsArray[2]}" "type-id" "$clf_category" "$clf_state"
        done

        printf "%s\n" ""
    done
}

searchLearnFileForTypeID() {
    # string category slffti_parameter_1
    # string state slffti_parameter_2
    # string type ID slffti_parameter_3

    outputToLogFile "\`> $ searchLearnFileForTypeID() \"$1\" \"$2\" \"$3\"\`"

    local slffti_parameter_1="$1"
    local slffti_parameter_2="$2"
    local slffti_parameter_3="$3"

    for slffti_includeFile in "$includesAdvisorLearnDirectory/$slffti_parameter_1"*; do
        outputToLogFile "\`$slffti_includeFile\`"
        printf "%s " "."

        slffti_notFoundCount=0

        if (grep -q "$slffti_parameter_3" "$slffti_includeFile") && [[ "$slffti_parameter_2" == "${stateArray[1]}" ]]; then
            foundDeprecatedArray+=("$slffti_parameter_3")

            printf "%s    " "*"

            break
        elif (! grep -q "$slffti_parameter_3" "$slffti_includeFile") &&[[ "$slffti_parameter_2" == "${stateArray[0]}" ]]; then
            slffti_notFoundCount=$((slffti_notFoundCount + 1))

            if [[ "$slffti_notFoundCount" -gt 0 ]]; then
                missingActiveArray+=("$slffti_parameter_3")

                printf "%s    " "+"

                break
            fi
        fi
    done
}

searchLearnDirectoriesByCategory() {

    outputToLogFile "\`> $ searchLearnDirectoriesByCategory()\`"

    printf "\n\n%s" "Search files for \`MicrosoftDocs/azure-monitor-docs-pr\` repo..."

    outputToLogFile "Search files for \`MicrosoftDocs/azure-monitor-docs-pr\` repo..."

    for m_categoryTemp in "${categoryArray[@]}"; do
        for m_stateTemp in "${stateArray[@]}"; do

            slifc_arrayTempVariableTemp=$(getArrayVariableNameByCategoryState "$m_categoryTemp" "$m_stateTemp")

            outputToLogFile "\`> $ slifc_arrayTempVariableTemp=\$(getArrayVariableNameByCategoryState \"$m_categoryTemp\" \"$m_stateTemp\")\`"

            mapfile -t slifc_arrayTemp < <(getSetArrayByName "${actionVerbsArray[1]}" "$slifc_arrayTempVariableTemp")

            for slifc_searchLine in "${slifc_arrayTemp[@]}"; do
                outputToLogFile "\`> $ find "$includesAdvisorLearnDirectory/" -type f -name \"$m_categoryTemp*.md\" -exec grep -q \"$slifc_searchLine\" {} +\`"
                printf "%s " "."

                if (find "$includesAdvisorLearnDirectory/" -type f -name "$m_categoryTemp*.md" -exec grep -q "$slifc_searchLine" {} +); then
                    outputToLogFile "\`> $ searchLearnFileForTypeID \"$m_categoryTemp\" \"$m_stateTemp\" \"$slifc_searchLine\"\`"
                    printf "%s " "."

                    searchLearnFileForTypeID "$m_categoryTemp" "$m_stateTemp" "$slifc_searchLine"
                fi
            done
        done
    done
}

createSummaryForLearnFiles() {
    # ----

    outputToLogFile "\`> $ createSummaryForLearnFiles()\`"

    printf "\n%s" "Create files for \`MicrosoftDocs/azure-monitor-docs-pr/articles/advisor\`..."

    outputToLogFile "Create files for \`MicrosoftDocs/azure-monitor-docs-pr/articles/advisor\`..."

    olatf_foundCount=0

    printf "%s" "(\"|<!--)(" >> "$outDateFoundLearnSummaryRegExText"

    for olatf_deprectedLineTemp in "${foundDeprecatedArray[@]}"; do
        ((olatf_foundCount=olatf_foundCount+1))
    
        printf "%s" ". "
        printf "%s\n" "\`$olatf_deprectedLineTemp\` found in \`$slffti_includeFile\`" >> "$outDateFoundLearnSummaryTxt"
        printf "%s" "$olatf_deprectedLineTemp" >> "$outDateFoundLearnSummaryRegExText"

        if [[ $olatf_foundCount -lt ${#foundDeprecatedArray[@]} ]]; then
            printf "%s" "|" >> "$outDateFoundLearnSummaryRegExText"
        fi
    done

    printf "%s" ")(\"|_begin-->|_end-->)" >> "$outDateFoundLearnSummaryRegExText"

    olatf_missingCount=0

    printf "%s" "(\"|<!--)(" >> "$outDateMissingLearnSummaryRegExText"

    for olatf_activeLineTemp in "${missingActiveArray[@]}"; do
        ((olatf_missingCount=olatf_missingCount+1))

        printf "%s" ". "
        printf "%s\n" "\`$olatf_activeLineTemp\` is Active and not found" >> "$outDateMissingLearnSummaryTxt"
        printf "%s" "$olatf_activeLineTemp" >> "$outDateMissingLearnSummaryRegExText"

        if [[ $olatf_missingCount -lt ${#missingActiveArray[@]} ]]; then
            printf "%s" "|" >> "$outDateMissingLearnSummaryRegExText"
        fi
    done
    printf "%s" ")(\"|_begin-->|_end-->)" >> "$outDateMissingLearnSummaryRegExText"
}

getFileLongForFile() {
    # string file gflff_parameter_1

    outputToLogFile "\`> $ getFileLongForFile() \"$1\"\`"

    if [[ -f $1 ]]; then
        gflff_parameter="$1"
        gflff_fileLong="${gflff_parameter##*/}"

        printf "%s" "$gflff_fileLong"
    else
        outputToLogFile "ERROR: \`file\` not provided to \`getFileLongForFile()\`"
    fi
}

getFileExtensionForFile() {
    # string file gfeff_parameter_1

    outputToLogFile "\`> $ getFileExtensionForFile() \"$1\"\`"

    if [[ -f $1 ]]; then
        gfeff_parameter="$1"
        gfeff_fileLong="${gfeff_parameter##*/}"
        gfeff_fileExtension="${gfeff_fileLong##*.}"

        printf "%s" "$gfeff_fileExtension"
    else
        outputToLogFile "ERROR: \`file\` not provided to \`getFileExtensionForFile()\`"
    fi
}

getFileShortForFile() {
    # string file gfsff_parameter_1

    outputToLogFile "\`> $ getFileShortForFile() \"$1\"\`"

    if [[ -f $1 ]]; then
        gfsff_parameter="$1"
        gfsff_fileLong="${gfsff_parameter##*/}"
        gfsff_fileShort="${gfsff_fileLong%.*}"

        printf "%s" "$gfsff_fileShort"
    else
        outputToLogFile "ERROR: \`file\` not provided to \`getFileShortForFile()\`"
    fi
}

main() {
    local durationEpochTime
    local endEpochTime
    local endTime
    local startEpochTime
    local startTime

    startEpochTime="$(date +%s)"
    startTime="$(date +%Y%b%d-%H%M)"

    checkDirectoryExists "$inputDirectory"
    checkDirectoryExists "$outputDirectory"

    # choose and search all or subset of directories for recommendation metadata
    selectDirectoriesToSearch

    # clear the old input files before new ones are written
    clearInputDirectory

    # create files based on search of recommendations
    createListFiles

    # search Learn files by category for unpublished active and published deprecated recommendations
    searchLearnDirectoriesByCategory

    # create summary of Learn search
    createSummaryForLearnFiles

    endEpochTime="$(date +%s)"
    endTime="$(date +%Y%b%d-%H%M)"

    ((durationEpochTime=endEpochTime-startEpochTime))

    outputToLogFile "Completed \`$startTime\` to \`$endTime\` = \`$durationEpochTime\` seconds"

    printf "\n%s\n" "Completed \`$startTime\` to \`$endTime\` = \`$durationEpochTime\` seconds"
}

time main
