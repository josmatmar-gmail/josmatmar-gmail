#!/usr/bin/env bash
# require bash >= 4.3 for 'declare -n' and readarray

if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3) )); then
    printf '%s\n' "ERROR: Update to Bash 4.3 or newer (current: $BASH_VERSION)" >&2
    printf '%s\n' "This script requires Bash >= 4.3 for 'declare -n' and 'readarray'."
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
#
# rerun
#
# real    19m9.372s
# user    0m59.197s
# sys     0m30.836s

dateStamp=$(printf "%s" "$(date +%Y%b%d-%H%M)")

if [[ -n "${WSL_DISTRO_NAME:-}" && -d "/mnt/c/Users/$(id -un)" ]]; then
    userProfile="/mnt/c/Users/$(id -un)"   # WSL priority
elif [[ "$(uname -s)" == "Darwin" ]]; then
    userProfile="/Users/$(id -un)"         # macOS
else
    userProfile="${HOME:-/home/$(id -un)}" # Linux (prefer HOME)
fi

gitDirectory="$userProfile/git"
scriptDirectory="$userProfile/bash/scripts"

inputDirectory="$scriptDirectory/input"
outputDirectory="$scriptDirectory/output"
temporaryDirectory="$scriptDirectory/temporary"

# outputIncludesDirectory="$outputDirectory/includes"

learnAdvisorDirectory="$gitDirectory/jm-247-ms/azure-monitor-docs-pr/articles/advisor"
selfHelpContentDirectory="$gitDirectory/jm-247-ms/SelfHelpContent"

articlesSelfhelpcontentDirectory="$selfHelpContentDirectory/articles"

includesAdvisorLearnDirectory="$learnAdvisorDirectory/includes"
# includesAdvisorLearnRetiringFeatureDirectory="$includesAdvisorLearnDirectory/retiring-feature"

temporaryDateRaw="$temporaryDirectory/$dateStamp-stiif-RAW"

inputDirectoryDirectoryOutputTxt="$inputDirectory/stiif-directory-Output.txt"

# learnAdvisorHowToUseServiceUpgradeRetirementRecommendationsMd="$learnAdvisorDirectory/advisor-how-to-use-service-upgrade-retirement-recommendations.md"

outputDateRawLogTxt="$outputDirectory/$dateStamp-stiif-RAW-Log.txt"

coverageOfServicesNote="Although the current coverage of services for retirement recommendations in Advisor isn't comprehensive, it serves as a solid starting point. At the current time, the platform doesn't have information about the **Impacted Resources** for a subset of recommendations. Based on your need, use any of the listed ways to get the required information."

cloudarray=( "fairfax" "mooncake" "public" "usnat" "ussec" )
dateincludebodysectionsmatrixarray=( "date" "includeBodySection" )
headingarray=( "# " "## " "### " "#### " "##### " "Retirement Recommendations for" )
includefrontmatterarray=( "---" "title: Retirement Recommendations" "description: List of retirement recommendations" "---" )
# loadcleanarray=( "directory" "loaddirectory" "learnadvisor" "selfhelpcontent" "norecommendationdirectory" )
metadataarray=( "recommendationMetadataState" "recommendationSubCategory" "retirementDate" "service" "serviceTreeId" "retirementFeatureName" )
progressArray=( "." ". " "..." "... " "+" "-" "---" "*" )
# requiredmetadataarray=( "service" "retirementFeatureName" "retirementDate" "recommendationCategory" "recommendationSubCategory" "recommendationMetadataState" "recommendationTypeId" "sourceProperties" "serviceRetirement" )
sectiontablearray=( "| Service | Feature Name | Availability |" "|--------|--------------|-------------|" )

declare -g -a arraynamelistarray=()
declare -g -a dateincludebodysectionsarray=()
declare -g -a retirementdatelistarray=()
declare -g -a directoryarray=()
declare -g -a filemetadatamatrixarray=()

# output

outputToConsole() {
    # *

    printf '\n%s\n' "$*"
}

outputToLogFile() {
    # *

    [[ -n "${outputDateRawLogTxt:-}" ]] || return 0

    [[ -d "$outputDirectory" ]] || {
        mkdir -p "$outputDirectory"
    }

    printf '%s\n' "$*" >> "$outputDateRawLogTxt"
}

outputToRawNamedFile() {
    # string outputFileName otrnf_parameter_1
    # string outputFileExtension otrnf_parameter_2
    # string content (all remaining args)

    local otrnf_parameter_1="$1"
    local otrnf_parameter_2="$2"
    shift 2

    local otrnf_outputFileName

    otrnf_outputFileName=$(printf "%s-%s.%s" "$temporaryDateRaw" "$otrnf_parameter_1" "$otrnf_parameter_2")

    [[ -n "${otrnf_outputFileName:-}" ]] || return 1

    [[ -d "$temporaryDirectory" ]] || mkdir -p "$temporaryDirectory"

    if ! touch "$otrnf_outputFileName" 2>&1 | outputToLogFile; then
        outputToLogFile "ERROR: \`outputToRawNamedFile()\` failed to write to \`$otrnf_outputFileName\`"
        return 1
    fi

    printf '%s\n' "$*" > "$otrnf_outputFileName"

    return 0
}

outputFunctionToLogFile() {
    # string function oftlf_parameter_1

    requireParameterForFunction "outputFunctionToLogFile" "function" "$1" || {
         outputToLogFile "ERROR: \`outputFunctionToLogFile()\` name of function not provided";

        return 1;
    }

    local oftlf_parameter_1="$1"

    shift

    local oftlf_parameter_2="$*"

    [[ -n "$oftlf_parameter_2" ]] || {
        outputToLogFile "\`> $ $oftlf_parameter_1()\`"

        return 0
    }

    outputToLogFile "\`> $ $oftlf_parameter_1() \"$oftlf_parameter_2\"\`"

    return 0
}

# utilty

getPathForFile() {
    # string file gpf_parameter_1

    outputFunctionToLogFile "getPathForFile" "$1"

    requireFileExists "getPathForFile" "file" "$1" || return 1

    local gpf_parameter_1="$1"

    local gpff_path

    gpff_path="${gpf_parameter_1%/*}"

    printf "%s" "$gpff_path"

    return 0
}

getFileExtensionForFile() {
    # string file gfeff_parameter_1

    outputFunctionToLogFile "getFileExtensionForFile" "$1"

    requireFileExists "getFileExtensionForFile" "file" "$1" || return 1

    local gfeff_parameter_1="$1"

    local gfeff_baseNameTemp
    local gfeff_extensionTemp

    gfeff_baseNameTemp=$(basename -- "$gfeff_parameter_1")

    gfeff_extensionTemp="${gfeff_baseNameTemp##*.}"

    [[ "$gfeff_extensionTemp" == "$gfeff_baseNameTemp" ]] && {
        printf "%s" ""

        return 0
    }

    printf "%s" "$gfeff_extensionTemp"

    return 0
}

getShortNameForFile() {
    # string file gsnff_parameter_1

    outputFunctionToLogFile "getShortNameForFile" "$1"

    requireFileExists "getShortNameForFile" "file" "$1" || return 1

    local gsnff_parameter_1="$1"

    local gsnff_baseNameTemp

    gsnff_baseNameTemp=$(basename -- "$gsnff_parameter_1")

    printf "%s" "${gsnff_baseNameTemp%.*}"

    return 0
}

normalizeString() {
    # string input ns_parameter_1

    outputFunctionToLogFile "normalizeString" "$1"

    requireParameterForFunction "normalizeString" "input" "$1" || return 1

    local ns_parameter_1="$1"

    local ns_stringTemp

    {
        ns_stringTemp=$(printf '%s' "$ns_parameter_1" | tr -cd '[:alnum:]_' | tr '[:upper:]' '[:lower:]')
    } || {
        outputToLogFile "ERROR: \`normalizeString()\` failed to normalize \`$ns_parameter_1\` input"

        return 1
    }

    printf '%s' "$ns_stringTemp"

    return 0
}

toLowerString() {
    # string input tls_parameter_1

    outputFunctionToLogFile "toLowerString" "$1"

    requireParameterForFunction "toLowerString" "input" "$1" || return 1

    local tls_parameter_1="$1"

    local tls_stringTemp

    {
        tls_stringTemp=$(printf '%s' "$tls_parameter_1" | tr '[:upper:]' '[:lower:]')
    } || {
        outputToLogFile "ERROR: \`toLowerString()\` failed to convert \`$tls_parameter_1\` input to lower case"

        return 1
    }

    printf '%s' "$tls_stringTemp"

    return 0
}

getYearMonthFromDate() {
    # string date gymfd_parameter_1

    outputFunctionToLogFile "getYearMonthFromDate" "$1"

    requireParameterForFunction "getYearMonthFromDate" "date value" "$1" || return 1

    local gymfd_parameter_1="$1"

    local gymfd_yearTemp
    local gymfd_monthTemp

    [[ "$gymfd_parameter_1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || {
        outputToLogFile "INFO: \`getStringFromDate()\` converting \`$gymfd_parameter_1\` reserve date to standard date format"

        gymfd_parameter_1=$(getDateFromReverseDate "$gymfd_parameter_1") || return 1
    }
    


    {
        gymfd_yearTemp=$(printf "%s" "$gymfd_parameter_1" | cut -d'-' -f1) || return 1;
        gymfd_monthTemp=$(printf "%s" "$gymfd_parameter_1" | cut -d'-' -f2) || return 1;
    } || {
        outputToLogFile "ERROR: \`getYearMonthFromDate()\` failed to parse \`$gymfd_parameter_1\` date value"

        printf "%s" "nomatch"

        return 1
    }

    printf "%s-%s" "$gymfd_yearTemp" "$gymfd_monthTemp"

    return 0
}

cleanDay() {
    # integer day cd_parameter_1

    local cd_parameter_1="$1"

    [[ "$cd_parameter_1" =~ ^[0-3][0-9]$ ]] || {
        outputToLogFile "ERROR: \`cleanDay()\` failed to validate \`$cd_parameter_1\` day value is an integer"

        printf "%s" "00"

        return 1
    }

    if [[ "$cd_parameter_1" =~ ^0[0-9]$ ]]; then
        cd_parameter_1="${cd_parameter_1#0}"
    fi

    if (( cd_parameter_1 < 1 || cd_parameter_1 > 31 )); then
        outputToLogFile "ERROR: \`cleanDay()\` failed to validate \`$cd_parameter_1\` day value"

        printf "%s" "nomatch"

        return 1
    fi

    printf "%s" "$cd_parameter_1"

    return 0
}

getStringFromMonth() {
    # integer month gsfm_parameter_1

    outputFunctionToLogFile "getStringFromMonth" "$1"

    requireParameterForFunction "getStringFromMonth" "month value" "$1" || return 1

    local gsfm_parameter_1="$1"

    [[ "$gsfm_parameter_1" =~ ^[0-1][0-9]$ ]] || {
        outputToLogFile "ERROR: \`getStringFromMonth()\` failed to validate \`$gsfm_parameter_1\` month value is an integer"

        printf "%s" "nomatch"

        return 1
    }

    if [[ "$gsfm_parameter_1" =~ ^0[0-9]$ ]]; then
        gsfm_parameter_1="${gsfm_parameter_1#0}"
    fi

    if (( gsfm_parameter_1 < 1 || gsfm_parameter_1 > 12 )); then
        outputToLogFile "ERROR: \`getStringFromMonth()\` failed to validate \`$gsfm_parameter_1\` month value"

        printf "%s" "nomatch"

        return 1
    fi

    case "$gsfm_parameter_1" in
        1) printf "%s" "January" ;;
        2) printf "%s" "February" ;;
        3) printf "%s" "March" ;;
        4) printf "%s" "April" ;;
        5) printf "%s" "May" ;;
        6) printf "%s" "June" ;;
        7) printf "%s" "July" ;;
        8) printf "%s" "August" ;;
        9) printf "%s" "September" ;;
        10) printf "%s" "October" ;;
        11) printf "%s" "November" ;;
        12) printf "%s" "December" ;;
        *) printf "%s" "Unknown" ;;
    esac

    return 0
}

getDateFromReverseDate() {
    # string date gdfrd_parameter_1

    outputFunctionToLogFile "getDateFromReverseDate" "$1"

    requireParameterForFunction "getDateFromReverseDate" "date value" "$1" || return 1

    local gdfrd_parameter_1="$1"

    local gdfrd_yearTemp
    local gdfrd_monthTemp
    local gdfrd_dayTemp

    {
        gdfrd_dayTemp=$(printf "%s" "$gdfrd_parameter_1" | cut -d'-' -f1) || return 1;
        gdfrd_monthTemp=$(printf "%s" "$gdfrd_parameter_1" | cut -d'-' -f2) || return 1;
        gdfrd_yearTemp=$(printf "%s" "$gdfrd_parameter_1" | cut -d'-' -f3) || return 1;
    } || {
        outputToLogFile "ERROR: \`getDateFromReverseDate()\` failed to parse \`$gdfrd_parameter_1\` date value"

        printf "%s" "nomatch"

        return 1
    }

    printf "%s-%s-%s" "$gdfrd_yearTemp" "$gdfrd_monthTemp" "$gdfrd_dayTemp"

    return 0
}

getStringFromDate() {
    # string date gsf_parameter_1

    outputFunctionToLogFile "getStringFromDate" "$1"

    requireParameterForFunction "getStringFromDate" "date value" "$1" || return 1

    local gsf_parameter_1="$1"

    local gsf_yearTemp
    local gsf_monthTemp
    local gsf_dayTemp
    local gsf_monthStringTemp
    local gsf_cleanDayTemp

    [[ "$gsf_parameter_1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || {
        outputToLogFile "INFO: \`getStringFromDate()\` converting \`$gsf_parameter_1\` reverse date to standard date format"

        gsf_parameter_1=$(getDateFromReverseDate "$gsf_parameter_1") || return 1
    }

    {
        gsf_yearTemp=$(printf "%s" "$gsf_parameter_1" | cut -d'-' -f1) || return 1;
        gsf_monthTemp=$(printf "%s" "$gsf_parameter_1" | cut -d'-' -f2) || return 1;
        gsf_dayTemp=$(printf "%s" "$gsf_parameter_1" | cut -d'-' -f3) || return 1;

        gsf_monthStringTemp=$(getStringFromMonth "$gsf_monthTemp") || return 1;
        gsf_cleanDayTemp=$(cleanDay "$gsf_dayTemp") || return 1;
    } || {
        outputToLogFile "ERROR: \`getStringFromDate()\` failed to parse \`$gsf_parameter_1\` date value"

        printf "%s" "nomatch"

        return 1
    }

    printf "%s %s, %s" "$gsf_monthStringTemp" "$gsf_cleanDayTemp" "$gsf_yearTemp"

    return 0
}

getValueFromMetadataKeyForFileMetadataMatrix() {
    # string fileMetadataValueMatrix gvfmkffmm_parameter_1
    # string metadata key gvfmkffmm_parameter_2

    outputFunctionToLogFile "getValueFromMetadataKeyForFileMetadataMatrix" "$1" "$2"

    requireParameterForFunction "getValueFromMetadataKeyForFileMetadataMatrix" "fileMetadataValueMatrix value" "$1" || return 1
    requireParameterForFunction "getValueFromMetadataKeyForFileMetadataMatrix" "metadata key" "$2" || return 1

    verifyArrayExists "metadataarray" || {
        outputToLogFile "ERROR: \`getValueFromMetadataKeyForFileMetadataMatrix()\` failed to verify \`metadataarray\` exists";

        return 1;
    }

    local gvfmkffmm_parameter_1="$1"
    local gvfmkffmm_parameter_2="$2"

    local gvfmkffmm_indexTemp
    local gvfmkffmm_metadataValueTemp

    gvfmkffmm_indexTemp=-1

    if [[ "$gvfmkffmm_parameter_2" == "filePath" ]]; then
        gvfmkffmm_indexTemp=0
    else
        for gvfmkffmm_metadataKeyIndexTemp in "${!metadataarray[@]}"; do
            if [[ "${metadataarray[$gvfmkffmm_metadataKeyIndexTemp]}" == "$gvfmkffmm_parameter_2" ]]; then
                gvfmkffmm_indexTemp=$((gvfmkffmm_metadataKeyIndexTemp + 1))
        
                break
            fi
        done
    fi

    if (( gvfmkffmm_indexTemp == -1 )); then
        outputToLogFile "ERROR: \`getValueFromMetadataKeyForFileMetadataMatrix()\` failed to find \`$gvfmkffmm_parameter_1\` metadata key in \`metadataarray\`";

        return 1;
    fi

    gvfmkffmm_metadataValueTemp=$(decodeFileMetadataMatrix "$gvfmkffmm_parameter_1" "$gvfmkffmm_indexTemp") || {
        outputToLogFile "ERROR: \`getValueFromMetadataKeyForFileMetadataMatrix()\` failed to decode \`$gvfmkffmm_parameter_1\` metadata key value from \`$gvfmkffmm_parameter_1\` fileMetadataValueMatrix value";

        return 1
    }

    printf "%s" "$gvfmkffmm_metadataValueTemp"

    return 0
}

getValueFromMetadataKeyForDateIncludeBodySectionsMatrix() {
    # string dateIncludeBodySectionsMatrix gvfmkffmm_parameter_1
    # string metadata key gvfmkffmm_parameter_2

    outputFunctionToLogFile "getValueFromMetadataKeyForDateIncludeBodySectionsMatrix" "$1" "$2"

    requireParameterForFunction "getValueFromMetadataKeyForDateIncludeBodySectionsMatrix" "dateIncludeBodySectionsMatrix value" "$1" || return 1
    requireParameterForFunction "getValueFromMetadataKeyForDateIncludeBodySectionsMatrix" "metadata key" "$2" || return 1

    verifyArrayExists "dateincludebodysectionsmatrixarray" || {
        outputToLogFile "ERROR: \`getValueFromMetadataKeyForDateIncludeBodySectionsMatrix()\` failed to verify \`dateincludebodysectionsmatrixarray\` exists";

        return 1;
    }

    local gvfmkffmm_parameter_1="$1"
    local gvfmkffmm_parameter_2="$2"

    local gvfmkffmm_indexTemp
    local gvfmkffmm_metadataValueTemp

    gvfmkffmm_indexTemp=-1

    for gvfmkffmm_metadataKeyIndexTemp in "${!dateincludebodysectionsmatrixarray[@]}"; do
        if [[ "${dateincludebodysectionsmatrixarray[$gvfmkffmm_metadataKeyIndexTemp]}" == "$gvfmkffmm_parameter_2" ]]; then
            gvfmkffmm_indexTemp="$gvfmkffmm_metadataKeyIndexTemp"

            break
        fi
    done

    if (( gvfmkffmm_indexTemp == -1 )); then
        outputToLogFile "ERROR: \`getValueFromMetadataKeyForDateIncludeBodySectionsMatrix()\` failed to find \`$gvfmkffmm_parameter_1\` metadata key in \`dateincludebodysectionsmatrixarray\`";

        return 1;
    fi

    gvfmkffmm_metadataValueTemp=$(decodeFileIncludeBodyMatrix "$gvfmkffmm_parameter_1" "$gvfmkffmm_indexTemp") || {
        outputToLogFile "ERROR: \`getValueFromMetadataKeyForDateIncludeBodySectionsMatrix()\` failed to decode \`$gvfmkffmm_parameter_1\` metadata key value from \`$gvfmkffmm_parameter_1\` fileMetadataValueMatrix value";

        return 1
    }

    printf "%s" "$gvfmkffmm_metadataValueTemp"

    return 0
}

getSafeNameForArray() {
    # string array name gsnfa_parameter_1

    outputFunctionToLogFile "getSafeNameForArray" "$1"

    requireParameterForFunction "getSafeNameForArray" "array name" "$1" || {
         outputToLogFile "ERROR: \`getSafeNameForArray()\` array name not provided";

        return 1;
    }

    local gsnfa_parameter_1="$1"

    local gsnfa_arrayNameSafe=""

    {
        gsnfa_arrayNameSafe=$(normalizeString "$gsnfa_parameter_1");
    } || {
        outputToLogFile "ERROR: \`getSafeNameForArray()\` failed to normalize \`$gsnfa_parameter_1\` input";

        gsnfa_arrayNameSafe="$gsnfa_parameter_1";
    }

    [[ -z "$gsnfa_arrayNameSafe" ]] && {
        gsnfa_arrayNameSafe="$gsnfa_parameter_1";
    }

    [[ "$gsnfa_arrayNameSafe" =~ ^[0-9] ]] && {
        gsnfa_arrayNameSafe="x_$gsnfa_arrayNameSafe";
    }

    [[ "$gsnfa_arrayNameSafe" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || {
        outputToLogFile "ERROR: \`getSafeNameForArray()\` failed to produce a valid variable name from \`$gsnfa_parameter_1\` input";

        return 1;
    }

    printf "%s" "$gsnfa_arrayNameSafe"

    return 0
}

# display utility

showProgress() {
    # ----

    outputFunctionToLogFile "showProgress"

    local sp_progressTemp

    outputToLogFile "\`> $ sp_progressTemp=\"${progressArray[0]}\"\`"

    sp_progressTemp="${progressArray[0]}"

    printf "%s" "$sp_progressTemp"

    return 0
}

trimPathForDisplay() {
    # string path tpfd_parameter_1

    outputFunctionToLogFile "trimPathForDisplay" "$1"

    requireParameterForFunction "trimPathForDisplay" "path" "$1" || return 1
    
    local tpfd_parameter_1="$1"

    local tpfd_shortPath

    {
        tpfd_shortPath=$(printf "%s\n" "$tpfd_parameter_1" | cut -b $((${#userProfile}+1))-)
    } || {
        outputToLogFile "ERROR: \`trimPathForDisplay()\` failed to trim \`$tpfd_parameter_1\` path for display"

        return 1
    }

    printf "%s%s" "~" "$tpfd_shortPath"

    return 0
}

# verify

verifyArrayExists() {
    # string source-array-name vae_parameter_1

    outputFunctionToLogFile "verifyArrayExists" "$1"

    requireParameterForFunction "verifyArrayExists" "source-array-name" "$1" || return 1

    local vae_parameter_1="$1"

    if ! declare -p "$vae_parameter_1" 2>/dev/null | grep -q 'declare \-[aA]'; then
        outputToLogFile "ERROR: \`verifyArrayExists()\` failed to find \`$vae_parameter_1\` array or it is not an array"
        return 1
    fi

    return 0
}

verifyFileExists() {
    # string file vfe_parameter_1

    outputFunctionToLogFile "verifyFileExists" "$1"

    requireParameterForFunction "verifyFileExists" "file" "$1" || return 1

    [[ -f "$1" ]] || {
        local vfe_parameter_1="$1"

        outputToLogFile "ERROR: \`verifyFileExists()\` failed to find \`$vfe_parameter_1\` file"

        return 1
    }

    return 0
}

verifyDirectoryExists() {
    # string directory vde_parameter_1

    outputFunctionToLogFile "verifyDirectoryExists" "$1"

    requireParameterForFunction "verifyDirectoryExists" "directory" "$1" || return 1

    [[ -d "$1" ]] || {
        local vde_parameter_1="$1"

        outputToLogFile "ERROR: \`verifyDirectoryExists()\` failed to find \`$vde_parameter_1\` directory"

        return 1
    }

    return 0
}

# require

requireParameterForFunction() {
    # Usage:
    #  requireParameterForFunction function_name parameter_name parameter_value
    #
    # string name of function rpff_parameter_1
    # string name of parameter rpff_parameter_2
    # string value of parameter rpff_paramter_3

    local rpff_parameter_1="$1"
    local rpff_parameter_2="$2"

    [[ -n "$rpff_parameter_1" ]] || {
        outputToLogFile "ERROR: \`requireParameterForFunction()\` name of function not provided"

        return 1
    }

    [[ -n "$rpff_parameter_2" ]] || {
        outputToLogFile "ERROR: \`requireParameterForFunction()\` name of parameter not provided to \`$rpff_parameter_1\` function"

        return 1
    }

    shift 2

    local rpff_parameter_3="$*"

    [[ -n "$rpff_parameter_3" ]] || {
        outputToLogFile "ERROR: \`requireParameterForFunction()\` value of parameter not provided for \`$rpff_parameter_2\` parameter to \`$rpff_parameter_1\` function"

        return 1
    }

    return 0
}

requireFileExists() {
    # string function rfe_parameter_1
    # string name of parameter rfe_parameter_2
    # string file rfe_parameter_3

    outputFunctionToLogFile "requireFileExists" "$1" "$2" "$3"

    requireParameterForFunction "requireFileExists" "function" "$1" || return 1
    requireParameterForFunction "requireFileExists" "name of parameter" "$2" || return 1
    requireParameterForFunction "requireFileExists" "file" "$3" || return 1

    local rfe_parameter_1="$1"
    local rfe_parameter_2="$2"
    local rfe_parameter_3="$3"

    requireParameterForFunction "$rfe_parameter_1" "$rfe_parameter_2" "$rfe_parameter_3" || return 1

    verifyFileExists "$rfe_parameter_3" || return 1

    return 0
}

requireDirectoryExists() {
    # string function rde_parameter_1
    # string name of parameter rde_parameter_2
    # string directory rde_parameter_3

    outputFunctionToLogFile "requireDirectoryExists" "$1" "$2" "$3"

    requireParameterForFunction "requireDirectoryExists" "function" "$1" || return 1
    requireParameterForFunction "requireDirectoryExists" "name of parameter" "$2" || return 1
    requireParameterForFunction "requireDirectoryExists" "directory" "$3" || return 1

    local rde_parameter_1="$1"
    local rde_parameter_2="$2"
    local rde_parameter_3="$3"

    requireParameterForFunction "$rde_parameter_1" "$rde_parameter_2" "$rde_parameter_3" || return 1

    verifyDirectoryExists "$rde_parameter_3" || return 1

    return 0
}

requireArrayExists() {
    # string function rae_parameter_1
    # string name of parameter rae_parameter_2
    # string name of array rae_parameter_3

    outputFunctionToLogFile "requireArrayExists" "$1" "$2" "$3"

    requireParameterForFunction "requireArrayExists" "function" "$1" || return 1
    requireParameterForFunction "requireArrayExists" "name of parameter" "$2" || return 1
    requireParameterForFunction "requireArrayExists" "name of array" "$3" || return 1

    local rae_parameter_1="$1"
    local rae_parameter_2="$2"
    local rae_parameter_3="$3"

    verifyArrayExists "$rae_parameter_3" || {
        outputToLogFile "ERROR: \`requireArrayExists()\` \`$rae_parameter_1\` failed to verify \`$rae_parameter_3\` array exists"
        return 1
    }

    return 0
}

# process

decodeFileMetadataMatrix() {
    # string fileMetadataMatrix dmvm_parameter_1
    # integer index dmvm_parameter_2

    outputFunctionToLogFile "decodeFileMetadataMatrix" "$1"

    requireParameterForFunction "decodeFileMetadataMatrix" "fileMetadataMatrix value" "$1" || return 1
    requireParameterForFunction "decodeFileMetadataMatrix" "index" "$2" || return 1

    local dmvm_parameter_1="$1"
    local dmvm_parameter_2="$2"

    local dmvm_valueTemp

    declare -a dmvm_arrayTemp

    # fileMetadataMatrix=( "filePath" "recommendationMetadataState" \
    #                      "recommendationSubCategory" "retirementDate" \
    #                      "service" "serviceTreeId" "retirementFeatureName" \
    #                      "impactedSourceValue" )

    IFS='|' read -r -a dmvm_arrayTemp <<< "$dmvm_parameter_1"

    if [[ $? -ne 0 ]]; then
        outputToLogFile "ERROR: \`decodeFileMetadataMatrix()\` failed to parse \`$dmvm_parameter_1\` fileMetadataMatrix value"

        return 1
    fi

    if (( dmvm_parameter_2 < 0 || dmvm_parameter_2 >= ${#dmvm_arrayTemp[@]} )); then
        outputToLogFile "ERROR: \`decodeFileMetadataMatrix()\` index \`$dmvm_parameter_2\` out of bounds for \`$dmvm_parameter_1\`"

        return 1
    fi

    dmvm_valueTemp="${dmvm_arrayTemp[$dmvm_parameter_2]}"

    printf "%s" "$dmvm_valueTemp"

    return 0
}

decodeFileIncludeBodyMatrix() {
    # string fileIncludeBodyMatrix dfibm_parameter_1
    # integer index dfibm_parameter_2

    outputFunctionToLogFile "decodeFileIncludeBodyMatrix" "$1"

    requireParameterForFunction "decodeFileIncludeBodyMatrix" "fileIncludeBodyMatrix value" "$1" || return 1
    requireParameterForFunction "decodeFileIncludeBodyMatrix" "index" "$2" || return 1

    local dfibm_parameter_1="$1"
    local dfibm_parameter_2="$2"

    local dfibm_valueTemp

    declare -a dfibm_arrayTemp

    # dateIncludeBodySectionsMatrix=( "retirementDate" "BodySectionMatrix")

    IFS='_' read -r -a dfibm_arrayTemp <<< "$dfibm_parameter_1"

    if [[ $? -ne 0 ]]; then
        outputToLogFile "ERROR: \`decodeFileIncludeBodyMatrix()\` failed to parse \`$dfibm_parameter_1\` fileMetadataMatrix value"

        return 1
    fi

    if (( dfibm_parameter_2 < 0 || dfibm_parameter_2 >= ${#dfibm_arrayTemp[@]} )); then
        outputToLogFile "ERROR: \`decodeFileIncludeBodyMatrix()\` index \`$dfibm_parameter_2\` out of bounds for \`$dfibm_parameter_1\`"

        return 1
    fi

    dfibm_valueTemp="${dfibm_arrayTemp[$dfibm_parameter_2]}"

    printf "%s" "$dfibm_valueTemp"

    return 0
}

validateJsonValue() {
    # string json value vjv_parameter_1

    outputFunctionToLogFile "validateJsonValue" "[***]"

    requireParameterForFunction "validateJsonValue" "JSON value" "[***]" || return 1

    local vjv_parameter_1="$1"

    {
        if printf "%s" "$vjv_parameter_1" | grep -E '^\s*\{.*\}\s*$'; then
            [[ $(printf "%s" "$vjv_parameter_1" | tr -cd '"' | wc -c) -eq 0 ]] || [[ $(( $(printf "%s" "$vjv_parameter_1" | tr -cd '"' | wc -c) % 2 )) -eq 0 ]]
        fi;
    } || {
        outputToLogFile "ERROR: \`validateJsonValue()\` failed to validate \`[***]\` JSON value";

        return 1;
    }

    return 0
}

getValueForKeyInJson() {
    # string json value gvfkij_parameter_1
    # string metadata key gvfkij_parameter_2

    outputFunctionToLogFile "getValueForKeyInJson" "[***]" "$2"

    requireParameterForFunction "getValueForKeyInJson" "JSON value" "[***]" || return 1
    requireParameterForFunction "getValueForKeyInJson" "metadata key" "$2" || return 1

    local gvfkij_parameter_1="$1"
    local gvfkij_parameter_2="$2"

    local gvfkij_metadataValueTemp
    local gvfkij_metadataValueCleanTemp
    local gvfkij_stage1
    local gvfkij_stage2

    validateJsonValue "$gvfkij_parameter_1" || {
        outputToLogFile "ERROR: \`getValueForKeyInJson()\` \`[***]\` failed to validate JSON value";

        return 1;
    }

    {
        gvfkij_metadataValueTemp=$(
            gvfkij_stage1=$(printf "%s" "$gvfkij_parameter_1" | grep -o "\"$gvfkij_parameter_2\"[[:space:]]*:[[:space:]]*\"[^\"]*\"")
            gvfkij_stage2=$(printf "%s" "$gvfkij_stage1" | sed -n -E "s/.*\"$gvfkij_parameter_2\"[[:space:]]*:[[:space:]]*\"([^\"]*)\".*/\1/p")
            printf "%s" "$gvfkij_stage2"
        );
    } || {
        outputToLogFile "ERROR: \`getValueForKeyInJson()\` failed to parse \`$gvfkij_parameter_2\` metadata value from \`[***]\` JSON value";

        return 1;
    }

    [[ -n "$gvfkij_metadataValueTemp" ]] || {
        outputToLogFile "ERROR: \`getValueForKeyInJson()\` \`[***]\` failed to find \`$gvfkij_parameter_2\` metadata key in JSON value";

        return 1;
    }

    {
        gvfkij_metadataValueCleanTemp=$(printf "%s" "$gvfkij_metadataValueTemp" | sed -E "s/^[[:space:]]+//; s/[[:space:]]+$//");
    } || {
        outputToLogFile "ERROR: \`getValueForKeyInJson()\` failed to clean \`$gvfkij_metadataValueTemp\` metadata value from \`[***]\` JSON value";

        return 1;
    }

    printf "%s" "$gvfkij_metadataValueCleanTemp"

    return 0
}

getMetadataValueMatrixInJson() {
    # decode key is recommendationMetadataState|recommendationSubCategory|
    #               retirementDate|service|serviceTreeId|
    #               retirementFeatureName|impactedSourceValue|
    # string json value gmvmij_parameter_1

    outputFunctionToLogFile "getMetadataValueMatrixInJson" "[***]"

    requireParameterForFunction "getMetadataValueMatrixInJson" "JSON value" "[***]" || return 1

    verifyArrayExists "metadataarray" || {
        outputToLogFile "ERROR: \`getMetadataValueMatrixInJson()\` failed to verify \`metadataarray\` exists";

        return 1;
    }

    local gmvmij_parameter_1="$1"

    local gmvmij_dataSourceValue
    local gmvmij_impactedSourceValue
    local gmvmij_requiredValuesMatrixTemp

    gmvmij_requiredValuesMatrixTemp=""

    for gmvmij_metadataKey in "${metadataarray[@]}"; do
        local gmvmij_metadataValue

        gmvmij_metadataValue=$(getValueForKeyInJson "$gmvmij_parameter_1" "$gmvmij_metadataKey")

        if [[ $? -ne 0 || -z "$gmvmij_metadataValue" || "$gmvmij_metadataValue" == "nomatch" ]]; then
            gmvmij_metadataValue="MISSING"
        fi

        if [[ "$gmvmij_metadataKey" == "recommendationMetadataState" ]]; then
            [[ "$(toLowerString "$gmvmij_metadataValue")" == "active" ]] || {
                outputToLogFile "ERROR: \`getMetadataValueMatrixInJson()\` skipping recommendation with \`$gmvmij_metadataKey\` metadata value of \`$gmvmij_metadataValue\`";

                return 1;
            }
        fi

        if [[ "$gmvmij_metadataKey" =~ ^(recommendationSubCategory|retirementDate|service|serviceTreeId|retirementFeatureName)$ ]]; then
            [[ -n "$gmvmij_metadataValue" && "$gmvmij_metadataValue" != "MISSING" ]] || {
                outputToLogFile "ERROR: \`getMetadataValueMatrixInJson()\` skipping recommendation with missing \`$gmvmij_metadataKey\` metadata value";

                return 1;
            }
        fi

        {
            gmvmij_requiredValuesMatrixTemp="${gmvmij_requiredValuesMatrixTemp}${gmvmij_metadataValue}|"
        } || {
            outputToLogFile "ERROR: \`getMetadataValueMatrixInJson()\` failed to add \`$gmvmij_metadataValue\` metadata value to metadataValueMatrix from \`[***]\` JSON value"

            return 1;
        }
    done

    gmvmij_impactedSourceValue="No"

    if gmvmij_dataSourceValue=$(getValueForKeyInJson "$gmvmij_parameter_1" "dataSource"); then
        if [[ "$gmvmij_dataSourceValue" =~ ^(ARG|Cosmos|Kusto|SAS)$ ]]; then
            gmvmij_impactedSourceValue="Yes"
        fi
    fi

    {
        gmvmij_requiredValuesMatrixTemp="${gmvmij_requiredValuesMatrixTemp}${gmvmij_impactedSourceValue}|"
    } || {
        outputToLogFile "ERROR: \`getMetadataValueMatrixInJson()\` failed to add \`$gmvmij_dataSourceValue\` dataSource value to metadataValueMatrix from \`[***]\` JSON value"

        return 1;
    }

    printf "%s" "$gmvmij_requiredValuesMatrixTemp"

    return 0
}

getFileMetadataValueMatrix() {
    # decode key is filePath|recommendationMetadataState|
    #               recommendationSubCategory|retirementDate|service|
    #               serviceTreeId|retirementFeatureName|impactedSourceValue|
    # string file gfmvm_parameter_1

    outputFunctionToLogFile "getFileMetadataValueMatrix" "$1"

    requireFileExists "getFileMetadataValueMatrix" "file" "$1" || return 1

    local gfmvm_parameter_1="$1"

    local gfmvm_fileMetadataValueMatrixTemp
    local gfmvm_metadataValueMatrixTemp
    local gfmvm_jsonInput

    {
        gfmvm_jsonInput=$(<"$gfmvm_parameter_1");
    } || {
        outputToLogFile "ERROR: \`getFileMetadataValueMatrix()\` failed to read \`$gfmvm_parameter_1\` file";

        return 1;
    }

    if [[ "$gfmvm_parameter_1" == *"|"* ]]; then
        outputToLogFile "ERROR: \`getFileMetadataValueMatrix()\` \`$gfmvm_parameter_1\` file path contains a pipe character";

        return 1;
    fi

    {
        gfmvm_metadataValueMatrixTemp=$(getMetadataValueMatrixInJson "$gfmvm_jsonInput");
    } || {
        outputToLogFile "ERROR: \`getFileMetadataValueMatrix()\` failed to create metadataValueMatrix from \`$gfmvm_parameter_1\` file";

        return 1;
    }

    if [[ -z "$gfmvm_metadataValueMatrixTemp" || "$gfmvm_metadataValueMatrixTemp" == "nomatch" ]]; then
        outputToLogFile "ERROR: \`getFileMetadataValueMatrix()\` metadataValueMatrix is empty or invalid for \`$gfmvm_parameter_1\` file";

        return 1;
    fi

    outputToLogFile "getFileMetadataValueMatrix() \`$gfmvm_parameter_1\` file has \`$gfmvm_metadataValueMatrixTemp\` metadataValueMatrix value"; # debug

    {
        gfmvm_fileMetadataValueMatrixTemp=$(printf "%s|%s" "$gfmvm_parameter_1" "$gfmvm_metadataValueMatrixTemp");
    } || {
        outputToLogFile "ERROR: \`getFileMetadataValueMatrix()\` failed to create fileMetadataMatrix from \`$gfmvm_parameter_1\` file";

        return 1;
    }

    outputToLogFile "getFileMetadataValueMatrix() \`$gfmvm_parameter_1\` file has \`$gfmvm_fileMetadataValueMatrixTemp\` fileMetadataValueMatrix value"; # debug

    printf "%s" "$gfmvm_fileMetadataValueMatrixTemp"

    return 0
}

# file system filter

checkPublicNameMarkdownFile() {
    # string file cpnmf_parameter_1

    outputFunctionToLogFile "checkPublicNameMarkdownFile" "$1"

    requireFileExists "checkPublicNameMarkdownFile" "file" "$1" || return 1

    local cpnmf_parameter_1="$1"

    local cpnmf_fileShortNameTemp
    local cpnmf_fileSuffixTemp
    local cpnmf_foundCount

    cpnmf_fileShortNameTemp=$(getShortNameForFile "$cpnmf_parameter_1") || {
        outputToLogFile "ERROR: \`checkPublicNameMarkdownFile()\` failed to get short name for \`$cpnmf_parameter_1\` file";
        return 1;
    }

    cpnmf_fileSuffixTemp="${cpnmf_fileShortNameTemp##*[-_]}"

    local cpnmf_fileSuffixLower
    cpnmf_fileSuffixLower=$(toLowerString "$cpnmf_fileSuffixTemp")

    cpnmf_foundCount=0

    for cpnmf_cloudTemp in "${cloudarray[@]}"; do
        showProgress

        [[ "$cpnmf_cloudTemp" == "public" ]] && continue

        if [[ "$cpnmf_fileSuffixLower" == "$cpnmf_cloudTemp" ]]; then
            cpnmf_foundCount=1
            break
        fi
    done

    if (( cpnmf_foundCount == 0 )) || [[ "$cpnmf_fileSuffixLower" == "public" ]]; then
        outputToLogFile "\`checkPublicNameMarkdownFile\` \`$cpnmf_fileShortNameTemp\` ends with public or not a listed cloud suffix"
        return 0
    else
        outputToLogFile "ERROR: \`checkPublicNameMarkdownFile\` \`$cpnmf_fileShortNameTemp\` ends with a non-public \`$cpnmf_fileSuffixTemp\` cloud suffix"
        return 1
    fi
}

verifyRequiredMetadataKeysExist() {
    # string file vrmke_parameter_1

    outputFunctionToLogFile "verifyRequiredMetadataKeysExist" "$1"

    requireFileExists "verifyRequiredMetadataKeysExist" "file" "$1" || return 1

    local vrmke_parameter_1="$1"

    local vrmke_jsonInput

    {
        vrmke_jsonInput=$(<"$vrmke_parameter_1");
    } || {
        outputToLogFile "ERROR: \`verifyRequiredMetadataKeysExist()\` failed to read \`$vrmke_parameter_1\` file";
        return 1;
    }

    for vrmke_metadataKey in "${metadataarray[@]}"; do
        showProgress

        local vrmke_metadataValue

        vrmke_metadataValue=$(getValueForKeyInJson "$vrmke_jsonInput" "$vrmke_metadataKey")

        if [[ $? -ne 0 || -z "$vrmke_metadataValue" || "$vrmke_metadataValue" == "nomatch" ]]; then
            outputToLogFile "ERROR: \`verifyRequiredMetadataKeysExist()\` failed to find \`$vrmke_metadataKey\` metadata key in \`$vrmke_parameter_1\` file";
            return 1;
        fi

        if [[ "$vrmke_metadataKey" =~ ^(recommendationSubCategory|retirementDate|service|serviceTreeId|retirementFeatureName)$ ]]; then
            [[ -n "$vrmke_metadataValue" && "$vrmke_metadataValue" != "MISSING" ]] || {
                outputToLogFile "ERROR: \`verifyRequiredMetadataKeysExist()\` skipping recommendation with missing \`$vrmke_metadataKey\` metadata value in \`$vrmke_parameter_1\` file";
                return 1;
            }
        fi
    done

    return 0
}

# file system

searchFile() {
    # string file sf_parameter_1

    outputFunctionToLogFile "searchFile" "$1"

    requireFileExists "searchFile" "file" "$1" || return 1

    local sf_parameter_1="$1"

    local sf_fileMetadataMatrix

    {
        checkPublicNameMarkdownFile "$sf_parameter_1";
    } || {
        outputToLogFile "ERROR: \`searchFile()\` failed to validate \`$sf_parameter_1\` file as a public cloud file";

        return 1;
    }

    {
        verifyRequiredMetadataKeysExist "$sf_parameter_1";
    } || {
        outputToLogFile "ERROR: \`searchFile()\` failed to verify required metadata keys exist in \`$sf_parameter_1\` file";

        return 1;
    }

    {
        sf_fileMetadataMatrix=$(getFileMetadataValueMatrix "$sf_parameter_1");
    } || {
        outputToLogFile "ERROR: \`searchFile()\` failed to get fileMetadataMatrix for \`$sf_parameter_1\` file";

        return 1;
    }

    [[ -n "$sf_fileMetadataMatrix" ]] || {
        outputToLogFile "ERROR: \`searchFile()\` \`$sf_parameter_1\` fileMetadataMatrix is empty";

        return 1;
    }

    {
        addValuesToMultipleArrays "$sf_fileMetadataMatrix";
    } || {
        outputToLogFile "ERROR: \`searchFile()\` failed to add values for \`$sf_parameter_1\` file";

        return 1;
    }

    return 0
}

searchDirectory() {
    # string directory sd_parameter_1

    outputFunctionToLogFile "searchDirectory" "$1"

    requireDirectoryExists "searchDirectory" "directory" "$1" || return 1

    local sd_parameter_1="$1"

    local sd_childTemp
    local sd_fileExtensionTemp
    # local sd_foundCount

    local -a sd_childrenArray=()

    # showProgress
    outputToConsole "searchDirectory() \`$sd_parameter_1\` is a directory"; # debug

    # sd_foundCount=0

    for sd_entry in "$sd_parameter_1"/*; do
        showProgress

        [[ -e "$sd_entry" ]] || continue

        sd_childrenArray+=( "$sd_entry" )
    done

    for sd_entry in "$sd_parameter_1"/.*; do
        showProgress

        [[ -e "$sd_entry" ]] || continue

        local sd_baseNameTemp

        sd_baseNameTemp=$(basename -- "$sd_entry")

        [[ "$sd_baseNameTemp" == "." || "$sd_baseNameTemp" == ".." ]] && continue

        sd_childrenArray+=( "$sd_entry" )
    done

    if (( ${#sd_childrenArray[@]} == 0 )); then
        outputToLogFile "ERROR: \`searchDirectory()\` \`$sd_parameter_1\` is empty or no matching files"
    else
        for sd_childTemp in "${sd_childrenArray[@]}"; do
            showProgress

            [[ -e "$sd_childTemp" ]] || continue

            # sd_foundCount=1

            if [[ -d "$sd_childTemp" ]]; then
                searchDirectory "$sd_childTemp" || {
                    outputToLogFile "ERROR: \`searchDirectory()\` failed to search \`$sd_childTemp\` directory";

                    continue;
                }
            elif [[ -f "$sd_childTemp" ]]; then
                sd_fileExtensionTemp=$(getFileExtensionForFile "$sd_childTemp") || {
                    outputToLogFile "ERROR: \`searchDirectory()\` failed to get file extension for \`$sd_childTemp\` file";

                    continue;
                }

                [[ "$sd_fileExtensionTemp" == "md" ]] || {
                    outputToLogFile "ERROR: \`searchDirectory()\` \`$sd_childTemp\` file extension is not \`.md\`";

                    continue;
                }

                searchFile "$sd_childTemp" || {
                    outputToLogFile "ERROR: \`searchDirectory()\` failed to search \`$sd_childTemp\` file";

                    continue;
                }
            else
                outputToLogFile "ERROR: \`searchDirectory()\` \`$sd_childTemp\` is not a valid directory or file";

                continue;
            fi
        done
    fi

    printf "\n"

    return 0
}

# search from file list

searchLinesFromListFile() {
    # string file slflf_parameter_1

    outputFunctionToLogFile "searchLinesFromListFile" "$1"

    requireFileExists "searchLinesFromListFile" "file" "$1" || return 1

    local slflf_parameter_1="$1"

    local slflf_searchLines

    {
        slflf_searchLines=$(< "$slflf_parameter_1");
    } || {
        outputToLogFile "ERROR: \`searchLinesFromListFile()\` failed to read content from \`$slflf_parameter_1\` file";

        return 1;
    }

    for slflf_searchLineTemp in $slflf_searchLines; do
        showProgress

        [[ -d "$slflf_searchLineTemp" ]] || {
            outputToLogFile "ERROR: \`searchLinesFromListFile()\` \`$slflf_searchLineTemp\` is not a valid directory";

            continue;
        }
        
        searchDirectory "$slflf_searchLineTemp" || {
            outputToLogFile "ERROR: \`main()\` failed to search \`$slflf_searchLineTemp\` directory";

            continue;
        }
    done

    return 0
}

searchDirectoryFromFile() {
    # ----

    outputFunctionToLogFile "searchDirectoryFromFile"

    # showProgress
    outputToConsole "\`searchDirectoryFromFile()\` Search list of directories from \`$inputDirectoryDirectoryOutputTxt\` file"

    verifyFileExists "$inputDirectoryDirectoryOutputTxt" || {
        outputToLogFile "ERROR: \`searchDirectoryFromFile()\` failed to find \`$inputDirectoryDirectoryOutputTxt\` file";

        return 1;
    }

    searchLinesFromListFile "$inputDirectoryDirectoryOutputTxt" || {
        outputToLogFile "ERROR: \`searchDirectoryFromFile()\` failed to search directories from \`$inputDirectoryDirectoryOutputTxt\` file";    

        return 1;
    }

    return 0
}

chooseSearch() {
    # ----

    outputFunctionToLogFile "chooseSearch"

    verifyDirectoryExists "$articlesSelfhelpcontentDirectory" || {
        outputToLogFile "ERROR: \`chooseSearch()\` failed to find \`$articlesSelfhelpcontentDirectory\` directory";

        return 1;
    }

    searchDirectoryFromFile || {
        searchDirectory "$articlesSelfhelpcontentDirectory" || {
            outputToLogFile "ERROR: \`chooseSearch()\` failed to search \`$articlesSelfhelpcontentDirectory\` directory";

            return 1;
        }
    }

    return 0
}

# configure array

setArrayByName() {
    # string name of array sabn_parameter_1

    outputFunctionToLogFile "setArrayByName" "$1"

    requireParameterForFunction "setArrayByName" "name of array" "$1" || return 1

    local sabn_parameter_1="$1"
    local sabn_safeArrayName

    sabn_safeArrayName="$(getSafeNameForArray "$sabn_parameter_1")" || {
        outputToLogFile "ERROR: \`setArrayByName()\` failed to get safe name for \`$sabn_parameter_1\`";
        return 1;
    }

    if ! declare -p "$sabn_safeArrayName" 2>/dev/null | grep -q 'declare \-[aA]'; then
        eval "declare -g -a $sabn_safeArrayName=()" || {
            outputToLogFile "ERROR: \`setArrayByName()\` failed to declare array \`$sabn_safeArrayName\`";
            return 1;
        }
    fi

    declare -n sabn_destinationArray="$sabn_safeArrayName" || {
        outputToLogFile "ERROR: \`setArrayByName()\` failed to reference array \`$sabn_safeArrayName\`";
        return 1;
    }

    sabn_destinationArray=()

    sabn_destinationArray+=( "${@:2}" )

    return 0
}

addValueToArray() {
    # string name of array avta_parameter_1
    # string value avta_parameter_2

    outputFunctionToLogFile "addValueToArray" "$1" "$2"

    requireParameterForFunction "addValueToArray" "name of array" "$1" || return 1
    requireParameterForFunction "addValueToArray" "input" "$2" || return 1

    local avta_parameter_1="$1"
    local avta_parameter_2="$2"

    local avta_safeArrayName

    avta_safeArrayName="$(getSafeNameForArray "$avta_parameter_1")" || {
        outputToLogFile "ERROR: \`addValueToArray()\` failed to get safe name for \`$avta_parameter_1\` input";

        avta_safeArrayName="$avta_parameter_1";
    }

    if ! declare -p "$avta_safeArrayName" 2>/dev/null | grep -q 'declare \-[aA]'; then
        eval "declare -g -a $avta_safeArrayName=()"
    fi

    local avta_currentvaluesarray

    if declare -p "$avta_safeArrayName" 2>/dev/null | grep -q 'declare \-[aA]'; then
        eval "avta_currentvaluesarray=(\"\${$avta_safeArrayName[@]}\")"
    else
        avta_currentvaluesarray=()
    fi

    avta_currentvaluesarray+=( "$avta_parameter_2" )

    mapfile -t avta_currentvaluesarray < <(printf "%s\n" "${avta_currentvaluesarray[@]}" | sed '/^$/d' | sort | uniq)

    setArrayByName "$avta_safeArrayName" "${avta_currentvaluesarray[@]}"

    return 0
}

addValuesToMultipleArrays() {
    # string fileMetadataMatrix value avtma_parameter_1

    outputFunctionToLogFile "addValuesToMultipleArrays" "$1"

    requireParameterForFunction "addValuesToMultipleArrays" "metadata matrix" "$1" || return 1

    local avtma_parameter_1="$1"

    local avtma_fileDirectoryPathTemp
    local avtma_filePathTemp

    # fileMetadataMatrix=( "filePath" "recommendationMetadataState" \
    #                      "recommendationSubCategory" "retirementDate" \
    #                      "service" "serviceTreeId" "retirementFeatureName" \
    #                      "impactedSourceValue" )

    avtma_filePathTemp=$(getValueFromMetadataKeyForFileMetadataMatrix "$avtma_parameter_1" "filePath") || {
        outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to decode \`filePath\` value from \`$avtma_parameter_1\` fileMetadataMatrix value";
        return 1;
    }

    verifyFileExists "$avtma_filePathTemp" || {
        outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to verify \`$avtma_filePathTemp\` file exists";
        return 1;
    }

    avtma_fileDirectoryPathTemp=$(getPathForFile "$avtma_filePathTemp") || {
        outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to get path for \`$avtma_parameter_1\` file";
        return 1;
    }

    verifyDirectoryExists "$avtma_fileDirectoryPathTemp" || {
        outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to verify \`$avtma_fileDirectoryPathTemp\` directory exists";
        return 1;
    }
    
    {
       avtma_retirementDateTemp=$(getValueFromMetadataKeyForFileMetadataMatrix "$avtma_parameter_1" "retirementDate");
    } || {
        outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to decode \`retirementDate\` value from \`$avtma_parameter_1\` fileMetadataMatrix value";
        return 1;
    }

    addValueToArray "directoryarray" "$avtma_fileDirectoryPathTemp" || {
        outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`$avtma_fileDirectoryPathTemp\` to \`directoryarray\` array";
        return 1;
    }

    addValueToArray "filemetadatamatrixarray" "$avtma_parameter_1" || {
        outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`$avtma_parameter_1\` to \`filemetadatamatrixarray\` array";
        return 1;
    }

    addValueToArray "retirementdatelistarray" "$avtma_retirementDateTemp" || {
        outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`$avtma_retirementDateTemp\` date value to \`retirementdatelistarray\` array";
        return 1;
    }

    addValueToArray "arraynamelistarray" "directoryarray" || {
        outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`directoryarray\` to \`arraynamelistarray\` array";
        return 1;
    }

    addValueToArray "arraynamelistarray" "filemetadatamatrixarray" || {
        outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`filemetadatamatrixarray\` to \`arraynamelistarray\` array";
        return 1;
    }

    addValueToArray "arraynamelistarray" "retirementdatelistarray" || {
        outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`retirementdatelistarray\` to \`arraynamelistarray\` array";
        return 1;
    }

    return 0
}

# retrieve array

getArrayByName() {
    # string name of array gabn_parameter_1

    requireArrayExists "getArrayByName" "name of array" "$1" || return 1

    local gabn_parameter_1="$1"

    [[ -n "$gabn_parameter_1" ]] || {
        outputToLogFile "ERROR: \`getArrayByName()\` name of array is empty";
        return 1;
    }

    if ! declare -p "$gabn_parameter_1" 2>/dev/null | grep -q 'declare \-[aA]'; then
        outputToLogFile "ERROR: \`getArrayByName()\` \`$gabn_parameter_1\` is not a valid array"
        return 1
    fi

    declare -n gabn_array="$gabn_parameter_1"

    for gabn_item in "${gabn_array[@]}"; do
        printf "%s\n" "$gabn_item"
    done

    return 0
}

setLocalArrayFromArrayName() {
    # string name of destination array slafn_parameter_1
    # string name of source array slafn_parameter_2

    outputFunctionToLogFile "setLocalArrayFromArrayName" "$1" "$2"

    requireParameterForFunction "setLocalArrayFromArrayName" "name of destination array" "$1" || return 1
    requireArrayExists "setLocalArrayFromArrayName" "name of source array" "$2" || return 1

    local slafn_parameter_1="$1"
    local slafn_parameter_2="$2"

    [[ -z "$slafn_parameter_1" ]] && {
        outputToLogFile "ERROR: \`setLocalArrayFromArrayName()\` name of destination array is empty";
        return 1;
    }

    if ! declare -p "$slafn_parameter_1" 2>/dev/null | grep -q 'declare \-[aA]'; then
        eval "declare -g -a $slafn_parameter_1=()"
    fi

    local -n destinationArrayReference="$slafn_parameter_1"

    mapfile -t destinationArrayReference < <(getArrayByName "$slafn_parameter_2") || {
        outputToLogFile "ERROR: \`setLocalArrayFromArrayName()\` failed to set \`$slafn_parameter_1\` array from \`$slafn_parameter_2\` array";
        return 1;
    }

    return 0
}

setLocalArrayFromFunction() {
    # string name of array slaff_parameter_1
    # string functionslaff_parameter_2

    outputFunctionToLogFile "setLocalArrayFromFunction" "$1" "$2"

    requireParameterForFunction "setLocalArrayFromFunction" "name of destination array" "$1" || return 1
    requireParameterForFunction "setLocalArrayFromFunction" "function" "$2" || return 1

    local slaff_parameter_1="$1"
    local slaff_parameter_2="$2"

    local -n destinationArrayReference="$slaff_parameter_1"

    mapfile -t destinationArrayReference < <($slaff_parameter_2) || {
        outputToLogFile "ERROR: \`setLocalArrayFromFunction()\` failed to set \`$slaff_parameter_1\` array from function";

        return 1;
    }

    return 0
}

loopAllActiveArrays() {
    # ----

    outputFunctionToLogFile "loopAllActiveArrays"

    requireArrayExists "loopAllActiveArrays" "name of array" "arraynamelistarray" || return 1

    outputToConsole "\`loopAllActiveArrays()\` Loop through all active arrays"

    local -a laaa_arrayNameListArray=()

    setLocalArrayFromArrayName "laaa_arrayNameListArray" "arraynamelistarray" || {
        outputToLogFile "ERROR: \`loopAllActiveArrays()\` failed to set \`laaa_arrayNameListArray\` from \`arraynamelistarray\`";
        return 1;
    }

    outputToRawNamedFile "final.arraynamelistarray" "txt" "$(printf "%s\n" "${laaa_arrayNameListArray[@]}")" || {
        outputToLogFile "ERROR: \`loopAllActiveArrays()\` failed to create \`final.arraynamelistarray.txt\`";
        return 1;
    }

    for laaa_arrayNameTemp in "${laaa_arrayNameListArray[@]}"; do
        showProgress
        # outputToConsole "loopAllActiveArrays() entry \`$laaa_arrayNameTemp\` array name from \`arraynamelistarray\`" # debug

        local -a laaa_arrayItemsArray=()

        setLocalArrayFromArrayName "laaa_arrayItemsArray" "$laaa_arrayNameTemp" || {
            outputToLogFile "ERROR: \`loopAllActiveArrays()\` failed to set \`laaa_arrayItemsArray\` from \`$laaa_arrayNameTemp\`";
            return 1;
        }

        outputToRawNamedFile "final.$laaa_arrayNameTemp" "txt" "$(printf "%s\n" "${laaa_arrayItemsArray[@]}")" || {
            outputToLogFile "ERROR: \`loopAllActiveArrays()\` failed to create \`final.$laaa_arrayNameTemp.txt\`";
            return 1;
        }
    done

    return 0
}

#create body sections and items

createBodyItem() {
    # string fileMetadataValueMatrix value cbi_parameter_9

    outputToLogFile "\`createBodyItem() \"$1\"\`"

    requireParameterForFunction "createBodyItem" "fileMetadataValueMatrix value" "$1" || return 1

    local cbi_parameter_1="$1"

    local cbi_availableResourcesTemp
    local cbi_bodyItemTemp
    local cbi_impactedResourcesAvailableTemp
    local cbi_normalizeImpactedResourcesAvailableTemp
    local cbi_retirementFeatureNameTemp
    local cbi_serviceTemp

    # fileMetadataMatrix=( "filePath" "recommendationMetadataState" \
    #                      "recommendationSubCategory" "retirementDate" \
    #                      "service" "serviceTreeId" "retirementFeatureName" \
    #                      "impactedSourceValue" )

    cbi_serviceTemp=$(getValueFromMetadataKeyForFileMetadataMatrix "$cbi_parameter_1" "service")
    cbi_retirementFeatureNameTemp=$(getValueFromMetadataKeyForFileMetadataMatrix "$cbi_parameter_1" "retirementFeatureName")
    cbi_impactedResourcesAvailableTemp=$(getValueFromMetadataKeyForFileMetadataMatrix "$cbi_parameter_1" "impactedResourcesAvailable")

    cbi_normalizeImpactedResourcesAvailableTemp=$(normalizeString "$cbi_impactedResourcesAvailableTemp")

    if [[ "$cbi_normalizeImpactedResourcesAvailableTemp" == "yes" ]]; then
        cbi_availableResourcesTemp="[!INCLUDE [Available](../../includes/inline-reusable-text/available-option.md)]"
    elif [[ "$cbi_normalizeImpactedResourcesAvailableTemp" == "no" ]]; then
        cbi_availableResourcesTemp="[!INCLUDE [Not available](../../includes/inline-reusable-text/not-available-option.md)]"
    fi

    {
        cbi_bodyItemTemp=$(
            printf "| %s | %s | %s |" "$cbi_serviceTemp" "$cbi_retirementFeatureNameTemp" "$cbi_availableResourcesTemp"
        );
    } || {
        outputToLogFile "ERROR: \`createBodyItem()\` failed to create body item value from \`$cbi_parameter_1\` fileMetadataMatrix value";

        return 1;
    }

    printf "%s" "$cbi_bodyItemTemp" || {
        outputToLogFile "ERROR: \`createBodyItem()\` failed to create body item value";

        return 1;
    }

    return 0
}

createBodySection() {
    # string date cbs_parameter_1

    outputFunctionToLogFile "createBodySection" "$1"

    requireParameterForFunction "createBodySection" "date value" "$1" || return 1

    local cbs_parameter_1="$1"

    local cbs_dateHeadingTemp
    local cbs_dateTableHeaderTemp
    local cbs_sectionHeadingTemp
    local cbs_sectionTemp
    local cbs_sectionValueTemp

    declare -a cbs_fileMetadataMatrixArray=()

    {
        cbs_dateHeadingTemp=$(getStringFromDate "$cbs_parameter_1");
    } || {
        outputToLogFile "ERROR: \`createBodySection()\` failed to create heading from \`$cbs_parameter_1\` date";

        return 1;
    }

    {
        cbs_dateTableHeaderTemp=$(printf "%s\n" "${sectiontablearray[*]}");
    } || {
        outputToLogFile "ERROR: \`createBodySection()\` failed to create table header from \`sectiontablearray\` array";

        return 1;
    }

    {
        cbs_sectionHeadingTemp=$(
            printf "%s %s\n" "${headingarray[4]}" "$cbs_dateHeadingTemp"
            printf "\n"
            printf "%s" "$cbs_dateTableHeaderTemp"
        );
    } || {
        outputToLogFile "ERROR: \`createBodySection()\` failed to create section heading from \`$cbs_parameter_1\` date";

        return 1;
    }

    cbs_sectionTemp=""

    setLocalArrayFromArrayName "cbs_fileMetadataMatrixArray" "filemetadatamatrixarray" || {
        outputToLogFile "ERROR: \`createBodySection()\` failed to set \`cbs_fileMetadataMatrixArray\` from \`filemetadatamatrixarray\` array";

        return 1;
    }

    for cbs_fileMetadataMatrixTemp in "${cbs_fileMetadataMatrixArray[@]}"; do
        local cbs_retirementDateTemp
        local cbs_recommendationSubCategoryTemp
        local cbs_recommendationMetadataStateTemp
        local cbs_sectionItemTemp

        {
            cbs_retirementDateTemp=$(getValueFromMetadataKeyForFileMetadataMatrix "$cbs_fileMetadataMatrixTemp" "retirementDate");
        } || {
            outputToLogFile "ERROR: \`createBodySection()\` failed to decode \`retirementDate\` from \`$cbs_fileMetadataMatrixTemp\`";

            continue;
        }

        [[ "$cbs_retirementDateTemp" == "$cbs_parameter_1" ]] || continue

        {
            cbs_recommendationSubCategoryTemp=$(getValueFromMetadataKeyForFileMetadataMatrix "$cbs_fileMetadataMatrixTemp" "recommendationSubCategory");
        } || {
            outputToLogFile "ERROR: \`createBodySection()\` failed to decode \`recommendationSubCategory\` from \`$cbs_fileMetadataMatrixTemp\`";

            continue;
        }

        [[ "$cbs_recommendationSubCategoryTemp" == "ServiceUpgradeAndRetirement" ]] || {
            outputToLogFile "\`createBodySection()\` skipping \`$cbs_parameter_1\` date with \`$cbs_recommendationSubCategoryTemp\` recommendationSubCategory";

            continue;
        }

        {
            cbs_recommendationMetadataStateTemp=$(getValueFromMetadataKeyForFileMetadataMatrix "$cbs_fileMetadataMatrixTemp" "recommendationMetadataState");
        } || {
            outputToLogFile "ERROR: \`createBodySection()\` failed to decode \`recommendationMetadataState\` from \`$cbs_fileMetadataMatrixTemp\`";

            continue;
        }

        [[ "$cbs_recommendationMetadataStateTemp" == "Active" ]] || {
            outputToLogFile "\`createBodySection()\` skipping \`$cbs_parameter_1\` date with \`$cbs_recommendationMetadataStateTemp\` state";

            continue;
        }

        {
            cbs_sectionItemTemp=$(createBodyItem "$cbs_fileMetadataMatrixTemp");
        } || {
            outputToLogFile "ERROR: \`createBodySection()\` failed to create item for \`$cbs_parameter_1\` date";

            continue;
        }

        if [[ -n "$cbs_sectionTemp" ]]; then
            cbs_sectionTemp=$(printf "%s\n%s" "$cbs_sectionTemp" "$cbs_sectionItemTemp")
        else
            cbs_sectionTemp="$cbs_sectionItemTemp"
        fi
    done

    [[ -n "$cbs_sectionTemp" ]] || {
        outputToLogFile "ERROR: \`createBodySection()\` no active recommendations found for \`$cbs_parameter_1\` date"

        return 1
    }

    cbs_sectionValueTemp=$(printf "%s\n%s" "$cbs_sectionHeadingTemp" "$cbs_sectionTemp") || return 1

    printf "%s" "$cbs_sectionValueTemp"

    return 0
}

createIncludeBodySectionsFromActiveArrays() {
    # ----

    outputFunctionToLogFile "createIncludeBodySectionsFromActiveArrays"

    requireArrayExists "createIncludeBodySectionsFromActiveArrays" "name of array" "retirementdatelistarray" || return 1

    outputToConsole "\`createIncludeBodySectionsFromActiveArrays()\` Create body sections from active arrays"

    local cibsfaa_bodySectionTemp
    local cibsfaa_dateIncludeBodySectionsMatrixTemp

    local -a cibsfaa_retirementdatelistarray=()

    setLocalArrayFromArrayName "cibsfaa_retirementdatelistarray" "retirementdatelistarray" || {
        outputToLogFile "ERROR: \`createIncludeBodySectionsFromActiveArrays()\` failed to set \`cibsfaa_retirementdatelistarray\` from \`retirementdatelistarray\` array";
        return 1;
    }

    for cibsfaa_dateTemp in "${cibsfaa_retirementdatelistarray[@]}"; do
        # showProgress
        outputToConsole "createIncludeBodySectionsFromActiveArrays() entry \`$cibsfaa_dateTemp\` date from \`retirementdatelistarray\` array" # debug

        cibsfaa_bodySectionTemp=$(createBodySection "$cibsfaa_dateTemp") || {
            outputToLogFile "ERROR: \`createIncludeBodySectionsFromActiveArrays()\` failed to create body section for \`$cibsfaa_dateTemp\` date";
            continue;
        }

        cibsfaa_dateIncludeBodySectionsMatrixTemp=$(printf "%s_%s_" "$cibsfaa_dateTemp" "$cibsfaa_bodySectionTemp")

        addValueToArray "dateincludebodysectionsarray" "$cibsfaa_dateIncludeBodySectionsMatrixTemp" || {
            outputToLogFile "ERROR: \`createIncludeBodySectionsFromActiveArrays()\` failed to add body section for \`$cibsfaa_dateTemp\` date to \`dateincludebodysectionsarray\` array";
            continue;
        }
    done

    return 0
}

# create include files

createHeader() {
    # ----

    outputToLogFile "\`createHeader()\`"

    {
        ch_headerValueTemp=$(
            printf "%s\n" "${progressArray[6]}"
            printf "%s\n" "${includefrontmatterarray[0]}"
            printf "%s\n" "${includefrontmatterarray[1]}"
            printf "%s\n" "${includefrontmatterarray[2]}"
            printf "%s\n" "${progressArray[6]}"
        );
    } || {
        outputToLogFile "ERROR: \`createHeader()\` failed to create header value";

        return 1;
    }

    outputToLogFile "\`createHeader()\` \`$ch_headerValueTemp\` header value created"

    printf "%s" "$ch_headerValueTemp"

    return 0
}

createBody() {
    # string short date cb_parameter_1

    outputFunctionToLogFile "createBody" "$1"

    requireParameterForFunction "createBody" "short date value" "$1" || return 1

    local cb_parameter_1="$1"

    local cb_bodyValueTemp=""
    local cb_dateTemp
    local cb_shortDateTemp
    local cb_sectionValueTemp

    local -a cb_dateIncludeBodySectionsArray=()

    setLocalArrayFromArrayName "cb_dateIncludeBodySectionsArray" "dateincludebodysectionsarray" || {
        outputToLogFile "ERROR: \`createBody()\` failed to set \`cb_dateIncludeBodySectionsArray\` from \`dateincludebodysectionsarray\` array";
        return 1;
    }

    for cb_dateIncludeBodySectionsMatrixTemp in "${cb_dateIncludeBodySectionsArray[@]}"; do
        cb_dateTemp=$(getValueFromMetadataKeyForDateIncludeBodySectionsMatrix "$cb_dateIncludeBodySectionsMatrixTemp" "date") || {
            outputToLogFile "ERROR: \`createBody()\` failed to decode date from \`$cb_dateIncludeBodySectionsMatrixTemp\`";
            continue;
        }

        cb_shortDateTemp=$(getYearMonthFromDate "$cb_dateTemp") || {
            outputToLogFile "ERROR: \`createBody()\` failed to get short date from \`$cb_dateTemp\`";
            continue;
        }

        [[ "$cb_shortDateTemp" == "$cb_parameter_1" ]] || {
            outputToLogFile "INFO: \`createBody()\` skipping section for \`$cb_shortDateTemp\`";
            continue;
        }

        cb_sectionValueTemp=$(getValueFromMetadataKeyForDateIncludeBodySectionsMatrix "$cb_dateIncludeBodySectionsMatrixTemp" "includeBodySection") || {
            outputToLogFile "ERROR: \`createBody()\` failed to decode body section from \`$cb_dateIncludeBodySectionsMatrixTemp\`";
            continue;
        }

        [[ -n "$cb_sectionValueTemp" ]] || {
            outputToLogFile "ERROR: \`createBody()\` no active recommendations found for \`$cb_dateTemp\`";
            continue;
        }

        if [[ -n "$cb_bodyValueTemp" ]]; then
            cb_bodyValueTemp=$(printf "%s\n\n%s" "$cb_bodyValueTemp" "$cb_sectionValueTemp") || {
                outputToLogFile "ERROR: \`createBody()\` failed to append section for \`$cb_dateTemp\`";
                continue;
            }
        else
            cb_bodyValueTemp="$cb_sectionValueTemp"
        fi
    done

    [[ -n "$cb_bodyValueTemp" ]] || {
        outputToLogFile "ERROR: \`createBody()\` failed to find active recommendations for \`$cb_parameter_1\`";
        return 1;
    }

    printf "%s" "$cb_bodyValueTemp"

    return 0
}

createIncludeFileFromShortDate() {
    # string short date ciffsd_parameter_1

    outputFunctionToLogFile "createIncludeFileFromShortDate" "$1"

    requireParameterForFunction "createIncludeFileFromShortDate" "short date value" "$1" || return 1

    local ciffsd_parameter_1="$1"

    local ciffsd_headerValueTemp
    local ciffsd_bodyValueTemp
    local ciffsd_includeFileValueTemp

    {
        ciffsd_headerValueTemp=$(createHeader);
    } || {
        outputToLogFile "ERROR: \`createIncludeFileFromShortDate()\` failed to create header for \`$ciffsd_parameter_1\` short date";
        return 1;
    }
    [[ -n "$ciffsd_headerValueTemp" ]] || {
        outputToLogFile "ERROR: \`createIncludeFileFromShortDate()\` header is empty for \`$ciffsd_parameter_1\` short date";
        return 1;
    }

    {
        ciffsd_bodyValueTemp=$(createBody "$ciffsd_parameter_1");
    } || {
        outputToLogFile "ERROR: \`createIncludeFileFromShortDate()\` failed to create body for \`$ciffsd_parameter_1\` short date";
        return 1;
    }
    [[ -n "$ciffsd_bodyValueTemp" ]] || {
        outputToLogFile "ERROR: \`createIncludeFileFromShortDate()\` body is empty for \`$ciffsd_parameter_1\` short date";
        return 1;
    }

    {
        ciffsd_includeFileValueTemp=$(printf "%s\n\n%s" "$ciffsd_headerValueTemp" "$ciffsd_bodyValueTemp");
    } || {
        outputToLogFile "ERROR: \`createIncludeFileFromShortDate()\` failed to create include file content for \`$ciffsd_parameter_1\` short date";
        return 1;
    }

    printf "%s" "$ciffsd_includeFileValueTemp"

    return 0
}

createIncludeFilesFromShortDatesArray() {
    # ----

    outputFunctionToLogFile "createIncludeFilesFromShortDatesArray"

    requireArrayExists "createIncludeFilesFromShortDatesArray" "name of array" "filemetadatamatrixarray" || {
        outputToLogFile "ERROR: \`createIncludeFilesFromShortDatesArray()\` failed to verify \`filemetadatamatrixarray\` array";
        return 1;
    }

    outputToConsole "\`createIncludeFilesFromShortDatesArray()\` Create retirement include files from all active arrays"

    declare -a ciffsda_retirementdatelistarray=()

    setLocalArrayFromArrayName "ciffsda_retirementdatelistarray" "retirementdatelistarray" || {
        outputToLogFile "ERROR: \`createIncludeFilesFromShortDatesArray()\` failed to set \`ciffsda_retirementdatelistarray\` from \`retirementdatelistarray\` array";
        return 1;
    }

    for ciffsda_dateItemTemp in "${ciffsda_retirementdatelistarray[@]}"; do
        showProgress
        # outputToConsole "createIncludeFilesFromShortDatesArray() entry \`$ciffsda_dateItemTemp\` date from \`retirementdatelistarray\` array" # debug

        local ciffsda_dateShortTemp
        local ciffsda_includeFileTemp

        if [[ "$ciffsda_dateItemTemp" != "MISSING" ]]; then
            ciffsda_dateShortTemp=$(getYearMonthFromDate "$ciffsda_dateItemTemp") || {
                outputToLogFile "ERROR: \`createIncludeFilesFromShortDatesArray()\` failed to get short date for \`$ciffsda_dateItemTemp\`";
                continue;
            }

            ciffsda_includeFileTemp=$(createIncludeFileFromShortDate "$ciffsda_dateShortTemp") || {
                outputToLogFile "ERROR: \`createIncludeFilesFromShortDatesArray()\` failed to create include file for \`$ciffsda_dateShortTemp\`";
                continue;
            }

            outputToRawNamedFile "retirement-date.$ciffsda_dateShortTemp" "md" "$(printf "%s\n" "$ciffsda_includeFileTemp")" || {
                outputToLogFile "ERROR: \`createIncludeFilesFromShortDatesArray()\` failed to create \`retirement-date.$ciffsda_dateShortTemp.md\` include file";
                continue;
            }
        fi
    done

    return 0
}

# create summary section

createCosHeading() {
    # ----

    outputFunctionToLogFile "createCosHeading"

    outputToConsole "\`createCosHeading()\` Create coverage of services section"

    local cch_coverageOfServicesSectionHeading

    {
        cch_coverageOfServicesSectionHeading=$(
            printf "%s %s\n\n" "${headingarray[1]}" "Coverage of services"
            printf "%s" "$coverageOfServicesNote"
        );
    } || {
        outputToLogFile "ERROR: \`createCosHeading()\` failed to create coverage of services section heading";

        return 1;
    }

    printf "%s" "$cch_coverageOfServicesSectionHeading"

    return 0
}

createCosYearHeading() {
    # string year ccmyh_parameter_1

    outputFunctionToLogFile "createCosYearHeading" "$1"

    requireParameterForFunction "createCosYearHeading" "year value" "$1" || return 1

    outputToConsole "\`createCosYearHeading()\` Create year heading"

    local ccmyh_parameter_1="$1"

    local ccmyh_yearSectionHeading

    {
        ccmyh_yearSectionHeading=$(
            printf "%s %s %s%s-%s%s" "${headingarray[2]}" "[Retiring in" "$ccmyh_parameter_1" "](#tab/service-retire" "$ccmyh_parameter_1" ")"
        );
    } || {
        outputToLogFile "ERROR: \`createCosYearHeading()\` failed to create year heading";

        return 1;
    }

    printf "%s" "$ccmyh_yearSectionHeading"

    return 0
}

createCosMonthYearSection() {
    # string short date ccmys_parameter_1

    outputFunctionToLogFile "createCosMonthYearSection" "$1"

    requireParameterForFunction "createCosMonthYearSection" "short date value" "$1" || return 1

    outputToConsole "\`createCosMonthYearSection()\` Create month year section"

    local ccmys_parameter_1="$1"

    local ccmys_monthYearSectionTemp
    local ccmys_monthTemp
    local ccmys_monthStringTemp
    local ccmys_yearTemp

    ccmys_yearTemp=$(printf "%s" "$ccmys_parameter_1" | cut -d'-' -f1) || return 1;
    ccmys_monthTemp=$(printf "%s" "$ccmys_parameter_1" | cut -d'-' -f2) || return 1;

    ccmys_monthStringTemp=$(getStringFromMonth "$ccmys_monthTemp") || {
        outputToLogFile "ERROR: \`createCosMonthYearSection()\` failed to get month string from \`$ccmys_monthTemp\` date";

        return 1;
    }

    {
        ccmys_monthYearSectionTemp=$(
            printf "%s %s %s %s\n\n" "${headingarray[3]}" "Retiring" "$ccmys_monthStringTemp" "$ccmys_yearTemp"
            printf "%s %s %s%s-%s-%s.%s" "[!INCLUDE [Table for retiring" "$ccmys_monthStringTemp" "$ccmys_yearTemp" "](./includes/retiring-feature/retirement-date" "$ccmys_yearTemp" "$ccmys_monthTemp" "md)]"
        );
    } || {
        outputToLogFile "ERROR: \`createCosMonthYearSection()\` failed to create month year section heading";

        return 1;
    }

    echo "$ccmys_monthYearSectionTemp"

    return 0
}

createCosFooter() {
    # ----

    outputFunctionToLogFile "createCosFooter"

    outputToConsole "\`createCosFooter()\` Create coverage of services footer"

    local ccf_footerTemp

    {
        ccf_footerTemp=$(
            printf "%s" "${includefrontmatterarray[0]}"
        );
    } || {
        outputToLogFile "ERROR: \`createCosFooter()\` failed to create coverage of services footer";

        return 1;
    }

    printf "%s" "$ccf_footerTemp"

    return 0
}

createCoverageOfServicesSection() {
    # ----

    outputFunctionToLogFile "createCoverageOfServicesSection"

    requireArrayExists "createCoverageOfServicesSection" "name of array" "retirementdatelistarray" || {
        outputToLogFile "ERROR: \`createCoverageOfServicesSection()\` failed to verify \`retirementdatelistarray\` array";
        return 1;
    }

    outputToConsole "\`createCoverageOfServicesSection()\` Create coverage of services section"

    local ccos_coverageHeadingTemp
    local ccos_finalSectionTemp
    local ccos_yearTracker
    local ccos_yearMonthGroup
    local ccos_yearMonthSectionTemp

    local -a ccos_retirementdatelistarray=()

    setLocalArrayFromArrayName "ccos_retirementdatelistarray" "retirementdatelistarray" || {
        outputToLogFile "ERROR: \`createCoverageOfServicesSection()\` failed to set \`ccos_retirementdatelistarray\` from \`retirementdatelistarray\` array";
        return 1;
    }

    {
        ccos_coverageHeadingTemp=$(createCosHeading);
    } || {
        outputToLogFile "ERROR: \`createCoverageOfServicesSection()\` failed to create coverage heading";
        return 1;
    }

    ccos_yearTracker="1900"
    ccos_yearMonthGroup=""

    for ccos_dateItemTemp in "${ccos_retirementdatelistarray[@]}"; do
        [[ "$ccos_dateItemTemp" != "MISSING" ]] || continue

        local ccos_yearMonthDate
        local ccos_yearTemp
        local ccos_yearHeadingTemp

        ccos_yearMonthDate=$(getYearMonthFromDate "$ccos_dateItemTemp") || {
            outputToLogFile "ERROR: \`createCoverageOfServicesSection()\` failed to get year-month for \`$ccos_dateItemTemp\`";
            continue;
        }

        ccos_yearTemp=$(printf "%s" "$ccos_yearMonthDate" | cut -d'-' -f1) || {
            outputToLogFile "ERROR: \`createCoverageOfServicesSection()\` failed to get year from \`$ccos_yearMonthDate\`";
            continue;
        }

        if [[ "$ccos_yearTemp" != "$ccos_yearTracker" ]]; then
            ccos_yearTracker="$ccos_yearTemp"
            ccos_yearHeadingTemp=$(createCosYearHeading "$ccos_yearTemp") || {
                outputToLogFile "ERROR: \`createCoverageOfServicesSection()\` failed to create year heading for \`$ccos_yearTemp\`";
                continue;
            }
            ccos_yearMonthGroup=$(printf "%s\n\n%s" "$ccos_yearMonthGroup" "$ccos_yearHeadingTemp")
        fi

        ccos_yearMonthSectionTemp=$(createCosMonthYearSection "$ccos_yearMonthDate") || {
            outputToLogFile "ERROR: \`createCoverageOfServicesSection()\` failed to create month-year section for \`$ccos_dateItemTemp\`";
            continue;
        }

        ccos_yearMonthGroup=$(printf "%s\n\n%s" "$ccos_yearMonthGroup" "$ccos_yearMonthSectionTemp")
    done

    {
        ccos_finalSectionTemp=$(printf "%s\n\n%s\n\n%s" "$ccos_coverageHeadingTemp" "$ccos_yearMonthGroup" "$(createCosFooter)");
    } || {
        outputToLogFile "ERROR: \`createCoverageOfServicesSection()\` failed to create final section";
        return 1;
    }

    outputToRawNamedFile "stiif-coverage-of-services" "md"  "$(printf "%s\n" "$ccos_finalSectionTemp")" || {
        outputToLogFile "ERROR: \`createCoverageOfServicesSection()\` failed to create \`stiif-coverage-of-services.md\` raw file";
        return 1;
    }

    printf "%s" "$ccos_finalSectionTemp"

    return 0
}

# add files to learn directory

addFilesToLearnDirectory() {
    # ----

    outputFunctionToLogFile "addFilesToLearnDirectory"

    requireDirectoryExists "addFilesToLearnDirectory" "learn directory" "$learnDirectory" || {
        outputToLogFile "ERROR: \`addFilesToLearnDirectory()\` failed to verify \`$learnDirectory\` directory";

        return 1;
    }

    outputToConsole "\`addFilesToLearnDirectory()\` Add files to learn directory"

    local aftld_learnFileTemp

    for aftld_learnFileTemp in "$outputDirectory"/*.md; do
        showProgress
        # outputToConsole "addFilesToLearnDirectory() entry \`$aftld_learnFileTemp\` file from \`$outputDirectory\` directory" # debug

        copyFileToDirectory "$aftld_learnFileTemp" "$learnDirectory" || {
            outputToLogFile "ERROR: \`addFilesToLearnDirectory()\` failed to copy \`$aftld_learnFileTemp\` file to \`$learnDirectory\` directory";

            return 1;
        }
    done

    return 0
}

# create summary file

createDirectoryOutputSummary() {
    # ----

    outputFunctionToLogFile "createDirectoryOutputSummary"

    requireArrayExists "createDirectoryOutputSummary" "name of array" "directoryarray" || {
        outputToLogFile "ERROR: \`createDirectoryOutputSummary()\` failed to verify \`directoryarray\` array";
        return 1;
    }

    outputToConsole "\`createDirectoryOutputSummary()\` Create summary file from all active arrays"

    local -a cdos_directoryarray=()

    setLocalArrayFromArrayName "cdos_directoryarray" "directoryarray" || {
        outputToLogFile "ERROR: \`createDirectoryOutputSummary()\` failed to set \`cdos_directoryarray\` from \`directoryarray\` array";
        return 1;
    }

    outputToRawNamedFile "stiif-directoryarray" "txt" "$(printf "%s\n" "${cdos_directoryarray[@]}")" || {
        outputToLogFile "ERROR: \`createDirectoryOutputSummary()\` failed to create \`stiif-directoryarray.txt\` for \`directoryarray\` array";
        return 1;
    }

    return 0
}

main() {
    # ----

    outputFunctionToLogFile "main"

    chooseSearch || {
        printf '%s\n' "ERROR: \`main()\` directory search failed" >&2
    }

    createDirectoryOutputSummary || {
        printf '%s\n' "ERROR: \`main()\` failed to create summary file" >&2
    }

    loopAllActiveArrays || {
        printf '%s\n' "ERROR: \`main()\` failed to find one or more arrays" >&2
    }

    createIncludeBodySectionsFromActiveArrays || {
        printf '%s\n' "ERROR: \`main()\` failed to create body sections from active arrays" >&2
    }

    createIncludeFilesFromShortDatesArray || {
        printf '%s\n' "ERROR: \`main()\` failed to create include files" >&2
    }

    # createCoverageOfServicesSection >&2 || {
    #     printf '%s\n' "ERROR: \`main()\` failed to create coverage of services section" >&2
    # }
}

time main
