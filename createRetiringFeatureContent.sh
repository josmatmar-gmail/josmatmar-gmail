#!/usr/bin/env bash
# require bash >= 4.3 for 'declare -n' and readarray

if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3) )); then
    printf '%s\n' "ERROR: Update to Bash 4.3 or newer (current: $BASH_VERSION)" >&2

    exit 1
fi

set -euo pipefail

# author: github.com/jm-247-ms
# ms.author: v-martinjos@microsoft.com
#
# initial-run 2025-08-15
#
# real    205m57.011s
# user    8m15.915s
# sys     4m6.013

dateStamp=$(printf "%s" "$(date +%Y%b%d-%H%M)")

if [[ -n "${WSL_DISTRO_NAME:-}" && -d "/mnt/c/Users/$(id -un)" ]]; then
    userProfile="/mnt/c/Users/$(id -un)"   # WSL priority
elif [[ "$(uname -s)" == "Darwin" ]]; then
    userProfile="/Users/$(id -un)"         # macOS
else
    userProfile="${HOME:-/home/$(id -un)}" # Linux (prefer HOME)
fi

scriptDirectory="$userProfile/bash/scripts"
outputDirectory="$scriptDirectory/output"
outputIncludesDirectory="$outputDirectory/includes"

inputDirectory="$scriptDirectory/input"
temporaryDirectory="$scriptDirectory/temporary"

gitDirectory="$userProfile/git"

selfHelpContentDirectory="$gitDirectory/jm-247-ms/SelfHelpContent"
articlesSelfhelpcontentDirectory="$selfHelpContentDirectory/articles"

learnAdvisorDirectory="$gitDirectory/jm-247-ms/azure-monitor-docs-pr/articles/advisor"
# includesAdvisorLearnDirectory="$learnAdvisorDirectory/includes"

learnAdvisorHowToUseServiceUpgradeRetirementRecommendationsMd="$learnAdvisorDirectory/advisor-how-to-use-service-upgrade-retirement-recommendations.md"

outputDateRawLogTxt="$outputDirectory/$dateStamp-RAW-Log.txt"
inputDirectoryDirectoryOutputTxt="$inputDirectory/directory-Output.txt"
# inputDirectoryTestFromExcelCsv="$inputDirectory/test-from-excel.csv"
# inputDirectoryTestFromJsonMd="$inputDirectory/test-json.md"

temporaryDateRaw="$temporaryDirectory/$dateStamp-RAW"

# contentCreatedNote="This content is automatically generated using API calls to Azure. Any edits made on these files will be overwritten in the next run of the script."
coverageOfServicesNote="Although the current coverage of services for retirement recommendations in Advisor isn't comprehensive, it serves as a solid starting point. At the current time, the platform doesn't have information about the **Impacted Resources** for a subset of recommendations.
Based on your need, use any of the listed ways to get the required information."
# learnLinkNote="For more information, see"

directoryListArray=( "$scriptDirectory" "$inputDirectory" "$outputDirectory" "$outputIncludesDirectory" "$temporaryDirectory" )

# authorArray=( "kapasrij" "kanika1894" )
# actionVerbsArray=( "add" "get" "output" "remove" "search" "set" "update" )
cloudArray=( "fairfax" "mooncake" "public" "usnat" "ussec" )
headingArray=( "# " "## " "### " "#### " "##### " )
# htmlCommentArray=( "<!--" "-->" "_begin" "_end" )
progressArray=( "." ". " "..." "... " "+" "-" "---" "*" )
sectionTableArray=( "[!div class=\"mx-tdCol3BreakAll\"]" "| Service name | Retiring feature | Impacted Resources available? |" "|:--- |:--- |:--- |" )
includeFrontMatterArray=( "ms.service: advisor" "ms.topic: include" "ms.date:$(date +%m/%d/%Y)" )

directoryBlockListPattern='/(apollo|asepapolloabexperiments|common-solutions|communication-services|compute-classiccompute-generic|d365|diagnostic|helpcontext-partnercenter|hovercards-partnercenter|knownissues|media|msx|partnercenter|portal-generic|PowerPlatform|problemscopingques|prompt-guides-partnercenter-copilot|quickstartcars-partnercenter|servicehealth|serviceshub|shared|sqlvm-generic|stscopingqstn|stsscopingqstn|supportTopicDescriptions|test|troubleshooting-guide|tsg_content|tsgQuestions|update-management-center|windows)|mock|(\.|-|_)tsg)'

# loadArray=( "directory" "loadDirectory" "learnAdvisor" "selfHelpContent" )
loadCleanArray=( "directory" "loaddirectory" "learnadvisor" "selfhelpcontent" "norecommendationdirectory" )

metadataArray=( "service" "retirementFeatureName" "retirementDate" "recommendationCategory" "recommendationSubCategory" "dataSource" "refreshInterval" "schemaVersion" "streamNamespace" "recommendationMetadataState" "recommendationTypeId" "sourceProperties" "serviceRetirement" "dataSourceMetadata" "recommendationImpact" )
requiredMetadataArray=( "service" "retirementFeatureName" "retirementDate" "recommendationCategory" "recommendationSubCategory" "recommendationMetadataState" "recommendationTypeId" "sourceProperties" "serviceRetirement" )

guidPattern='\{?[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12}\}?'
# alphanumericPattern='^([[:alpha:]][[:alnum:]_]*Array|[[:alpha:]][[:alnum:]_]*[_-][[:alpha:]][[:alnum:]_]*[_-](active|disabled))$'

outputToConsole() {
    # *

    printf '%s\n' "$*"
}

outputToLogFile() {
    # *

    [[ -n "${outputDateRawLogTxt:-}" ]] || return 0

    if [[ ! -d "$outputDirectory" ]]; then
        mkdir -p "$outputDirectory"
    fi

    printf '%s\n' "$*" >> "$outputDateRawLogTxt"
}

outputToRawNamedFile() {
    # string outputFileName otrnf_parameter_1
    # string outputFileExtension otrnf_parameter_2
    # *

    local otrnf_parameter_1="$1"
    local otrnf_parameter_2="$2"

    shift 2

    otrnf_outputFileName=$(printf "%s/%s-%s-%s.%s" "$temporaryDirectory" "$dateStamp" "RAW" "$otrnf_parameter_1" "$otrnf_parameter_2")

    [[ -n "${otrnf_outputFileName:-}" ]] || return 0

    if [[ ! -d "$temporaryDirectory" ]]; then
        mkdir -p "$temporaryDirectory"
    fi

    printf '%s\n' "$*" >> "$otrnf_outputFileName"
}

outputFunctionToLogFile() {
    # string function oftlf_parameter_1

    local oftlf_parameter_1="$1"

    shift

    outputToLogFile "\`> $ $oftlf_parameter_1() \"$*\"\`"
}

requireParameterForFunction() {
    # Usage:
    #  requireParameterForFunction function_name parameter_name parameter_value
    #
    # string name of function rpff_parameter_1
    # string name of parameter rpff_parameter_2
    # string value of parameter rpff_paramter_3

    local rpff_parameter_1="$1"
    local rpff_parameter_2="$2"

    shift 2

    local rpff_parameter_3="$*"

    if [[ -n "$rpff_parameter_3" ]]; then
        outputToLogFile "\`> $ \`requireParameterForFunction()\` \"$rpff_parameter_1\": \"$rpff_parameter_2\" - \"$rpff_parameter_3\"\`"

        return 0
    else
        outputToLogFile "ERROR: \`requireParameterForFunction()\` \`$rpff_parameter_2\` not provided to \`$rpff_parameter_1\`"

        return 1
    fi
}

trimPathForDisplay() {
    # string path tpfd_parameter_1

    outputFunctionToLogFile "trimPathForDisplay" "$1"

    if requireParameterForFunction "trimPathForDisplay" "path" "$1"; then
        local tpfd_parameter_1="$1"

        local tpfd_shortPath

        tpfd_shortPath=$(printf "%s\n" "$tpfd_parameter_1" | cut -b $((${#userProfile}+1))-)

        printf "%s%s" "~" "$tpfd_shortPath"
    fi
}

checkDirectoryExists() {
    # string directory cde_parameter_1

    outputFunctionToLogFile "checkDirectoryExists" "$1"

    requireParameterForFunction "checkDirectoryExists" "${loadCleanArray[0]}" "$1" || return 1

    cde_parameter_1="$1"

    cde_shortDirectoryPath=$(trimPathForDisplay "$cde_parameter_1")

    [[ -d "$cde_parameter_1" ]] || {
        outputToLogFile "\`> $ mkdir -p \"$cde_parameter_1\"\`"

        mkdir -p "$cde_parameter_1"

        outputToConsole "\`checkDirectoryExists()\` \`$cde_shortDirectoryPath\` directory created"

        return 0
    }
    
    outputToConsole "\`checkDirectoryExists()\` \`$cde_shortDirectoryPath\` directory found"

    return 0
}

initializeDirectories() {
    # ----

    outputFunctionToLogFile "initializeDirectories"

    for id_directoryTemp in "${directoryListArray[@]}"; do
        checkDirectoryExists "$id_directoryTemp"
    done
}

checkActiveInRecommendationMetadataState() {
    # string recommendationMetadataState value caif_parameter_1

    outputFunctionToLogFile "checkActiveInRecommendationMetadataState" "$1"

    requireParameterForFunction "checkActiveInRecommendationMetadataState" "recommendationMetadataState value" "$1" || return 1

    local caif_parameter_1="$1"

    # Normalize value: remove carriage returns and trim leading/trailing whitespace
    caif_recommendationMetadataStateNoReturnTemp="${caif_parameter_1//$'\r'/}"

    [[ "$caif_recommendationMetadataStateNoReturnTemp" == "Active" ]] || {
        outputToLogFile "Deprecated; contains \`\"$caif_parameter_1\"\` \`recommendationMetadataState\` metadata value"

        printf "%s" "nomatch"

        return 1
    }  

    outputToLogFile "Active; contains \`$caif_parameter_1\` \`recommendationMetadataState\` metadata value"

    printf "%s" "match"

    return 0
}

requireFileExists() {
    # string function rfe_parameter_1
    # string name of parameter rfe_parameter_2
    # string file rfe_parameter_3

    outputFunctionToLogFile "requireFileExists" "$1" "$2" "$3"

    local rfe_parameter_1="$1"
    local rfe_parameter_2="$2"

    shift 2

    local rfe_parameter_3="$*"

    outputFunctionToLogFile "$rfe_parameter_1" "$rfe_parameter_3"

    requireParameterForFunction "$rfe_parameter_1" "$rfe_parameter_2" "$rfe_parameter_3" || return 1

    verifyFileExists "$rfe_parameter_3" || return 1

    return 0
}

checkPublicNameFile() {
    # string file cfnis_parameter_1

    outputFunctionToLogFile "checkPublicNameFile" "$1"

    requireFileExists "checkPublicNameFile" "file" "$1" || return 1

    local cfnis_parameter_1="$1"

    local cfnis_fileShortNameTemp
    local cfnis_cloudEnvironmentPattern

    cfnis_fileShortNameTemp=$(getShortNameForFile "$cfnis_parameter_1")

    cfnis_cloudEnvironmentPattern="(${cloudArray[0]}|${cloudArray[1]}|${cloudArray[3]}|${cloudArray[4]})$"

    if [[ "$cfnis_fileShortNameTemp" =~ $cfnis_cloudEnvironmentPattern ]]; then
        outputToLogFile "ERROR: \`checkPublicNameFile\` \`$cfnis_fileShortNameTemp\` ends with a non-public cloud suffix"

        printf "%s" "nomatch"

        return 1
    else
        outputToLogFile "\`checkPublicNameFile\` \`$cfnis_fileShortNameTemp\` ends with a public cloud suffix"

        printf "%s" "match"

        return 0
    fi
}

checkMarkdownFile() {
    # string file cmf_parameter_1

    outputFunctionToLogFile "checkMarkdownFile" "$1"

    requireFileExists "checkMarkdownFile" "file" "$1" || return 1

    local cmf_parameter_1="$1"

    local cmf_filePatternTemp
    local cmf_fileExtensionPattern

    cmf_filePatternTemp=" $cmf_parameter_1"

    cmf_fileExtensionPattern="\.md$"

    [[ "$cmf_filePatternTemp" =~ $cmf_fileExtensionPattern ]] || {
        outputToLogFile "ERROR: \`checkMarkdownFile()\` \`$cmf_parameter_1\` is not a markdown file"

        printf "%s" "nomatch"

        return 1
    }
    
    outputToLogFile "\`checkMarkdownFile()\` \`$cmf_parameter_1\` is a markdown file"

    printf "%s" "match"

    return 0
}

checkPublicCloudInCloudenvironments() {
    # string cloudenvironments value vpcf_parameter_1

    outputFunctionToLogFile "checkPublicCloudInCloudenvironments" "$1"

    requireParameterForFunction "checkPublicCloudInCloudenvironments" "cloudenvironments value" "$1" || return 1

    local vpcf_parameter_1="$1"

    [[ "$vpcf_parameter_1" == *"${cloudArray[2]}"* ]] || {
        outputToLogFile "ERROR: \`checkPublicCloudInCloudenvironments()\` does not target the public cloud environment"

        printf "%s" "nomatch"

        return 1
    }

    outputToLogFile "\`checkPublicCloudInCloudenvironments()\` Targets the public cloud environment"

    printf "%s" "match"

    return 0
}

checkServiceUpgradeAndRetirementInRecommendationSubCategory() {
    # string recommendationSubCategory value csaruif_parameter_1

    outputFunctionToLogFile "checkServiceUpgradeAndRetirementInRecommendationSubCategory" "$1"

    requireParameterForFunction "checkServiceUpgradeAndRetirementInRecommendationSubCategory" "recommendationSubCategory value" "$1" || return 1

    local csarumf_parameter_1="$1"

    [[ "$csarumf_parameter_1" == "ServiceUpgradeAndRetirement" ]] || {
        outputToLogFile "ERROR: \`checkServiceUpgradeAndRetirementInRecommendationSubCategory()\` not a valid \`recommendationSubCategory\`; contains \`$csarumf_parameter_1\`"

        printf "%s" "nomatch"

        return 1
    }

    outputToLogFile "\`checkServiceUpgradeAndRetirementInRecommendationSubCategory()\` Valid subcategory; contains \`$csarumf_parameter_1\` \`recommendationSubCategory\` metadata value"

    printf "%s" "match"

    return 0
}

checkGuidInRecommendationTypeId() {
    # string recommendationTypeId value ctigif_parameter_1

    outputFunctionToLogFile "checkGuidInRecommendationTypeId" "$1"

    requireParameterForFunction "checkGuidInRecommendationTypeId" "recommendationTypeId value" "$1" || return 1

    local ctigif_parameter_1="$1"

    [[ "$ctigif_parameter_1" =~ $guidPattern ]] || {
        outputToLogFile "ERROR: \`checkGuidInRecommendationTypeId()\` not a valid GUID value for \`recommendationTypeId\` metadata key; contains \`$ctigif_parameter_1\`"

        printf "%s" "nomatch"

        return 1  
    }

    outputToLogFile "\`checkGuidInRecommendationTypeId()\` Valid GUID; contains \`$ctigif_parameter_1\` \`recommendationTypeId\` metadata value"

    printf "%s" "match"

    return 0
}

checkDateInRetirementDate() {
    # string retirementDate value cdirf_parameter_1

    outputFunctionToLogFile "checkDateInRetirementDate" "$1"

    requireParameterForFunction "checkDateInRetirementDate" "retirementDate value" "$1" || return 1

    local cdirf_parameter_1="$1"
    
    #  if ! gdate "$cdirf_parameter_1" +"%Y-%m-%d" >/dev/null 2>&1; then
    if ! date -d "$cdirf_parameter_1" +"%Y-%m-%d" >/dev/null 2>&1; then
        outputToLogFile "ERROR: \`checkDateInRetirementDate()\` not a valid date value for \`retirementDate\` metadata key; contains \`$cdirf_parameter_1\`"

        printf "%s" "nomatch"

        return 1
    fi

    outputToLogFile "\`checkDateInRetirementDate()\` Valid date; contains \`$cdirf_parameter_1\` \`retirementDate\` metadata value"

    printf "%s" "match"

    return 0
}

getMetadataValueInFile() {
    # string file gmvif_parameter_1
    # string metadata key gmvif_parameter_2

    outputToLogFile "\`> $ getMetadataValueInFile() \"$1\" \"$2\"\`"

    requireFileExists "getMetadataValueInFile" "file" "$1" || return 1

    requireParameterForFunction "getMetadataValueInFile" "metadata key" "$2" || return 1

    local gmvif_parameter_1="$1"
    local gmvif_parameter_2="$2"

    local gmvif_patternTemp

    gmvif_patternTemp=" $gmvif_parameter_2 "

    [[ " ${metadataArray[*]} " =~ $gmvif_patternTemp ]] || {
        outputToLogFile "ERROR: \`getMetadataValueInFile()\` \`$gmvif_parameter_2\` not a valid metadata key"

        printf "%s" "nomatch"

        return 1
    }

    local gmvif_lineTemp
    local gmvif_metadataValueTemp

    gmvif_lineTemp=$(grep -E "^\s{0,}\"$gmvif_parameter_2\":\s{0,}*" "$gmvif_parameter_1" | head -n1) || {
        outputToLogFile "ERROR: \`getMetadataValueInFile()\` \`$gmvif_parameter_1\` file does not contain \`$gmvif_parameter_2\` metadata key"

        printf "%s" "nomatch"

        return 1
    }

    gmvif_metadataValueTemp=$(printf "%s" "$gmvif_lineTemp" | cut -d '"' -f4) || {
        outputToLogFile "ERROR: \`getMetadataValueInFile()\` \`$gmvif_parameter_1\` file does not contain value for \`$gmvif_parameter_2\` metadata key"

        printf "%s" "nomatch"

        return 1
    }

    gmvif_metadataValueCleanTemp="$(printf '%s' "$gmvif_metadataValueTemp" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"

    printf "%s" "$gmvif_metadataValueCleanTemp"

    return 0
}

checkUniqueRecommendationFile() {
    # string file curf_parameter_1

    outputFunctionToLogFile "checkUniqueRecommendationFile" "$1"

    if [[ -z "${1:-}" ]]; then
        outputToLogFile "ERROR: \`checkUniqueRecommendationFile()\` file not provided"

        printf "%s" "nomatch"

        return 1
    fi

    requireFileExists "checkUniqueRecommendationFile" "file" "$1" || {
        printf "%s" "nomatch";

        return 1;
    }

    local curf_parameter_1="$1"

    checkMarkdownFile "$curf_parameter_1" >/dev/null 2>&1 || {
        printf "%s" "nomatch";

        return 1;
    }

    checkPublicNameFile "$curf_parameter_1" >/dev/null 2>&1 || {
        printf "%s" "nomatch";

        return 1;
    }

    checkPublicCloudInCloudenvironments "$curf_parameter_1" >/dev/null 2>&1 || {
        printf "%s" "nomatch";

        return 1;
    }

    checkGuidInRecommendationTypeId "$curf_parameter_1" >/dev/null 2>&1 || {
        printf "%s" "nomatch";

        return 1;
    }
    
    curf_recommendationSubCategoryValueTemp=$(getMetadataValueInFile "$curf_parameter_1" "recommendationSubCategory") || {
        outputToLogFile "ERROR: \`checkUniqueRecommendationFile()\` \`recommendationSubCategory\` metadata key not found in \`$curf_parameter_1\`"

        printf "%s" "nomatch";

        return 1;
    }

    checkServiceUpgradeAndRetirementInRecommendationSubCategory "$curf_recommendationSubCategoryValueTemp" >/dev/null 2>&1 || {
        printf "%s" "nomatch";

        return 1;
    }

    curf_retirementDateValueTemp=$(getMetadataValueInFile "$curf_parameter_1" "retirementDate") || {
        outputToLogFile "ERROR: \`checkUniqueRecommendationFile()\` \`retirementDate\` metadata key not found in \`$curf_parameter_1\`"

        printf "%s" "nomatch";

        return 1;
    }

    checkDateInRetirementDate "$curf_retirementDateValueTemp" >/dev/null 2>&1 || {
        printf "%s" "nomatch";

        return 1;
    }

    curf_recommendationMetadataStateValueTemp=$(getMetadataValueInFile "$curf_parameter_1" "recommendationMetadataState") || {
        outputToLogFile "ERROR: \`checkUniqueRecommendationFile()\` \`recommendationMetadataState\` metadata key not found in \`$curf_parameter_1\`"

        printf "%s" "nomatch";

        return 1;
    }

    checkActiveInRecommendationMetadataState "$curf_recommendationMetadataStateValueTemp" >/dev/null 2>&1 || { 
        printf "%s" "nomatch";

        return 1;
    }

    verifyRequiredMetadataKeysInFile "$curf_parameter_1" >/dev/null 2>&1 || {
        printf "%s" "nomatch";

        return 1;
    }

    printf "%s" "match"

    outputToLogFile "\`$curf_parameter_1\` is a unique recommendation markdown file"

    return 0
}

# ---- end check utilities ----

getPathForFile() {
    # string file gpf_parameter_1

    outputFunctionToLogFile "getPathForFile" "$1"

    requireFileExists "getPathForFile" "file" "$1" || return 1

    local gpf_parameter_1="$1"

    gpff_path="${gpf_parameter_1%/*}"

    printf "%s" "$gpff_path"

    return 0
}

getShortNameForFile() {
    # string file gsnff_parameter_1

    outputFunctionToLogFile "getShortNameForFile" "$1"

    requireFileExists "getShortNameForFile" "file" "$1" || return 1

    local gsnff_parameter_1="$1"

    local gsnff_baseNameTemp

    gsnff_baseNameTemp="$(basename -- "$gsnff_parameter_1")"

    printf "%s" "${gsnff_baseNameTemp%.*}"

    return 0
}

normalizeString() {
    # string input ns_parameter_1

    outputFunctionToLogFile "normalizeString" "$1"

    requireParameterForFunction "normalizeString" "input" "$1" || return 1

    ns_parameter_1="$1"

    ns_stringTemp="$(printf '%s' "$ns_parameter_1" | tr -cd '[:alnum:]_' | tr '[:upper:]' '[:lower:]')"

    printf '%s' "$ns_stringTemp"

    return 0
}

showProgress() {
    # ----

    outputFunctionToLogFile "showProgress"

    local sp_progressTemp

    outputToLogFile "\`> $ sp_progressTemp=\"${progressArray[0]}\"\`"

    sp_progressTemp="${progressArray[0]}"

    printf "%s" "$sp_progressTemp"
}

verifyFileExists() {
    # string file vfe_parameter_1

    outputFunctionToLogFile "verifyFileExists" "$1"

    requireFileExists "verifyFileExists" "file" "$1" || return 1

    if [[ -f "$1" ]]; then
        return 0
    else
        local vfe_parameter_1="$1"

        outputToLogFile "ERROR: \`verifyFileExists()\` \`$vfe_parameter_1\` file not found"

        return 1
    fi
}

verifyDirectoryExists() {
    # string directory vde_parameter_1

    outputFunctionToLogFile "verifyDirectoryExists" "$1"

    requireDirectoryExists "verifyDirectoryExists" "directory" "$1" || return 1

    if [[ -d "$1" ]]; then
        return 0
    else
        local vde_parameter_1="$1"

        outputToLogFile "ERROR: \`verifyDirectoryExists()\` \`$vde_parameter_1\` directory not found"

        return 1
    fi
}

requireDirectoryExists() {
    # string function rde_parameter_1
    # string name of parameter rde_parameter_2
    # string directory rde_parameter_3

    outputFunctionToLogFile "requireDirectoryExists" "$1" "$2" "$3"

    local rde_parameter_1="$1"
    local rde_parameter_2="$2"
    local rde_parameter_3="$3"

    outputFunctionToLogFile "$rde_parameter_1" "$rde_parameter_3"

    requireParameterForFunction "$rde_parameter_1" "$rde_parameter_2" "$rde_parameter_3" || return 1

    verifyDirectoryExists "$rde_parameter_3" || return 1

    return 0
}

verifyArrayExists() {
    # string name of array vae_parameter_1

    local vae_parameter_1="$1"

    outputFunctionToLogFile "verifyArrayExists" "$1"

    requireParameterForFunction "verifyArrayExists" "name of array" "$1" || return 1

    local vae_declare_output

    if ! vae_declare_output="$(declare -p -- "$vae_parameter_1" 2>/dev/null)"; then
        outputToLogFile "ERROR: \`verifyArrayExists()\` \`$vae_parameter_1\` array not found"

        return 1
    fi

    if [[ "$vae_declare_output" =~ ^declare\ \-[aA] ]]; then
        return 0
    else
        outputToLogFile "ERROR: \`verifyArrayExists()\` \`$vae_parameter_1\` exists but is not an array"

        return 1
    fi
}

requireArrayExists() {
    # string function rae_parameter_1
    # string name of parameter rae_parameter_2
    # string name of array rae_parameter_3

    outputFunctionToLogFile "requireArrayExists" "$1" "$2" "$3"

    local rae_parameter_1="$1"
    local rae_parameter_2="$2"

    shift 2

    local rae_parameter_3="$*"

    outputFunctionToLogFile "$rae_parameter_1" "$rae_parameter_3"

    requireParameterForFunction "$rae_parameter_1" "$rae_parameter_2" "$rae_parameter_3" || return 1

    verifyArrayExists "$rae_parameter_3" || return 1

    return 0
}

getArrayByName() {
    # string name of array gabn_parameter_1

    outputFunctionToLogFile "getArrayByName" "$1"

    requireArrayExists "getArrayByName" "name of array" "$1" || return 1

    local gabn_parameter_1="$1"

    local -n gabn_arrayReference="$gabn_parameter_1"

    printf "%s\n" "${gabn_arrayReference[@]}"

    return 0
}

setLocalArrayFromArrayName() {
    # string name of source array slafn_parameter_1
    # string name of destination array slafn_parameter_2

    outputFunctionToLogFile "setLocalArrayFromArrayName" "$1" "$2"

    requireArrayExists "setLocalArrayFromArrayName" "name of source array" "$1" || return 1

    requireParameterForFunction "setLocalArrayFromArrayName" "name of destination array" "$2" || return 1

    local slafn_parameter_1="$1"
    local slafn_parameter_2="$2"

    local -n destinationArrayReference="$slafn_parameter_2"

    mapfile -t destinationArrayReference < <(getArrayByName "$slafn_parameter_1")

    return 0
}

setArrayByName() {
    # string name of array sabn_parameter_1

    outputFunctionToLogFile "setArrayByName" "$1"

    requireParameterForFunction "setArrayByName" "name of array" "$1" || return 1

    local sabn_parameter_1="$1"

    declare -n sabn_arrayTemp="$sabn_parameter_1"

    sabn_arrayTemp=("${@:2}")

    return 0
}

addValueToArray() {
    # string value avta_parameter_1
    # string name of array avta_parameter_2

    outputFunctionToLogFile "addValueToArray" "$1" "$2"

    requireParameterForFunction "addValueToArray" "input" "$1" || return 1
    requireParameterForFunction "addValueToArray" "name of array" "$2" || return 1

    local avta_parameter_1="$1"
    local avta_parameter_2="$2"

    if [[ -z "${temporaryDateRaw:-}" ]]; then
        outputToLogFile "ERROR: \`addValueToArray()\` temporaryDateRaw is not set"

        return 1
    fi

    local avta_arrayNameSafe

    avta_arrayNameSafe="$(printf '%s' "$avta_parameter_2" | tr -c '[:alnum:]_' '_' )"

    if [[ "$avta_arrayNameSafe" =~ ^[0-9] ]]; then
        avta_arrayNameSafe="x_$avta_arrayNameSafe"
    fi

    if ! [[ "$avta_arrayNameSafe" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
        outputToLogFile "ERROR: \`addValueToArray()\` could not produce a valid variable name from \`$avta_parameter_2\`"

        return 1
    fi

    if ! declare -p arrayNameList >/dev/null 2>&1; then
        declare -g -a arrayNameList=()
    fi

    if ! declare -p "$avta_arrayNameSafe" >/dev/null 2>&1; then
        eval "declare -g -a $avta_arrayNameSafe=()"
    fi

    declare -n avta_destinationArray="$avta_arrayNameSafe"

    if ! printf '%s\n' "${avta_destinationArray[@]:-}" | grep -xFq -- "$avta_parameter_1"; then
        avta_destinationArray+=( "$avta_parameter_1" )
    fi

    if (( ${#avta_destinationArray[@]} )); then
        mapfile -t avta_sortedArrayTemp < <(printf "%s\n" "${avta_destinationArray[@]}" | sed '/^$/d' | LC_ALL=C sort -u)
    else
        avta_sortedArrayTemp=()
    fi

    setArrayByName "$avta_arrayNameSafe" "${avta_sortedArrayTemp[@]}" || {
        outputToLogFile "ERROR: \`addValueToArray()\` failed to update \`$avta_arrayNameSafe\` array"

        unset avta_sortedArrayTemp

        return 1
    }

    if ! printf '%s\n' "${arrayNameList[@]:-}" | grep -xFq -- "$avta_arrayNameSafe"; then
        arrayNameList+=( "$avta_arrayNameSafe" )

        outputToRawNamedFile "arrayNameList" "txt" "$avta_arrayNameSafe"
    fi

    outputToRawNamedFile "$avta_arrayNameSafe" "txt" "$avta_parameter_1"

    unset avta_sortedArrayTemp

    return 0
}

loopAllActiveArrays() {
    # ----

    outputFunctionToLogFile "loopAllActiveArrays"

    requireArrayExists "loopAllActiveArrays" "name of array" "arrayNameList" || return 1

    for saaa_arrayNameTemp in "${arrayNameList[@]}"; do
        showProgress

        outputToRawNamedFile "final.arrayNameList" "txt" "$saaa_arrayNameTemp"

        for saaa_arrayNameItemTemp in $(getArrayByName "$saaa_arrayNameTemp"); do
            outputToRawNamedFile "final.$saaa_arrayNameTemp" "txt" "$saaa_arrayNameItemTemp"
        done
    done

    return 0
}

addMetadataValueMatrixInFile() {
    # string file amvif_parameter_1

    outputFunctionToLogFile "addMetadataValueMatrixInFile" "$1"

    requireFileExists "addMetadataValueMatrixInFile" "file" "$1" || return 1

    local amvif_parameter_1="$1"

    amvif_jsonInput=$(<"$amvif_parameter_1") || {
        outputToLogFile "ERROR: \`addMetadataValueMatrixInFile()\` \`$amvif_parameter_1\` file cannot be read";

        return 1;
    }

    amvif_metadataValueMatrixTemp=$(getMetadataValueMatrixInJson "$amvif_jsonInput") || return 1

    outputToRawNamedFile "json.metadataValueMatrix" "txt" "$amvif_metadataValueMatrixTemp"

    outputToLogFile "\`addMetadataValueMatrixInFile()\` \`$amvif_parameter_1\` file has \`$amvif_metadataValueMatrixTemp\` metadata value matrix"

    addValueToArray "$amvif_metadataValueMatrixTemp" "loadArray" || return 1
    
    amvif_directoryPathTemp=$(getPathForFile "$amvif_parameter_1")

    outputToRawNamedFile "directoryArray" "txt" "$amvif_directoryPathTemp"

    addValueToArray "$amvif_directoryPathTemp" "directoryArray"

    return 0
}

searchFile() {
    # string file sf_parameter_1

    outputFunctionToLogFile "searchFile" "$1"

    requireFileExists "searchFile" "file" "$1" || return 1

    local sf_parameter_1="$1"

    showProgress

    # sf_shortFileNameTemp=$(trimPathForDisplay "$sf_parameter_1")

    # outputToConsole "\`searchFile()\` Check \`$sf_shortFileNameTemp\` file for uniqueness"

    #checkUniqueRecommendationFile "$sf_parameter_1" >/dev/null 2>&1 || {
    #    outputToLogFile "ERROR: \`searchFile()\` \`$sf_parameter_1\` file is not a valid recommendation";

    #    return 0;
    #}

    showProgress

    # outputToConsole "\`searchFile()\` Search \`$sf_shortFileNameTemp\` file for metadata keys and values"

    addMetadataValueMatrixInFile "$sf_parameter_1" || {
        outputToLogFile "ERROR: \`searchFile()\` \`$sf_parameter_1\` file one or metadata values are missing or not valid";

        printf "%s" " "

        return 0;
    }

    printf "%s" " "

    return 0
}

searchDirectory() {
    # string directory sd_parameter_1

    outputFunctionToLogFile "searchDirectory" "$1"

    requireDirectoryExists "searchDirectory" "${loadCleanArray[0]}" "$1" || {
        if [[ -f "$1" ]]; then
            searchFile "$1"

            return 0
        else
            outputToLogFile "ERROR: \`searchDirectory()\` \`$1\` is not a valid directory or file"

            return 1
        fi
    }

    local sd_parameter_1="$1"

    local sd_shortFileName

    showProgress

    # sd_shortFileName=$(trimPathForDisplay "$sd_parameter_1")

    # outputToConsole "\`searchDirectory()\` Search \`$sd_shortFileName\` ${loadCleanArray[0]}"

    for sd_fileTemp in "$sd_parameter_1"/*.md; do
        if [[ -f "$sd_fileTemp" ]]; then
            searchFile "$sd_fileTemp"
        else
            continue
        fi
    done

    printf "%s" " "

    return 0
}

searchFilesFromListFile() {
    # string file sfflf_parameter_1

    outputFunctionToLogFile "searchFilesFromListFile" "$1"

    requireFileExists "searchFilesFromListFile" "file" "$1" || return 1

    local sfflf_parameter_1="$1"

    sfflf_shortFileName=$(trimPathForDisplay "$sfflf_parameter_1")

    outputToConsole "\`searchFilesFromListFile()\` \`$sfflf_shortFileName\` search file found"

    sfflf_searchLines=$(< "$sfflf_parameter_1")

    for sfflf_searchLineTemp in $sfflf_searchLines; do
        if [[ -d "$sfflf_searchLineTemp" ]]; then
            # showProgress

            addValueToArray "$sfflf_searchLineTemp" "loadSearchArray" || continue

            outputToLogFile "\`searchFilesFromListFile()\` Search \`$sfflf_searchLineTemp\` directory"

            searchDirectory "$sfflf_searchLineTemp" || continue
        else
            outputToLogFile "ERROR: \`searchFilesFromListFile()\` \`$sfflf_searchLineTemp\` is not a valid directory"

            continue
        fi
    done

    return 0
}

addValuesFromDirectorySearch() {
    # ----

    outputFunctionToLogFile "addValuesFromDirectorySearch"

    outputToConsole "\`addValuesFromDirectorySearch()\` Make list of directories to search for metadata"

    verifyFileExists "$inputDirectoryDirectoryOutputTxt" || return 1

    searchFilesFromListFile "$inputDirectoryDirectoryOutputTxt" || return 1

    return 0
}

parseRequiredMetadataInFile() {
    # string file prmif_parameter_1
    # string name of associative array prmif_parameter_2

    outputFunctionToLogFile "parseRequiredMetadataInFile" "$1" "$2"

    requireFileExists "parseRequiredMetadataInFile" "file" "$1" || return 1

    requireParameterForFunction "parseRequiredMetadataInFile" "name of associative array" "$2" || return 1

    local prmif_parameter_1="$1"
    local prmif_assocName="$2"

    declare -n prmif_assoc="$prmif_assocName"

    for prmif_key in "${requiredMetadataArray[@]}"; do
        prmif_value="$(getMetadataValueInFile "$prmif_parameter_1" "$prmif_key" 2>/dev/null || printf '%s' "nomatch")"

        prmif_assoc["$prmif_key"]="$prmif_value"
    done

    return 0
}

verifyRequiredMetadataKeysInFile() {
    # string file vrmkif_parameter_1

    outputFunctionToLogFile "verifyRequiredMetadataKeysInFile" "$1"

    requireFileExists "verifyRequiredMetadataKeysInFile" "file" "$1" || {
        printf "nomatch";

        return 1;
    }

    local vrmkif_parameter_1="$1"

    local -A vrmkif_metadataValuesArray

    parseRequiredMetadataInFile "$vrmkif_parameter_1" vrmkif_metadataValuesArray

    for vrmkif_metadataKeyTemp in "${requiredMetadataArray[@]}"; do
        if [[ -z "${vrmkif_metadataValuesArray[$vrmkif_metadataKeyTemp]+_}" || "${vrmkif_metadataValuesArray[$vrmkif_metadataKeyTemp]}" == "nomatch" ]]; then
            outputToLogFile "ERROR: \`verifyRequiredMetadataKeysInFile()\` \`$vrmkif_metadataKeyTemp\` metadata key not found in \`$vrmkif_parameter_1\` file"

            printf "%s" "nomatch"

            return 1
        fi
    done

    outputToLogFile "\`verifyRequiredMetadataKeysInFile()\` \`$vrmkif_parameter_1\` file contains all required metadata keys for recommendation"

    printf "%s" "match"

    return 0
}

encodeMetadataToString() {
    # string dataSource emts_parameter_1
    # string refreshInterval emts_parameter_2
    # string retirementDate emts_parameter_3
    # string retirementFeatureName emts_parameter_4
    # string schemaVersion emts_parameter_5
    # string service emts_parameter_6
    # string streamNamespace emts_parameter_7

    outputFunctionToLogFile "encodeMetadataToString"

    requireParameterForFunction "encodeMetadataToString" "dataSource" "$1" || return 1
    requireParameterForFunction "encodeMetadataToString" "refreshInterval" "$2" || return 1
    requireParameterForFunction "encodeMetadataToString" "retirementDate" "$3" || return 1
    requireParameterForFunction "encodeMetadataToString" "retirementFeatureName" "$4" || return 1
    requireParameterForFunction "encodeMetadataToString" "schemaVersion" "$5" || return 1
    requireParameterForFunction "encodeMetadataToString" "service" "$6" || return 1
    requireParameterForFunction "encodeMetadataToString" "streamNamespace" "$7" || return 1

    local emts_parameter_1="$1"
    local emts_parameter_2="$2"
    local emts_parameter_3="$3"
    local emts_parameter_4="$4"
    local emts_parameter_5="$5"
    local emts_parameter_6="$6"
    local emts_parameter_7="$7"

    local emts_availableResourcesTemp
    local emts_availableResourcesValueTemp
    local emts_outputStringTemp

    outputToLogFile "\`$emts_shortFileNameTemp\` file has the following metadata values"
    outputToLogFile "   \`$emts_parameter_1\` \`dataSource\` metadata value"
    outputToLogFile "   \`$emts_parameter_2\` \`refreshInterval\` metadata value"
    outputToLogFile "   \`$emts_parameter_3\` \`retirementDate\` metadata value"
    outputToLogFile "   \`$emts_parameter_4\` \`retirementFeatureName\` metadata value"
    outputToLogFile "   \`$emts_parameter_5\` \`schemaVersion\` metadata value"
    outputToLogFile "   \`$emts_parameter_6\` \`service\` metadata value"
    outputToLogFile "   \`$emts_parameter_7\` \`streamNamespace\` metadata value"

    emts_availableResourcesTemp=0

    for ects_countTemp in 1 2 5 7; do
        ects_parameterName="emts_parameter_$ects_countTemp"

        if [[ -z "${!ects_parameterName}" || "${!ects_parameterName}" == "MISSING" ]]; then
            emts_availableResourcesTemp=1

            break
        fi
    done

    if (( emts_availableResourcesTemp > 0 )); then
        emts_availableResourcesValueTemp="No"
    else
        emts_availableResourcesValueTemp="Yes"
    fi

    emts_outputStringTemp="$emts_parameter_6|$emts_parameter_4|$emts_parameter_3|$emts_availableResourcesValueTemp|"

    emts_shortFileNameTemp=$(trimPathForDisplay "$emts_parameter_1")

    outputToLogFile "\`encodeMetadataToString()\` \`$emts_shortFileNameTemp\` file has \`$emts_outputStringTemp\` metadata value matrix"

    printf "%s" "$emts_outputStringTemp"

    return 0
}

getValueForKeyInJson() {
    # string json value gvfkij_parameter_1
    # string metadata key gvfkij_parameter_2

    outputFunctionToLogFile "getValueForKeyInJson" "$1" "$2"

    requireParameterForFunction "getValueForKeyInJson" "json value" "$1" || return 1
    requireParameterForFunction "getValueForKeyInJson" "metadata key" "$2" || return 1

    local gvfkij_parameter_1="$1"
    local gvfkij_parameter_2="$2"

    local gvfkij_metadataValueTemp
    local gvfkij_metadataValueCleanTemp

    gvfkij_metadataValueTemp=$(printf "%s" "$gvfkij_parameter_1" | grep -oP "\"$gvfkij_parameter_2\":\s*\"\K[^\"]+") || {
        outputToLogFile "ERROR: \`getValueForKeyInJson()\` \`$gvfkij_parameter_1\` does not contain \`$gvfkij_parameter_2\` metadata key"

        printf "%s" "nomatch"

        return 1
    }

    gvfkij_metadataValueCleanTemp=$(printf "%s" "$gvfkij_metadataValueTemp" | sed -E "s/^[[:space:]]+//; s/[[:space:]]+$//")

    printf "%s" "$gvfkij_metadataValueCleanTemp"

    return 0
}

getMetadataValueMatrixInJson() {
    # string json value gmvmij_parameter_1

    outputFunctionToLogFile "getMetadataValueMatrixInJson" "$1"

    requireParameterForFunction "getMetadataValueMatrixInJson" "json value" "$1" || return 1

    requireArrayExists "getMetadataValueMatrixInJson" "name of array" "metadataArray" || return 1

    local gmvmij_parameter_1="$1"

    local gmvmij_requiredValuesMatrixTemp

    gmvmij_requiredValuesMatrixTemp=""

    # metadataArray=( "service" "retirementFeatureName" "retirementDate" "recommendationCategory" "recommendationSubCategory" "dataSource" "refreshInterval" "schemaVersion" "streamNamespace" "recommendationMetadataState" "recommendationTypeId" "sourceProperties" "serviceRetirement" "dataSourceMetadata" "recommendationImpact" )

    for gmvmij_metadataKey in "${metadataArray[@]}"; do
        local gmvmij_metadataValue

        gmvmij_metadataValue=$(getValueForKeyInJson "$gmvmij_parameter_1" "$gmvmij_metadataKey") || gmvmij_metadataValue="MISSING"

        gmvmij_requiredValuesMatrixTemp+=$(printf "%s|" "$gmvmij_metadataValue")

        if [[ "$gmvmij_metadataKey" == "retirementDate" ]]; then
            addValueToArray "$gmvmij_metadataValue" "dateListArray" || return 1

            outputToConsole "\`getMetadataValueMatrixInJson()\` Found retirement date \`$gmvmij_metadataValue\`"
        elif [[ "$gmvmij_metadataKey" == "service" ]]; then
            addValueToArray "$gmvmij_metadataValue" "serviceListArray" || return 1

            outputToConsole "\`getMetadataValueMatrixInJson()\` Found service \`$gmvmij_metadataValue\`"
        elif [[ "$gmvmij_metadataKey" == "retirementFeatureName" ]]; then
            addValueToArray "$gmvmij_metadataValue" "featureListArray" || return 1

            outputToConsole "\`getMetadataValueMatrixInJson()\` Found feature \`$gmvmij_metadataValue\`"
        fi
    done

    addValueToArray "$gmvmij_requiredValuesMatrixTemp" "metadataValueMatrixArray" || return 1

    return 0
}

selectDirectoriesToSearch() {
    # ----

    outputFunctionToLogFile "selectDirectoriesToSearch"

    requireArrayExists "selectDirectoriesToSearch" "name of array" "loadSearchArray" || return 1

    sdts_arrayNameTemp="loadSearchArray"

    outputToConsole "Search directories for metadata"

    if declare -p "$sdts_arrayNameTemp" >/dev/null 2>&1; then
        declare -n sdts_arrayTemp="$sdts_arrayNameTemp"
    else
        setLocalArrayFromArrayName "$sdts_arrayNameTemp" "sdts_arrayTemp"
    fi

    for sdts_directoryTemp in "${sdts_arrayTemp[@]}"; do
        searchDirectory "$sdts_directoryTemp"
    done

    return 0
}

createHeader() {
    # ----

    outputToLogFile "\`createHeader()\`"

    ch_headerValueTemp=$(
        printf "%s\n" "${progressArray[6]}"
        printf "%s\n" "${includeFrontMatterArray[0]}"
        printf "%s\n" "${includeFrontMatterArray[1]}"
        printf "%s\n" "${includeFrontMatterArray[2]}"
        printf "%s\n" "${progressArray[6]}"
    ) || {
        outputToLogFile "ERROR: \`createHeader()\` unable to create header value"

        return 1
    }

    outputToLogFile "\`createHeader()\` \`$ch_headerValueTemp\` header value created"

    printf "%s" "$ch_headerValueTemp"

    return 0
}

decodeMetadataValueMatrix() {
    # string metadataValueMatrix dmvm_parameter_1
    # integer index dmvm_parameter_2

    outputFunctionToLogFile "decodeMetadataValueMatrix" "$1"

    requireParameterForFunction "decodeMetadataValueMatrix" "metadataValueMatrix value" "$1" || return 1
    requireParameterForFunction "decodeMetadataValueMatrix" "index" "$2" || return 1
    local dmvm_parameter_1="$1"
    local dmvm_parameter_2="$2"

    local dmvm_valueTemp

    local -a dmvm_arrayTemp

    # metadataArray=( "service" "retirementFeatureName" "retirementDate" "recommendationCategory" "recommendationSubCategory" "dataSource" "refreshInterval" "schemaVersion" "streamNamespace" "recommendationMetadataState" "recommendationTypeId" "sourceProperties" "serviceRetirement" "dataSourceMetadata" "recommendationImpact" )

    IFS='|' read -r -a dmvm_arrayTemp <<< "$dmvm_parameter_1" || {
        outputToLogFile "ERROR: \`decodeMetadataValueMatrix()\` cannot parse \`$dmvm_parameter_1\` metadataValueMatrix value"

        return 1
    }

    dmvm_valueTemp=$(printf "%s" "${dmvm_arrayTemp[$dmvm_parameter_2]}") || {
        outputToLogFile "ERROR: \`decodeMetadataValueMatrix()\` cannot extract index \`$dmvm_parameter_2\` from \`$dmvm_parameter_1\` metadataValueMatrix value"

        return 1
    }

    printf "%s" "$dmvm_valueTemp"

    return 0
}

createBodyItem() {
    # string metadataValueMatrix value cbi_parameter_9

    outputToLogFile "\`createBodyItem() \"$1\"\`"

    requireParameterForFunction "createBodyItem" "metadataValueMatrix value" "$1" || return 1

    local cbi_parameter_1="$1"

    local cbi_availableResourcesTemp
    local cbi_bodyItemTemp
    local cbi_impactedResourcesAvailableTemp
    local cbi_normalizeImpactedResourcesAvailableTemp
    local cbi_retirementFeatureNameTemp
    local cbi_serviceTemp

    # metadataArray=( "service" "retirementFeatureName" "retirementDate" "recommendationCategory" "recommendationSubCategory" "dataSource" "refreshInterval" "schemaVersion" "streamNamespace" "recommendationMetadataState" "recommendationTypeId" "sourceProperties" "serviceRetirement" "dataSourceMetadata" "recommendationImpact" )

    cbi_serviceTemp=$(decodeMetadataValueMatrix "$cbi_parameter_1" "0")
    cbi_retirementFeatureNameTemp=$(decodeMetadataValueMatrix "$cbi_parameter_1" "1")
    cbi_impactedResourcesAvailableTemp=$(decodeMetadataValueMatrix "$cbi_parameter_1" "14")

    cbi_normalizeImpactedResourcesAvailableTemp=$(normalizeString "$cbi_impactedResourcesAvailableTemp")

    if [[ "$cbi_normalizeImpactedResourcesAvailableTemp" == "yes" ]]; then
        cbi_availableResourcesTemp="[!INCLUDE [Available](../../includes/inline-reusable-text/available-option.md)]"
    elif [[ "$cbi_normalizeImpactedResourcesAvailableTemp" == "no" ]]; then
        cbi_availableResourcesTemp="[!INCLUDE [Not available](../../includes/inline-reusable-text/not-available-option.md)]"
    fi

    cbi_bodyItemTemp=$(
        printf "| %s | %s | %s |" "$cbi_serviceTemp" "$cbi_retirementFeatureNameTemp" "$cbi_availableResourcesTemp"
    )

    printf "%s" "$cbi_bodyItemTemp" || {
        outputToLogFile "ERROR: \`createBodyItem()\` unable to create body item value"

        return 1
    }

    return 0
}

createBodySection() {
    # string date cbs_parameter_1

    outputToLogFile "\`createBodySection() \"$1\"\`"

    requireParameterForFunction "createBodySection" "date value" "$1" || return 1

    local cbs_parameter_1="$1"

    local cbs_dateHeadingTemp
    local cbs_dateTableHeaderTemp
    local cbs_sectionHeadingTemp
    local cbs_sectionTemp
    local cbs_sectionValueTemp

    local -a cbs_metadataValueMatrixListArray

    # cbs_dateHeadingTemp="$(gdate "$cbs_parameter_1" +%B, %e, %Y)"
    cbs_dateHeadingTemp="$(date -d "$cbs_parameter_1" +%B, %e, %Y)"

    cbs_dateTableHeaderTemp=$(printf "%s\n" "${sectionTableArray[*]}")

    cbs_sectionHeadingTemp=$(
        printf "%s %s\n" "${headingArray[4]}" "$cbs_dateHeadingTemp"
        printf "\n"
        printf "%s" "$cbs_dateTableHeaderTemp"
    )

    cbs_sectionTemp=""

    setLocalArrayFromArrayName "loadArray" "cbs_metadataValueMatrixListArray" || return 1

    for cbs_metadataValueMatrixTemp in "${cbs_metadataValueMatrixListArray[@]}"; do
        showProgress

        local cbs_retirementDateTemp
        local cbs_recommendationMetadataStateTemp
        local cbs_recommendationSubCategoryTemp
        local cbs_sectionItemTemp

        cbs_retirementDateTemp=$(decodeMetadataValueMatrix "$cbs_metadataValueMatrixTemp" "2")

        [[ "$cbs_retirementDateTemp" == "$cbs_parameter_1" ]] || continue

        cbs_recommendationSubCategoryTemp=$(decodeMetadataValueMatrix "$cbs_metadataValueMatrixTemp" "4")

        [[ "$cbs_recommendationSubCategoryTemp" == "ServiceUpgradeAndRetirement" ]] || continue

        cbs_recommendationMetadataStateTemp=$(decodeMetadataValueMatrix "$cbs_metadataValueMatrixTemp" "9")

        [[ "$cbs_recommendationMetadataStateTemp" == "Active" ]] || continue

        cbs_sectionItemTemp=$(createBodyItem "$cbs_metadataValueMatrixTemp") || continue

        if [[ -n "$cbs_sectionTemp" ]]; then
            cbs_sectionTemp=$(printf "%s\n%s" "$cbs_sectionTemp" "$cbs_sectionItemTemp") || continue
        else
            cbs_sectionTemp="$cbs_sectionItemTemp"
        fi
    done

    [[ -n "$cbs_sectionTemp" ]] || {
        outputToLogFile "ERROR: \`createBodySection()\` no active recommendations found for \`$cbs_parameter_1\` retirement date"

        return 1
    }

    cbs_sectionValueTemp=$(printf "%s\n%s" "$cbs_sectionHeadingTemp" "$cbs_sectionTemp") || return 1

    printf "%s" "$cbs_sectionValueTemp"

    return 0
}

createBody() {
    # string short date cb_parameter_2

    outputToLogFile "\`createBody() \"$1\"\`"

    requireParameterForFunction "createBody" "short date value" "$1" || return 1

    local cb_parameter_1="$1"

    local cb_bodyTemp

    cb_bodyTemp=""

    for cb_dayTemp in {01..31}; do
        showProgress

        local cb_dateFullTemp
        local cb_sectionTemp

        cb_dateFullTemp=$(printf "%s-%s" "$cb_parameter_1" "$cb_dayTemp")

        cb_sectionTemp=$(createBodySection "$cb_dateFullTemp") || continue

        if [[ -n "$cb_bodyTemp" ]]; then
            cb_bodyTemp=$(printf "%s\n\n%s" "$cb_bodyTemp" "$cb_sectionTemp") || continue
        else
            cb_bodyTemp="$cb_sectionTemp"
        fi
    done

    [[ -n "$cb_bodyTemp" ]] || {
        outputToLogFile "ERROR: \`createBody()\` no active recommendations found for \`$cb_parameter_1\` retirement date"

        return 1
    }

    printf "%s" "$cb_bodyTemp"

    return 0
}

createIncludeFile() {
    # string short date cif_parameter_1

    outputToLogFile "\`createIncludeFile() \"$1\"\`"

    requireParameterForFunction "createIncludeFile" "short date value" "$1" || return 1

    local cif_parameter_1="$1"

    local cif_bodyValueTemp
    local cif_headerValueTemp
    local cif_includeFileTemp
    
    cif_headerValueTemp=$(createHeader) || return 1

    cif_bodyValueTemp=$(createBody "$cif_parameter_1") || {
        outputToLogFile "ERROR: \`createIncludeFile()\` no active recommendations found for \`$cif_parameter_1\` retirement date"

        return 1
    }

    cif_includeFileTemp=$(printf "%s\n\n%s" "$cif_headerValueTemp" "$cif_bodyValueTemp") || {
        outputToLogFile "ERROR: \`createIncludeFile()\` unable to create include content for \`$cif_parameter_1\` retirement date"

        return 1 
    }

    outputToLogFile "\`createIncludeFile()\` include content created for \`$cif_parameter_1\` retirement date"

    printf "%s" "$cif_includeFileTemp"

    return 0
}

trimDateForFileName() {
    # string date tdf_parameter_1

    outputFunctionToLogFile "trimDateForFileName" "$1"

    requireParameterForFunction "trimDateForFileName" "date value" "$1" || return 1

    local tdf_parameter_1="$1"

    local tdf_dateTemp

    tdf_dateTemp=$(printf "%s" "$tdf_parameter_1" | cut -d'-' -f1,2) || {
        outputToLogFile "ERROR: \`trimDateForFileName()\` cannot parse \`$tdf_parameter_1\` date value"

        return 1
    }

    printf "%s" "$tdf_dateTemp"

    return 0
}

createIncludeFilesFromArray() {
    # ----

    outputFunctionToLogFile "createIncludeFilesFromArray"

    requireArrayExists "createIncludeFilesFromArray" "name of array" "dateListArray" || return 1

    local -a ciffa_dateListArray

    setLocalArrayFromArrayName "dateListArray" "ciffa_dateListArray" || return 1

    for ciffa_dateTemp in "${ciffa_dateListArray[@]}"; do
        showProgress

        if [[ "$ciffa_dateTemp" != "MISSING" ]]; then
            local ciffa_dateShortTemp
            local ciffa_includeFileTemp
            local ciffa_outputIncludeFile

            ciffa_dateShortTemp=$(trimDateForFileName "$ciffa_dateTemp")
            ciffa_includeFileTemp=$(createIncludeFile "$ciffa_dateShortTemp") || continue

            

            if [[ -z "$ciffa_outputIncludeFile" ]]; then
               outputToRawNamedFile "retirement-date.$ciffa_dateShortTemp" "md" "$ciffa_includeFileTemp"
            fi
        fi
    done

    return 0
}

main() {
    # ----

    outputFunctionToLogFile "main"

    local durationEpochTime
    local endEpochTime
    local endTime
    local startEpochTime
    local startTime

    startEpochTime="$(date +%s)"
    startTime="$(date +%Y%b%d-%H%M)"

    initializeDirectories

    addValuesFromDirectorySearch || searchDirectory "$articlesSelfhelpcontentDirectory"

    loopAllActiveArrays

    createIncludeFilesFromArray

    endEpochTime="$(date +%s)"
    endTime="$(date +%Y%b%d-%H%M)"

    ((durationEpochTime=endEpochTime-startEpochTime))

    outputToLogFile "Completed \`$startTime\` to \`$endTime\` = \`$durationEpochTime\` seconds"

    outputToConsole "Completed \`$startTime\` to \`$endTime\` = \`$durationEpochTime\` seconds"
}

time main
