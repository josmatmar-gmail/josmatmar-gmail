#!/bin/bash
#
# author: github.com/jm-247-ms
# ms.author: v-martinjos@microsoft.com
#
# full-lastrun 2025.07.31
# ---
# real    51m22.167s
# user    1m12.998s
# sys     1m9.196s
#
# list-lastrun 2025.08.06
# ---
# real    37m46.804s
# user    1m13.648s
# sys     0m56.436s

set -euo pipefail

# Declare global arrays used throughout the script
declare -g -a directoryOutputArray
declare -g -a learnActiveNotFoundArray
declare -g -a learnDeprecatedFoundArray

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

outDateLearnSummaryTxt="$outputDirectory/$dateStamp-learn-summary.txt"

guidPattern='^\{?[A-Z0-9a-z]{8}-[A-Z0-9a-z]{4}-[A-Z0-9a-z]{4}-[A-Z0-9a-z]{4}-[A-Z0-9a-z]{12}\}?$'
# integerPattern='^\{?[0-9]+\}?$'

actionVerbsArray=( "add" "get" "output" "remove" "search" "set" "update" )
categoryArray=( "Cost" "HighAvailability" "OperationalExcellence" "Performance" )
metadataArray=( "learnMoreLink" "displayLabel" "description" "longDescription" "potentialBenefits" "recommendationCategory" "recommendationFriendlyName" "recommendationMetadataState" "recommendationTypeId" "version" )
stateArray=( "Active" "Disabled" )
loadArray=( "directory" "learnAdvisor" "selfHelpContent" )
matchFoundArray=( "+" "...") # '+'="match"; '...'="nomatch"

sendToLogFile() {
    # string message stlf_parameter_1

    local stlf_parameter_1="$1"

    printf "%s\n" "$stlf_parameter_1" >> "$outDateRawLogTxt"
}

sendToFile() {
    # string file path stlf_parameter_1
    # string content stlf_parameter_2

    sendToLogFile "sendToFile \`$1\` \`$2\`"

    local stlf_parameter_1="$1"
    local stlf_parameter_2="$2"

    checkCreateDirectory "$(dirname "$stlf_parameter_1")"

    [[ -z "$stlf_parameter_1" ]] || [[ -z "$stlf_parameter_2" ]] && {
        sendToLogFile "ERROR: file path or content not provided";

        return;
    }

    [[ ! -d "$(dirname "$stlf_parameter_1")" ]] && {
        sendToLogFile "ERROR: directory not found";

        return;
    }

    [[ ! -f "$stlf_parameter_1" ]] && touch "$stlf_parameter_1"

    [[ ! -f "$stlf_parameter_1" ]] && {
        sendToLogFile "ERROR: file not created";

        return;
    }

    [[ ! -w "$stlf_parameter_1" ]] && {
        sendToLogFile "ERROR: file not writable";

        return;
    }

    printf "%s\n" "$stlf_parameter_2" >> "$stlf_parameter_1"
}

deduplicateSortArray() {
    # string array elements

    sendToLogFile "deduplicateSortArray \`\${@:1}\`"

    readarray -td '' sorted < <(printf "%s\0" "${@:1}" | sort -uz)

    printf "%s\n" "${sorted[@]}"
}

replaceUserPathWithTilde() {
    # string path stlf_parameter_1

    sendToLogFile "Replacing user path with tilde for \`$1\`"

    [[ -z "$1" ]] && {
        sendToLogFile "ERROR: path not provided";

        return;
    }

    [[ ! -d "$1" ]] && {
        sendToLogFile "ERROR: directory not found";

        return;
    }
    
    local rupwt_userProfile="${userProfile%/}"

    [[ "$1" == "$rupwt_userProfile"* ]] || {
        printf "%s" "$1";

        return;
    }

    local rupwt_parameter_1="$1"
    local rupwt_shortcutPathTemp="${rupwt_parameter_1:${#rupwt_userProfile}}"

    printf "~%s" "$rupwt_shortcutPathTemp"
}

checkCreateDirectory() {
    # string directory path ccd_parameter_1

    sendToLogFile "Checking and creating directory: $1"

    [[ -z "$1" ]] && {
        sendToLogFile "ERROR: directory path not provided";

        return;
    }

    [[ ! -d "$1" ]] && {
        sendToLogFile "ERROR: directory not found";

        return;
    }

    local ccd_parameter_1="$1"

    if [[ ! -d "$ccd_parameter_1" ]]; then
        mkdir "$ccd_parameter_1"

        sendToLogFile "Created directory: $ccd_parameter_1"
    else
        sendToLogFile "Directory exists: $ccd_parameter_1"
    fi
}

getExtensionForFile() {
    # string file path geff_parameter_1

    sendToLogFile "getExtensionForFile \`$1\`"

    local geff_parameter_1="$1"

    [[ -f $geff_parameter_1 ]] || {
        sendToLogFile "ERROR: file not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ -f $geff_parameter_1 ]] && printf "%s" "${geff_parameter_1##*.}"
}

getLongNameForFile() {
    # string file path glnff_parameter_1

    sendToLogFile "getLongNameForFile \`$1\`"

    local glnff_parameter_1="$1"

    [[ -z $glnff_parameter_1 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ ! -f $glnff_parameter_1 ]] && {
        sendToLogFile "ERROR: file not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ -f $glnff_parameter_1 ]] && printf "%s" "${glnff_parameter_1##*/}"
}

getShortNameForFile() {
    # string file path gsnff_parameter_1

    sendToLogFile "getShortNameForFile \`$1\`"

    local gsnff_parameter_1="$1"

    [[ -z $gsnff_parameter_1 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ ! -f $gsnff_parameter_1 ]] && {
        sendToLogFile "ERROR: file not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ -f $gsnff_parameter_1 ]] && printf "%s" "${gsnff_parameter_1##*/%.*}"
}

getDirectoryPathForFile() {
    # string file path gdpff_parameter_1

    sendToLogFile "getDirectoryPathForFile \`$1\`"

    local gdpff_parameter_1="$1"

    [[ -z $gdpff_parameter_1 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ -f $gdpff_parameter_1 ]] || {
        sendToLogFile "ERROR: file not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ -f $gdpff_parameter_1 ]] && printf "%s" "${gdpff_parameter_1%/*}"
}

getValueOfMetadataForFile() {
    # string file path gvomff_parameter_1
    # string metadata key gvomff_parameter_2

    sendToLogFile "getValueOfMetadataForFile \`$1\` \`$2\`"

    local gvomff_parameter_1="$1" gvomff_parameter_2="$2"

    [[ -f $gvomff_parameter_1 ]] || {
        sendToLogFile "ERROR: file not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    gvomff_keyPatternTemp=" $gvomff_parameter_2 "

    [[ " ${metadataArray[*]} " =~ $gvomff_keyPatternTemp ]] || {
        sendToLogFile "ERROR: metadata key not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    grep "$gvomff_parameter_2" "$gvomff_parameter_1" | cut -d '"' -f 4
}

getVariableNameForArray() {
    # string category gvnfa_parameter_1
    # string state gvnfa_parameter_2

    sendToLogFile "getVariableNameForArray \`$1\` \`$2\`"

    local gvnfa_parameter_1="$1" gvnfa_parameter_2="$2"

    [[ -z $gvnfa_parameter_1 ]] || [[ -z $gvnfa_parameter_2 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    gvnfa_categoryPatternTemp=" $gvnfa_parameter_1 "

    [[ ! " ${categoryArray[*]} " =~ $gvnfa_categoryPatternTemp ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    
    gvnfa_statePatternTemp=" $gvnfa_parameter_2 "

    [[ ! " ${stateArray[*]} " =~ $gvnfa_statePatternTemp ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    if [[ " ${categoryArray[*]} " =~ $gvnfa_categoryPatternTemp ]] && [[ " ${stateArray[*]} " =~ $gvnfa_statePatternTemp ]]; then
        printf "%s%sArray" "$gvnfa_parameter_2" "$gvnfa_parameter_1"
    fi
}

getArray() {
    # string array name ga_parameter_1

    sendToLogFile "getArray \`$1\`"

    local ga_parameter_1="$1"

    [[ -z $ga_parameter_1 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ ! $(declare -p "$ga_parameter_1" 2>/dev/null) =~ "declare -a" ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    declare -n ga_arrayTemp="$ga_parameter_1"

    printf "%s\n" "${ga_arrayTemp[@]}"
}

setArray() {
    # string array name sa_parameter_1
    # string array values sa_parameter_2...

    sendToLogFile "setArray \`$1\` \`$2\`"

    local sa_parameter_1="$1";

    [[ -z $sa_parameter_1 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }
    
    shift

    [[ ! $(declare -p "$sa_parameter_1" 2>/dev/null) =~ "declare -a" ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    unset "$sa_parameter_1"

    declare -g -a "$sa_parameter_1"

    for sa_valueTemp in "$@"; do
        declare -n sa_arrayReferenceTemp="$sa_parameter_1"

        sa_arrayReferenceTemp+=("$sa_valueTemp")
    done
}

addSortValueToArray() {
    # string array name asvta_parameter_1
    # string value asvta_parameter_2

    sendToLogFile "addSortValueToArray \`$1\` \`$2\`"
    
    local asvta_parameter_1="$1" asvta_parameter_2="$2"
    
    [[ -z $1 ]] || [[ -z $2 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    asvta_arrayNamePatternTemp=" $asvta_parameter_1 "

    [[ ! " ${loadArray[*]} " =~ $asvta_arrayNamePatternTemp ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ ! $(declare -p "$1" 2>/dev/null) =~ "declare -a" ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    mapfile -t asvta_arrayTemp < <(getArray "$asvta_parameter_1")

    asvta_arrayTemp+=("$asvta_parameter_2")

    mapfile -t asvta_arrayTempSortTemp < <(deduplicateSortArray "${asvta_arrayTemp[@]}")

    setArray "$asvta_parameter_1" "${asvta_arrayTempSortTemp[@]}"
}

trimPathForDisplay() {
    # string path to trim tpfd_parameter_1

    sendToLogFile "trimPathForDisplay \`$1\`"

    local tpfd_parameter_1="$1"

    [[ -z $tpfd_parameter_1 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ ! -d $tpfd_parameter_1 ]] && {
        sendToLogFile "ERROR: directory not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    replaceUserPathWithTilde "$tpfd_parameter_1";
}

outputToLogFile() {
    # string message to log otlf_parameter_1

    sendToLogFile "outputToLogFile \`$1\`"

    local otlf_parameter_1="$1"
    
    [[ -z $otlf_parameter_1 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    sendToLogFile "$otlf_parameter_1";
}

checkDirectoryExists() {
    # string directory path cde_parameter_1

    sendToLogFile "checkDirectoryExists \`$1\`"

    local cde_parameter_1="$1"
    
    [[ -z $cde_parameter_1 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ ! -d $cde_parameter_1 ]] && {
        sendToLogFile "ERROR: directory not found: $cde_parameter_1";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    sendToLogFile "Directory exists: $cde_parameter_1";

    checkCreateDirectory "$1";
}

getFileExtensionForFile() {
    # string file path gfeff_parameter_1

    sendToLogFile "getExtensionForFile \`$1\`"

    local gfeff_parameter_1="$1"
    
    [[ -z $gfeff_parameter_1 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ ! -f $gfeff_parameter_1 ]] && {
        sendToLogFile "ERROR: file not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    getExtensionForFile "$gfeff_parameter_1";
}

getFileLongForFile() {
    # string file path gflff_parameter_1

    sendToLogFile "getFileLongForFile \`$1\`"

    local gflff_parameter_1="$1"
    
    [[ -z $gflff_parameter_1 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ ! -f $gflff_parameter_1 ]] && {
        sendToLogFile "ERROR: file not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    getLongNameForFile "$1";
}

getFileShortForFile() {
    # string file path gfsff_parameter_1

    sendToLogFile "getShortNameForFile \`$1\`"

    local gfsff_parameter_1="$1"
    
    [[ -z $gfsff_parameter_1 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ ! -f $gfsff_parameter_1 ]] && {
        sendToLogFile "ERROR: file not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    getShortNameForFile "$gfsff_parameter_1";
}

getPathForFile() {
    # string file path gpff_parameter_1

    sendToLogFile "getDirectoryPathForFile \`$1\`"

    local gpff_parameter_1="$1"
    
    [[ -z $gpff_parameter_1 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ ! -f $gpff_parameter_1 ]] && {
        sendToLogFile "ERROR: file not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    getDirectoryPathForFile "$1";
}

getArrayVariableNameByCategoryState() {
    # string category gvnfa_parameter_1
    # string state gvnfa_parameter_2

    sendToLogFile "getArrayVariableNameByCategoryState \`$1\` \`$2\`"

    local gvnfa_parameter_1="$1" gvnfa_parameter_2="$2"

    [[ -z $gvnfa_parameter_1 ]] || [[ -z $gvnfa_parameter_2 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }
    
    gvnfa_categoryPatternTemp=" $gvnfa_parameter_1 "

    [[ ! " ${categoryArray[*]} " =~ $gvnfa_categoryPatternTemp ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    gvnfa_statePatternTemp=" $gvnfa_parameter_2 "

    [[ ! " ${stateArray[*]} " =~ $gvnfa_statePatternTemp ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    getVariableNameForArray "$gvnfa_parameter_1" "$gvnfa_parameter_2";
}

getMetadataValueInFile() {
    # string file path gmvif_parameter_1
    # string metadata key gmvif_parameter_2

    sendToLogFile "getMetadataValueInFile \`$1\` \`$2\`"

    local gmvif_parameter_1="$1" gmvif_parameter_2="$2"

    [[ -f $gmvif_parameter_1 ]] || {
        sendToLogFile "ERROR: file not found";
        
        printf "%s" "${matchFoundArray[1]}";
        
        return; 
    }

    gmvif_metdataKeyPatternTemp=" $gmvif_parameter_2 "

    [[ " ${metadataArray[*]} " =~ $gmvif_metdataKeyPatternTemp ]] || {
        sendToLogFile "ERROR: metadata key not found";
        
        printf "%s" "${matchFoundArray[1]}";
        
        return;
    }

    local value

    value=$(getValueOfMetadataForFile "$gmvif_parameter_1" "$gmvif_parameter_2")
    
    printf "%s" "${value:-nomatch}"
}

searchStringInFilesInDirectory() {
    # string directory path ssifid_parameter_1
    # string search string ssifid_parameter_2

    sendToLogFile "searchStringInFilesInDirectory \`$1\` \`$2\`"

    local ssifid_parameter_1="$1" ssifid_parameter_2="$2"

    [[ -d $ssifid_parameter_1 ]] || {
        sendToLogFile "ERROR: directory not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    find "$ssifid_parameter_1" -type f -name "*.md" -exec grep -q "$ssifid_parameter_2" {} + && printf "%s" "${matchFoundArray[0]}" || printf "%s" "${matchFoundArray[1]}"
}

checkRecommendationInDirectory() {
    # string directory path crid_parameter_1

    sendToLogFile "checkRecommendationInDirectory \`$1\`"

    local crid_parameter_1="$1"

    [[ -z $crid_parameter_1 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ ! -d $crid_parameter_1 ]] && {
        sendToLogFile "ERROR: directory not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    local crid_directoryTemp="$crid_parameter_1"

    [[ -d $crid_directoryTemp ]] || {
        sendToLogFile "ERROR: directory not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    for crid_metadataKeyTemp in "${metadataArray[@]}"; do
        [[ "$(searchStringInFilesInDirectory "$crid_directoryTemp" "$crid_metadataKeyTemp")" == "${matchFoundArray[0]}" ]] || {
            printf "%s" "${matchFoundArray[1]}";

            return;
        }
    done

    printf "%s" "${matchFoundArray[0]}"
}

addValueToArray() {
    # string value to add avta_parameter_1
    # string category avta_parameter_2
    # string state avta_parameter_3

    sendToLogFile "addValueToArray \`$1\` \`$2\` \`$3\`"

    local avta_parameter_1="$1" avta_parameter_2="$2" avta_parameter_3="$3"

    [[ -z $avta_parameter_1 ]] || [[ -z $avta_parameter_2 ]] || [[ -z $avta_parameter_3 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    avta_categoryPatternTemp=" $avta_parameter_2 "

    [[ ! " ${categoryArray[*]} " =~ $avta_categoryPatternTemp ]] && {
        sendToLogFile "ERROR: category not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    avta_statePatternTemp=" $avta_parameter_3 "

    [[ ! " ${stateArray[*]} " =~ $avta_statePatternTemp ]] && {
        sendToLogFile "ERROR: state not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    local avta_arrayNameTemp

    if [[ "$avta_parameter_2" == "${loadArray[0]}" ]] || [[ "$avta_parameter_3" == "${loadArray[0]}" ]]; then
        avta_arrayNameTemp="directoryOutputArray"
    else
        avta_arrayNameTemp="$(getArrayVariableNameByCategoryState "$avta_parameter_2" "$avta_parameter_3")"
    fi

    addSortValueToArray "$avta_arrayNameTemp" "$avta_parameter_1"
}

outputArrayToFileByCategoryState() {
    # string category oatfbcs_parameter_1
    # string state oatfbcs_parameter_2
    # string stamp oatfbcs_parameter_3
    # string output directory oatfbcs_parameter_4

    sendToLogFile "outputArrayToFileByCategoryState \`$1\` \`$2\` \`$3\` \`$4\`"

    local oatfbcs_parameter_1="$1" oatfbcs_parameter_2="$2" oatfbcs_parameter_3="$3" oatfbcs_parameter_4="$4"

    [[ -z $oatfbcs_parameter_1 ]] || [[ -z $oatfbcs_parameter_2 ]] || [[ -z $oatfbcs_parameter_3 ]] || [[ -z $oatfbcs_parameter_4 ]] && {
        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    oatbcs_categoryPatternTemp=" $oatfbcs_parameter_1 "

    [[ ! " ${categoryArray[*]} " =~ $oatbcs_categoryPatternTemp ]] && {
        sendToLogFile "ERROR: category not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    oatbcs_statePatternTemp=" $oatfbcs_parameter_2 "

    [[ ! " ${stateArray[*]} " =~ $oatbcs_statePatternTemp ]] && {
        sendToLogFile "ERROR: state not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    [[ ! -d $oatfbcs_parameter_4 ]] && {
        sendToLogFile "ERROR: output directory not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    local oatfbcs_arrayNameTemp oatfbcs_outputFileNameTemp

    oatfbcs_arrayNameTemp="$(getArrayVariableNameByCategoryState "$oatfbcs_parameter_1" "$oatfbcs_parameter_2")"

    [[ "$oatfbcs_arrayNameTemp" == "${matchFoundArray[1]}" ]] && {
        sendToLogFile "ERROR: array name not found";

        printf "%s" "${matchFoundArray[1]}";

        return;
    }

    oatfbcs_outputFileNameTemp="$oatfbcs_parameter_4/$oatfbcs_parameter_3-selfhelpcontent-$oatfbcs_parameter_1${oatfbcs_parameter_2/Active/}-Output.txt"

    mapfile -t oatfbcs_arrayTemp < <(getArray "$oatfbcs_arrayNameTemp")

    [[ ${#oatfbcs_arrayTemp[@]} -eq 0 ]] && {
        sendToLogFile "No values found for category: $oatfbcs_parameter_1, state: $oatfbcs_parameter_2";

        return;
    }

    for oatfbcs_typeIdTemp in "${oatfbcs_arrayTemp[@]}"; do
        sendToFile "$oatfbcs_outputFileNameTemp" "$oatfbcs_typeIdTemp";
    done
}

addOutputSearchValuesInArray() {
    # string action add|output|search aosvia_parameter_1
    # string typeid type-id aosvia_parameter_2
    # string category category aosvia_parameter_3
    # string state Active|Disabled aosvia_parameter_4

    sendToLogFile "addOutputSearchValuesInArray \`$1\` \`$2\` \`$3\` \`$4\`"

    local aosvia_parameter_1="$1" aosvia_parameter_2="$2" aosvia_parameter_3="$3" aosvia_parameter_4="$4"

    [[ -z $aosvia_parameter_1 ]] || [[ -z $aosvia_parameter_2 ]] || [[ -z $aosvia_parameter_3 ]] || [[ -z $aosvia_parameter_4 ]] && {
        sendToLogFile "ERROR: missing parameters";

        return;
    }

    local aosvia_arrayNameTemp

    aosvia_arrayNameTemp="$(getArrayVariableNameByCategoryState "$aosvia_parameter_3" "$aosvia_parameter_4")"

    [[ "$aosvia_arrayNameTemp" == "${matchFoundArray[1]}" ]] && {
        sendToLogFile "ERROR: array name not found";

        return;
    }

    aosvia_actionVerbsPatternTemp=" $aosvia_parameter_1 "

    [[ ! " ${actionVerbsArray[*]} " =~ $aosvia_actionVerbsPatternTemp ]] && {
        sendToLogFile "ERROR: action verb not found";

        return;
    }

    mapfile -t aosvia_arrayTemp < <(getArray "$aosvia_arrayNameTemp")

    [[ ${#aosvia_arrayTemp[@]} -eq 0 ]] && {
        sendToLogFile "No values found for category: $aosvia_parameter_3, state: $aosvia_parameter_4";

        return;
    }

    if [[ "$aosvia_parameter_1" == "${actionVerbsArray[0]}" ]]; then
        addValueToArray "$aosvia_parameter_2" "$aosvia_parameter_3" "$aosvia_parameter_4"
    else
        for aosvia_typeIdTemp in "${aosvia_arrayTemp[@]}"; do
            if [[ "$aosvia_parameter_1" == "${actionVerbsArray[2]}" ]]; then
                sendToFile "$outputDirectory/$dateStamp-selfhelpcontent-$aosvia_parameter_4$aosvia_parameter_3-Output.txt" "$aosvia_typeIdTemp"
            elif [[ "$aosvia_parameter_1" == "${actionVerbsArray[4]}" ]]; then
                if [[ "$(searchStringInFilesInDirectory "$includesAdvisorLearnDirectory/$aosvia_parameter_3" "$aosvia_typeIdTemp")" == "${matchFoundArray[0]}" ]]; then
                    [[ "$aosvia_parameter_4" == "${stateArray[1]}" ]] && learnDeprecatedFoundArray+=("$aosvia_typeIdTemp")
                else
                    [[ "$aosvia_parameter_4" == "${stateArray[0]}" ]] && learnActiveNotFoundArray+=("$aosvia_typeIdTemp")
                fi
            fi
        done
    fi
}

addValuesToArrays() {
    # string file path avta_parameter_1

    sendToLogFile "addValuesToArrays \`$1\`"

    local avta_parameter_1="$1"

    [[ -z $avta_parameter_1 ]] && {
        sendToLogFile "ERROR: file path not provided";

        return;
    }

    [[ ! -f $avta_parameter_1 ]] && {
        sendToLogFile "ERROR: file not found";

        return;
    }


    [[ -f $avta_parameter_1 ]] || {
        sendToLogFile "ERROR: file not found";

        return;
    }

    local avta_typeidTemp avta_categoryTemp avta_stateTemp

    avta_typeidTemp=$(getMetadataValueInFile "$avta_parameter_1" "recommendationTypeId")

    [[ "$avta_typeidTemp" == "${matchFoundArray[1]}" ]] && return

    avta_categoryTemp=$(getMetadataValueInFile "$avta_parameter_1" "recommendationCategory")

    [[ "$avta_categoryTemp" == "${matchFoundArray[1]}" ]] && {
        sendToLogFile "ERROR: category not found";

        return;
    }

    avta_stateTemp=$(getMetadataValueInFile "$avta_parameter_1" "recommendationMetadataState")

    addOutputSearchValuesInArray "${actionVerbsArray[0]}" "$avta_typeidTemp" "$avta_categoryTemp" "$avta_stateTemp"
}

searchContentInFile() {
    # string file path scif_parameter_1

    sendToLogFile "searchContentInFile \`$1\`"

    local scif_parameter_1="$1"

    [[ -z $scif_parameter_1 ]] && {
        sendToLogFile "ERROR: file path not provided";

        return;
    }

    [[ -f $scif_parameter_1 ]] || {
        sendToLogFile "ERROR: file not found";

        return;
    }

    local scif_typeIdTemp

    scif_typeIdTemp=$(getMetadataValueInFile "$scif_parameter_1" "recommendationTypeId")

    [[ "$scif_typeIdTemp" =~ $guidPattern ]] || {
        sendToLogFile "$scif_typeIdTemp is not a GUID";

        return;
    }

    local scif_pathTemp

    scif_pathTemp=$(getPathForFile "$scif_parameter_1")

    [[ "$scif_pathTemp" == "${matchFoundArray[1]}" ]] && {
        sendToLogFile "ERROR: path not found";

        return;
    }

    addValueToArray "$scif_pathTemp" "${loadArray[0]}" "${loadArray[0]}"

    addValuesToArrays "$scif_parameter_1"
}

searchFilesInDirectory() {
    # string directory path sfid_parameter_1

    sendToLogFile "searchFilesInDirectory \`$1\`"

    local sfid_parameter_1="$1"

    for sfid_childTemp in "$sfid_parameter_1"*; do
        if [[ -d $sfid_childTemp ]]; then
            [[ "$(checkRecommendationInDirectory "$sfid_childTemp/")" == "${matchFoundArray[0]}" ]] && searchFilesInDirectory "$sfid_childTemp/"
        elif [[ -f $sfid_childTemp ]]; then
            [[ "$(getFileExtensionForFile "$sfid_childTemp")" == "md" ]] && searchContentInFile "$sfid_childTemp"
        fi
    done
}

searchDirectoriesByLetter() {
    # string directory path sdbl_parameter_1

    sendToLogFile "searchDirectoriesByLetter \`$1\`"

    local sdbl_parameter_1="$1"
    
    [[ -z $sdbl_parameter_1 ]] && {
        sendToLogFile "ERROR: directory path not provided";

        return;
    }

    [[ ! -d $sdbl_parameter_1 ]] && {
        sendToLogFile "ERROR: directory not found";

        return;
    }

    [[ -z "${metadataArray[*]}" ]] && {
        sendToLogFile "ERROR: metadata array not initialized";

        return;
    }

    [[ -d $sdbl_parameter_1 ]] || {
        sendToLogFile "ERROR: directory not found";

        return;
    }

    for letter in {a..z}; do
        for sdbl_subdirectoryTemp in "$sdbl_parameter_1/$letter"*; do
            [ -d "$sdbl_subdirectoryTemp" ] || continue

            local sdbl_foundCount=0

            for sdbl_metadataKeyTemp in "${metadataArray[@]}"; do
                if find "$sdbl_subdirectoryTemp" -type f -name "*.md" -exec grep -q "$sdbl_metadataKeyTemp" {} +; then
                    (( sdbl_foundCount = sdbl_foundCount + 1 ))
                else
                    sendToLogFile "Metadata key '$sdbl_metadataKeyTemp' not found in $sdbl_subdirectoryTemp"

                    break
                fi
            done

            [[ $sdbl_foundCount -eq ${#metadataArray[@]} ]] && searchFilesInDirectory "$sdbl_subdirectoryTemp"
        done
    done
}

selectDirectoriesToSearch() {
    # ----

    sendToLogFile "selectDirectoriesToSearch"

    [[ -z "$selfHelpContentDirectory" ]] && {
        sendToLogFile "ERROR: \`SelfHelpContent\` directory not provided";

        return;
    }

    [[ -z "$articlesSelfhelpcontentDirectory" ]] && {
        sendToLogFile "ERROR: \`articles\` directory not provided";

        return;
    }

    [[ -z "$includesAdvisorLearnDirectory" ]] && {
        sendToLogFile "ERROR: \`includes\` directory not provided";

        return;
    }

    [[ -d "$selfHelpContentDirectory" ]] || {
        sendToLogFile "ERROR: \`SelfHelpContent\` directory not found";

        return;
    }

    [[ -d "$articlesSelfhelpcontentDirectory" ]] || {
        sendToLogFile "ERROR: \`articles\` directory not found";

        return;
    }

    [[ -d "$includesAdvisorLearnDirectory" ]] || {
        sendToLogFile "ERROR: \`includes\` directory not found";

        return;
    }

    if [[ -f "$inputDirectory/directory-Output.txt" ]]; then
        mapfile -t sdts_arrayTemp < "$inputDirectory/directory-Output.txt"

        for sdts_directoryTemp in "${sdts_arrayTemp[@]}"; do
            [[ -d $sdts_directoryTemp/ ]] && searchFilesInDirectory "$sdts_directoryTemp/"
        done
    else
        searchDirectoriesByLetter "$articlesSelfhelpcontentDirectory"
    fi
}

clearInputDirectory() {
    # ----

    sendToLogFile "clearInputDirectory"

    [[ -z "$inputDirectory" ]] && {
        sendToLogFile "ERROR: \`input\` directory not provided";

        return;
    }

    [[ ! -d "$inputDirectory" ]] && {
        sendToLogFile "ERROR: \`input\` directory not found";

        return;
    }

    [[ -d "$inputDirectory" ]] && rm -rf "$inputDirectory"

    mkdir "$inputDirectory"
}

createListFiles() {
    # ----

    sendToLogFile "createListFiles"

    [[ -z "$outputDirectory" ]] && {
        sendToLogFile "ERROR: \`output\` directory not provided";

        return;
    }

    [[ ! -d "$outputDirectory" ]] && {
        sendToLogFile "ERROR: \`output\` directory not found";

        return;
    }
    for clf_directoryTemp in "${directoryOutputArray[@]}"; do
        sendToFile "$outputDirectory/$dateStamp-selfhelpcontent-directory-Output.txt" "$clf_directoryTemp"

        sendToFile "$inputDirectory/directory-Output.txt" "$clf_directoryTemp"
    done

    for clf_categoryTemp in "${categoryArray[@]}"; do
        for clf_stateTemp in "${stateArray[@]}"; do
            addOutputSearchValuesInArray "${actionVerbsArray[2]}" "type-id" "$clf_categoryTemp" "$clf_stateTemp"
        done
    done
}

searchLearnDirectoriesByCategory() {
    # ----

    sendToLogFile "searchLearnDirectoriesByCategory"

    [[ -z "$includesAdvisorLearnDirectory" ]] && {
        sendToLogFile "ERROR: \`includes\` directory not provided";

        return;
    }

    [[ -d "$includesAdvisorLearnDirectory" ]] || {
        sendToLogFile "ERROR: \`includes\` directory not found";

        return;
    }

    for sldbc_categoryTemp in "${categoryArray[@]}"; do
        for sldbc_directoryTemp in "$includesAdvisorLearnDirectory/$sldbc_categoryTemp"*; do
            [ -d "$sldbc_directoryTemp" ] || continue

            for sldbc_stateTemp in "${stateArray[@]}"; do
                addOutputSearchValuesInArray "${actionVerbsArray[4]}" "type-id" "$sldbc_categoryTemp" "$sldbc_stateTemp"
            done
        done
    done
}

createSummaryForLearnFiles() {
    # ----

    sendToLogFile "createSummaryForLearnFiles"

    [[ -z "$outDateLearnSummaryTxt" ]] && {
        sendToLogFile "ERROR: output file for Learn summary not provided";

        return;
    }

    [[ -f "$outDateLearnSummaryTxt" ]] && rm -f "$outDateLearnSummaryTxt"

    for csflf_typeIdTemp1 in "${learnActiveNotFoundArray[@]}"; do
        sendToFile "$outDateLearnSummaryTxt" "Active and not found on Learn: $csflf_typeIdTemp1"
    done

    for csflf_itemTemp2 in "${learnDeprecatedFoundArray[@]}"; do
        sendToFile "$outDateLearnSummaryTxt" "Deprecated and found on Learn: $csflf_itemTemp2"
    done
}

main() {
    # ----

    sendToLogFile "> $ main"

    sendToLogFile "> $ local startEpochTime endEpochTime startTime endTime"

    local startEpochTime endEpochTime startTime endTime

    sendToLogFile "> $ local startEpochTime startTime endEpochTime endTime"

    local startEpochTime startTime

    sendToLogFile "> $ startEpochTime=\"$(date +%s)\""

    startEpochTime="$(date +%s)"

    sendToLogFile "> $ startTime=\"$(date +%Y%b%d-%H%M)\""
    
    startTime="$(date +%Y%b%d-%H%M)"

    sendToLogFile "> $ checkDirectoryExists \"$inputDirectory\""
    
    checkDirectoryExists "$inputDirectory"

    sendToLogFile "> $ checkDirectoryExists \"$outputDirectory\""

    checkDirectoryExists "$outputDirectory"

    sendToLogFile "> $ selectDirectoriesToSearch"

    selectDirectoriesToSearch

    sendToLogFile "> $ clearInputDirectory"

    clearInputDirectory

    sendToLogFile "> $ searchLearnDirectoriesByCategory"

    createListFiles

    sendToLogFile "> $ createListFiles"

    searchLearnDirectoriesByCategory

    sendToLogFile "> $ createSummaryForLearnFiles"

    createSummaryForLearnFiles

    sendToLogFile "> $ endEpochTime=\"$(date +%s)\" endTime=\"$(date +%Y%b%d-%H%M)\""

    endEpochTime="$(date +%s)" endTime="$(date +%Y%b%d-%H%M)"

    sendToLogFile "Completed ($startTime to $endTime = $((endEpochTime - startEpochTime)) seconds)"

    printf "\n%s\n" "Completed ($startTime to $endTime = $((endEpochTime - startEpochTime)) seconds)"
}

time main
