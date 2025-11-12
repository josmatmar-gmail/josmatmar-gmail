#!/usr/bin/env bash

# Require bash >= 4.3 for 'declare -n' and 'readarray'
if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3) )); then
    printf 'ERROR: Bash 4.3 or newer required (current: %s)\n' "$BASH_VERSION" >&2
    exit 1
fi

set -euo pipefail

# author: github.com/jm-247-ms
# ms.author: v-martinjos@microsoft.com
#
# initial-run 2025-08-15
#
# initail run tim
#
# real    937m32.412s
# user    25m21.305s
# sys     22m29.594s
#
# rerun time
#
# real    15m20.855s
# user    1m36.613s
# sys     0m38.008s

dateStamp="$(printf "%s" "$(date +%Y%b%d-%H%M)")"

case "$(uname -s)" in
    Linux)
        if [[ -n "${WSL_DISTRO_NAME:-}" && -d "/mnt/c/Users/$(id -un)" ]]; then
            userProfile="/mnt/c/Users/$(id -un)"   # WSL
        else
            userProfile="${HOME:-/home/$(id -un)}" # Linux
        fi
      ;;
    Darwin)
        userProfile="/Users/$(id -un)"             # macOS
      ;;
    *)
        userProfile="${HOME:-/home/$(id -un)}"     # Fallback
      ;;
esac

gitDirectory="$userProfile/git"
scriptDirectory="$userProfile/bash/scripts"

inputDirectory="$scriptDirectory/input"
outputDirectory="$scriptDirectory/output"
temporaryDirectory="$scriptDirectory/temporary"

outputIncludesDirectory="$outputDirectory/includes"
retiringFeatureDirectory="$outputIncludesDirectory/retiring-feature"
learnDirectory="$outputDirectory/learn/advisor"

learnAdvisorDirectory="$gitDirectory/jm-247-ms/azure-monitor-docs-pr/articles/advisor"
selfHelpContentDirectory="$gitDirectory/jm-247-ms/SelfHelpContent"

articlesSelfhelpcontentDirectory="$selfHelpContentDirectory/articles"
includesAdvisorLearnDirectory="$learnAdvisorDirectory/includes"
includesAdvisorLearnRetiringFeatureDirectory="$includesAdvisorLearnDirectory/retiring-feature"
temporaryDateRaw="$temporaryDirectory/$dateStamp-stiif-RAW"

inputDirectoryDirectoryOutputTxt="$inputDirectory/stiif-directory-Output.txt"
outputDateRawLogTxt="$outputDirectory/$dateStamp-stiif-RAW-Log.txt"

availableresourcesarray=( "[!INCLUDE [Available](../../includes/inline-reusable-text/available-option.md)]" "[!INCLUDE [Not available](../../includes/inline-reusable-text/not-available-option.md)]" )
cloudarray=( "fairfax" "mooncake" "public" "usnat" "ussec" )
coverageofservicesnotearray=( "Although the current coverage of services for retirement recommendations in Advisor isn't comprehensive, it serves as a solid starting point. At the current time, the platform doesn't have information about the **Impacted Resources** for a subset of recommendations." "Based on your need, use any of the listed ways to get the required information." )
coverageofservicessectionarray=( "Coverage of services" "${coverageofservicesnotearray[0]}" "${coverageofservicesnotearray[1]}" "Retiring in" "tab/service-retire" "Retiring" "!INCLUDE [Table for retiring" "./includes/retiring-feature/retirement-date" "md" "Conclusion" )
dateincludebodysectionsmatrixarray=( "date" "includeBodySection" )
headingarray=( "# " "## " "### " "#### " "##### " "Retirement Recommendations for" )
includefrontmatterarray=( "ms.service: advisor" "ms.topic: include" "ms.date: $(date +%m/%d/%Y)" )
metadatarequiredarray=( "service" "recommendationResourceType" "serviceTreeId" "retirementFeatureName" "retirementDate" "recommendationSubCategory" "recommendationScope" "recommendationMetadataState" )
montharray=( "January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December" )
progressArray=( "." ". " "..." "... " "+" "-" "---" "*" )
sectiontablearray=( "> [!div class=\"mx-tdCol3BreakAll\"]" "> | Service (Resource type) | Retiring feature | Impacted Resources available? |" "> |:--- |:--- |:--- |" )

datePattern="^[0-9]{2}-[0-9]{2}-[0-9]{4}$|^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
guidPattern="^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
stringPattern="^[a-zA-Z0-9 _\-\.\:\,\/\(\)]*$"

# global array

declare -a directoryarray
declare -a metadatavaluearray
declare -a retirementdatearray
declare -a servicearray
declare -a retirementfeaturearray
declare -a impactedsourcevaluearray
declare -a arraynamearray
declare -a datesectionheadermatrixarray
declare -a datetablerowmatrixarray
declare -a dateincludesectiontablearray
declare -a datebodysectionmatrixarray
declare -a datebodymatrixarray
declare -a dateincludefilearray
declare -a coverageofservicesyearyearmonthmatrixarray

validateDirectories() {
    # ----

    printf '%s\n' "INFO: validateDirectories() validating required directories"

    declare -a checkdirectoryarray=( "$learnAdvisorDirectory" "$includesAdvisorLearnDirectory" "$includesAdvisorLearnRetiringFeatureDirectory" )
    declare -a directoryarray=( "$inputDirectory" "$outputDirectory" "$temporaryDirectory" "$outputIncludesDirectory" "$temporaryDateRaw" "$retiringFeatureDirectory" )

    (
        for vd_directoryTemp in "${directoryarray[@]}"; do
            if [[ ! -d "$vd_directoryTemp" ]]; then
                mkdir -p "$vd_directoryTemp" || {
                    printf '%s\n' "ERROR: \`validateDirectories()\` failed to create \`$vd_directoryTemp\` directory";
                    return 1;
                }
            fi
        done
    ) & (
        for vd_checkDirectoryTemp in "${checkdirectoryarray[@]}"; do
            if [[ ! -d "$vd_checkDirectoryTemp" ]]; then
                printf '%s\n' "ERROR: \`validateDirectories()\` failed to find \`$vd_checkDirectoryTemp\` directory";
                return 1;
            fi
        done
    ) & wait

    return 0
}

# output

outputToConsole() {
    # *

    printf '\n%s\n' "$*" || {
        printf '%s\n' "ERROR: outputToConsole() failed to write to console";
        return 1;
    }

    return 0
}

outputToLogFile() {
    # *

    printf '%s\n' "$*" >> "$outputDateRawLogTxt" || {
        printf '%s\n' "ERROR: outputToLogFile() failed to write to $outputDateRawLogTxt";
        return 1;
    }

    return 0
}

outputToRawNamedFile() {
    # string outputFileName otrnf_parameter_1
    # string outputFileExtension otrnf_parameter_2
    # string content (all remaining args)

    local otrnf_parameter_1="$1"
    local otrnf_parameter_2="$2"

    shift 2

    local otrnf_outputFileName

    otrnf_outputFileName="$(printf "%s-%s.%s" "$temporaryDateRaw" "$otrnf_parameter_1" "$otrnf_parameter_2")"

    [[ -n "${otrnf_outputFileName}" ]] || return 1

    if ! printf '%s\n' "$*" > "$otrnf_outputFileName" 2>/dev/null; then
        outputToLogFile "ERROR: \`outputToRawNamedFile()\` failed to write to \`$otrnf_outputFileName\`"
        return 1
    fi

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

    if [[ $# -eq 0 ]]; then
        outputToLogFile "\`> $ $oftlf_parameter_1()\`"
    else
        outputToLogFile "\`> $ $oftlf_parameter_1() \"$*\"\`"
    fi

    return 0
}

# utilty

getPathForFile() {
    # string file gpf_parameter_1

    outputFunctionToLogFile "getPathForFile" "$1"
    requireFileParameterExists "getPathForFile" "file" "$1" || return 1

    dirname -- "$1" || {
        outputToLogFile "ERROR: \`getPathForFile()\` failed to get path for \`$1\` file";
        return 1;
    }

    return 0
}

getFileExtensionForFile() {
    # string file gfeff_parameter_1

    outputFunctionToLogFile "getFileExtensionForFile" "$1"
    requireFileParameterExists "getFileExtensionForFile" "file" "$1" || return 1

    local gfeff_parameter_1="$1"

    local gfeff_baseNameTemp

    gfeff_baseNameTemp="$(basename -- "$gfeff_parameter_1")" || {
        outputToLogFile "ERROR: \`getFileExtensionForFile()\` failed to get base name for \`$gfeff_parameter_1\` file";
        return 1;
    }

    if [[ "$gfeff_baseNameTemp" == *.* && "$gfeff_baseNameTemp" != .* ]]; then
        printf "%s" "${gfeff_baseNameTemp##*.}"
    else
        printf ""
    fi

    return 0
}

getShortNameForFile() {
    # string file gsnff_parameter_1

    outputFunctionToLogFile "getShortNameForFile" "$1"
    requireFileParameterExists "getShortNameForFile" "file" "$1" || return 1

    local gsnff_base

    gsnff_base="${1##*/}" || {
        outputToLogFile "ERROR: \`getShortNameForFile()\` failed to get base for \`$1\` file";
        return 1;
    }

    printf "%s" "${gsnff_base%.*}" || {
        outputToLogFile "ERROR: \`getShortNameForFile()\` failed to get short name for \`$1\` file";
        return 1;
    }

    return 0
}

normalizeString() {
    # string input ns_parameter_1

    outputFunctionToLogFile "normalizeString" "$1"
    requireParameterForFunction "normalizeString" "input" "$1" || return 1

    printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]_' || {
        outputToLogFile "ERROR: \`normalizeString()\` failed to normalize \`$1\` input";
        return 1;
    }

    return 0
}

toLowerString() {
    # string input tls_parameter_1

    outputFunctionToLogFile "toLowerString" "$1"
    requireParameterForFunction "toLowerString" "input" "$1" || return 1

    printf '%s' "$1" | tr '[:upper:]' '[:lower:]' || {
        outputToLogFile "ERROR: \`toLowerString()\` failed to convert \`$1\` input to lower case"
        return 1
    }

    return 0
}

getYearMonthFromYearMonthDay() {
    # string date gymfymd_parameter_1

    outputFunctionToLogFile "getYearMonthFromYearMonthDay" "$1"
    requireParameterForFunction "getYearMonthFromYearMonthDay" "date value" "$1" || return 1

    local gymfymd_parameter_1="$1"

    local gymfymd_yearMonth

    if [[ ! "$gymfymd_parameter_1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        outputToLogFile "INFO: \`getYearMonthFromYearMonthDay()\` convert \`$gymfymd_parameter_1\` to standard date format"
        gymfymd_parameter_1="$(getYearMonthDayFromMonthDayYear "$gymfymd_parameter_1")" || return 1
    fi

    gymfymd_yearMonth="$(printf "%s" "$gymfymd_parameter_1" | awk -F'-' '{print $1 "-" $2}')" || {
        outputToLogFile "ERROR: \`getYearMonthFromYearMonthDay()\` failed to parse \`$gymfymd_parameter_1\` date value"
        return 1
    }

    printf "%s" "$gymfymd_yearMonth"

    return 0
}

getYearFromYearMonth() {
    # string date gyfym_parameter_1

    outputFunctionToLogFile "getYearFromYearMonth" "$1"
    requireParameterForFunction "getYearFromYearMonth" "date value" "$1" || return 1

    local gyfym_parameter_1="$1"

    local gyfym_year

    if [[ "$gyfym_parameter_1" =~ ^([0-9]{4}-[0-9]{2})$ ]]; then
        gyfym_year="$(printf "%s" "$gyfym_parameter_1" | cut -d'-' -f1)" || {
            outputToLogFile "ERROR: \`getYearFromYearMonth()\` failed to parse \`$gyfym_parameter_1\` date value";
            return 1;
        }

        printf "%s" "$gyfym_year" ||

        return 0
    else
        outputToLogFile "ERROR: \`getYearFromYearMonth()\` failed to parse \`$gyfym_parameter_1\` date value"

        return 1
    fi
}

getDayIntegerFromDay() {
    # string day gdifd_parameter_1

    local gdifd_parameter_1="$1"

    gdifd_parameter_1="${gdifd_parameter_1#0}"

    if [[ "$gdifd_parameter_1" =~ ^[1-9]$|^[12][0-9]$|^3[01]$ ]]; then
        printf "%s" "$gdifd_parameter_1"
        return 0
    else
        outputToLogFile "ERROR: \`getDayIntegerFromDay()\` failed to validate \`$1\` day value"
        return 1
    fi
}

getMonthStringFromMonth() {
    # string month gmsfm_parameter_1

    outputFunctionToLogFile "getMonthStringFromMonth" "$1"
    requireParameterForFunction "getMonthStringFromMonth" "month value" "$1" || return 1

    local gmsfm_parameter_1="$1"

    if [[ "$gmsfm_parameter_1" =~ ^0*([1-9]|1[0-2])$ ]]; then
        gmsfm_parameter_1="${BASH_REMATCH[1]}" || {
            outputToLogFile "ERROR: \`getMonthStringFromMonth()\` failed to parse \`$1\` month value"
            return 1
        }
    else
        outputToLogFile "ERROR: \`getMonthStringFromMonth()\` failed to validate \`$gmsfm_parameter_1\` month value"
        return 1
    fi

    printf "%s" "${montharray[$((gmsfm_parameter_1-1))]}"

    return 0
}

verifyYearMonthDayFormat() {
    # string date vymdf_parameter_1

    outputFunctionToLogFile "verifyYearMonthDayFormat" "$1"
    requireParameterForFunction "verifyYearMonthDayFormat" "date value" "$1" || return 1

    [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || {
        return 1
    }

    return 0
}

getYearFromMonthDayYear() {
    # string date gyfmdy_parameter_1

    outputFunctionToLogFile "getYearFromMonthDayYear" "$1"
    requireParameterForFunction "getYearFromMonthDayYear" "date value" "$1" || return 1

    local gyfmdy_parameter_1="$1"

    local gyfmdy_year

    if [[ "$gyfmdy_parameter_1" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})$ ]]; then
        gyfmdy_year="$(printf "%s" "$gyfmdy_parameter_1" | cut -d'-' -f1)" || return 1

        printf "%s" "$gyfmdy_year" || return 1

        return 0
    else
        outputToLogFile "ERROR: \`getYearFromMonthDayYear()\` failed to parse \`$gyfmdy_parameter_1\` date value"

        return 1
    fi
}

getYearMonthDayFromMonthDayYear() {
    # string date gymdfmdy_parameter_1

    outputFunctionToLogFile "getYearMonthDayFromMonthDayYear" "$1"
    requireParameterForFunction "getYearMonthDayFromMonthDayYear" "date value" "$1" || return 1

    local gymdfmdy_parameter_1="$1"

    local gymdfmdy_day
    local gymdfmdy_month
    local gymdfmdy_year

    if [[ "$gymdfmdy_parameter_1" =~ ^([0-9]{2})[-/.]([0-9]{2})[-/.]([0-9]{4})$ ]]; then
        (
            gymdfmdy_month="$(printf "%s" "$gymdfmdy_parameter_1" | (cut -d'-' -f1 || cut -d'/' -f1))" || return 1
        ) & (
            gymdfmdy_day="$(printf "%s" "$gymdfmdy_parameter_1" | (cut -d'-' -f2 || cut -d'/' -f2))" || return 1
        ) & (
            gymdfmdy_year="$(printf "%s" "$gymdfmdy_parameter_1" | (cut -d'-' -f3 || cut -d'/' -f3))" || return 1
        ) & wait

        printf "%s-%s-%s" "$gymdfmdy_year" "$gymdfmdy_month" "$gymdfmdy_day" || return 1

        return 0
    else
        outputToLogFile "ERROR: \`getYearMonthDayFromMonthDayYear()\` failed to parse \`$gymdfmdy_parameter_1\` date value"
        return 1
    fi
}

getMonthDayYearStringFromYearMonthDay() {
    # string date gmdysfymd_parameter_1

    outputFunctionToLogFile "getMonthDayYearStringFromYearMonthDay" "$1"
    requireParameterForFunction "getMonthDayYearStringFromYearMonthDay" "date value" "$1" || return 1

    local gmdysfymd_parameter_1="$1"

    local gmdysfymd_day
    local gmdysfymd_dayInteger
    local gmdysfymd_month
    local gmdysfymd_monthString
    local gmdysfymd_year

    verifyYearMonthDayFormat "$gmdysfymd_parameter_1" || {
        outputToLogFile "INFO: \`getMonthDayYearStringFromYearMonthDay()\` convert \`$gmdysfymd_parameter_1\` month-day-year to year-month-day format"
        gmdysfymd_parameter_1="$(getYearMonthDayFromMonthDayYear "$gmdysfymd_parameter_1")" || return 1
    }
    
    IFS='-' read -r gmdysfymd_year gmdysfymd_month gmdysfymd_day <<< "$gmdysfymd_parameter_1" || {
        outputToLogFile "ERROR: \`getMonthDayYearStringFromYearMonthDay()\` failed to split gmdysfymd_parameter_1: $gmdysfymd_parameter_1"
        return 1
    }

    (
        gmdysfymd_monthString="$(getMonthStringFromMonth "$gmdysfymd_month")" || return 1
    ) & (
        gmdysfymd_dayInteger="$(getDayIntegerFromDay "$gmdysfymd_day")" || return 1
    ) & wait

    printf "%s %s, %s" "$gmdysfymd_monthString" "$gmdysfymd_dayInteger" "$gmdysfymd_year"
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
    local gsnfa_arrayNameSafe

    gsnfa_arrayNameSafe="$(normalizeString "$gsnfa_parameter_1" 2>/dev/null)" || gsnfa_arrayNameSafe="$gsnfa_parameter_1"

    [[ -n "$gsnfa_arrayNameSafe" ]] || gsnfa_arrayNameSafe="$gsnfa_parameter_1"

    [[ "$gsnfa_arrayNameSafe" =~ ^[0-9] ]] && gsnfa_arrayNameSafe="x_$gsnfa_arrayNameSafe"

    if [[ ! "$gsnfa_arrayNameSafe" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
        outputToLogFile "ERROR: \`getSafeNameForArray()\` failed to produce a valid variable name from \`$gsnfa_parameter_1\` input"
        return 1
    fi

    printf "%s" "$gsnfa_arrayNameSafe"

    return 0
}

# display utility

showProgressBar() {
    # string current spb_parameter_1
    # string total spb_parameter_2

    local spb_parameter_1="$1"
    local spb_parameter_2="$2"

    local spb_empty
    local spb_filled
    local spb_percent
    local spb_width

    spb_percent=$(( 100 * spb_parameter_1 / spb_parameter_2 ))
    spb_width=40

    spb_filled=$(( spb_width * spb_parameter_1 / spb_parameter_2 ))

    spb_empty=$(( spb_width - spb_filled ))

    {
        printf "\r["
        printf "%0.s#" $(seq 1 $spb_filled)
        printf "%0.s-" $(seq 1 $spb_empty)
        printf "] %3d%% (%d/%d)" "$spb_percent" "$spb_parameter_1" "$spb_parameter_2"

        if (( spb_parameter_1 == spb_parameter_2 )); then
            printf "\n"
        fi
    } || {
        outputToLogFile "ERROR: \`showProgressBar()\` failed to show progress bar"
        return 1
    }

    return 0
}

showProgress() {
    printf "\r%s" "${progressArray[2]}" || {
        outputToLogFile "ERROR: \`showProgress()\` failed to show progress indicator"
        return 1
    }

    return 0
}

trimPathForDisplay() {
    # string path tpfd_parameter_1

    outputFunctionToLogFile "trimPathForDisplay" "$1"
    requireParameterForFunction "trimPathForDisplay" "path" "$1" || return 1

    local tpfd_parameter_1="$1"

    local tpfd_prefix
    local tpfd_trimmed

    tpfd_prefix="$userProfile"

    if [[ "$tpfd_parameter_1" == "$tpfd_prefix"* ]]; then
        tpfd_trimmed="~${tpfd_parameter_1#$tpfd_prefix}" || {
            outputToLogFile "ERROR: \`trimPathForDisplay()\` failed to trim \`$tpfd_parameter_1\` path for display";
            return 1;
        }
    else
        tpfd_trimmed="$tpfd_parameter_1"
    fi

    tpfd_trimmed="${tpfd_trimmed//\/\//\/}" || {
        outputToLogFile "ERROR: \`trimPathForDisplay()\` failed to normalize \`$tpfd_trimmed\` path for display";
        return 1;
    }

    if [[ "$tpfd_trimmed" != "/" ]]; then
        tpfd_trimmed="${tpfd_trimmed%/}" || {
            outputToLogFile "ERROR: \`trimPathForDisplay()\` failed to remove trailing slash from \`$tpfd_trimmed\` path for display";
            return 1;
        }
    fi

    printf "%s" "$tpfd_trimmed"

    return 0
}

# verify

verifyArrayExists() {
    # string source-array-name vae_parameter_1

    outputFunctionToLogFile "verifyArrayExists" "$1"

    requireParameterForFunction "verifyArrayExists" "source-array-name" "$1" || return 1

    local vae_parameter_1="$1"

    if ! declare -p "$vae_parameter_1" 2>/dev/null | grep -Eq 'declare -[aA] '; then
        outputToLogFile "ERROR: \`verifyArrayExists()\` failed to find \`$vae_parameter_1\` array or it is not an array"
        return 1
    fi

    return 0
}

verifyFileExists() {
    # string file vfe_parameter_1

    outputFunctionToLogFile "verifyFileExists" "$1"

    requireParameterForFunction "verifyFileExists" "file" "$1" || return 1

    local vfe_parameter_1="$1"

    if [[ ! -f "$vfe_parameter_1" ]]; then
        outputToLogFile "ERROR: \`verifyFileExists()\` failed to find \`$vfe_parameter_1\` file"
        return 1
    fi

    return 0
}

verifyDirectoryExists() {
    # string directory vde_parameter_1

    outputFunctionToLogFile "verifyDirectoryExists" "$1"

    requireParameterForFunction "verifyDirectoryExists" "directory" "$1" || return 1

    local vde_parameter_1="$1"

    if [[ ! -d "$vde_parameter_1" ]]; then
        outputToLogFile "ERROR: \`verifyDirectoryExists()\` failed to find \`$vde_parameter_1\` directory"
        return 1
    fi

    return 0
}

# require

requireParameterForFunction() {
    # Usage:
    #  requireParameterForFunction function_name parameter_name parameter_value
    #
    # string name of function rpff_parameter_1
    # string name of parameter rpff_parameter_2
    # string value of parameter rpff_parameter_3

    local rpff_parameter_1="$1"
    local rpff_parameter_2="$2"
    local rpff_parameter_3="$3"

    [[ -n "$rpff_parameter_1" ]] || {
        outputToLogFile "ERROR: \`requireParameterForFunction()\` name of function not provided"
        return 1
    }
    [[ -n "$rpff_parameter_2" ]] || {
        outputToLogFile "ERROR: \`requireParameterForFunction()\` name of parameter not provided to \`$rpff_parameter_1\` function"
        return 1
    }
    [[ -n "$rpff_parameter_3" ]] || {
        outputToLogFile "ERROR: \`requireParameterForFunction()\` value of parameter not provided for \`$rpff_parameter_2\` parameter to \`$rpff_parameter_1\` function"
        return 1
    }
    return 0
}

requireFileParameterExists() {
    # string function rfpe_parameter_1
    # string name of parameter rfpe_parameter_2
    # string file rfpe_parameter_3

    outputFunctionToLogFile "requireFileParameterExists" "$1" "$2" "$3"

    declare -a rfpe_parameterarray=( "$1" "$2" "$3" )
    declare -a rfpe_namearray=( "function" "name of parameter" "file" )

    for rfpe_index in "${!rfpe_parameterarray[@]}"; do
        requireParameterForFunction "requireFileParameterExists" "${rfpe_namearray[$rfpe_index]}" "${rfpe_parameterarray[$rfpe_index]}" || return 1
    done

    local rfpe_parameter_1="$1"
    local rfpe_parameter_2="$2"
    local rfpe_parameter_3="$3"

    requireParameterForFunction "$rfpe_parameter_1" "$rfpe_parameter_2" "$rfpe_parameter_3" || return 1
    verifyFileExists "$rfpe_parameter_3" || return 1

    return 0
}

requireDirectoryParameterExists() {
    # string function rdpe_parameter_1
    # string name of parameter rdpe_parameter_2
    # string directory rdpe_parameter_3

    outputFunctionToLogFile "requireDirectoryParameterExists" "$1" "$2" "$3"

    declare -a rdpe_parameterarray=( "$1" "$2" "$3" )
    declare -a rdpe_namearray=( "function" "name of parameter" "directory" )

    for rdpe_index in "${!rdpe_parameterarray[@]}"; do
        requireParameterForFunction "requireDirectoryParameterExists" "${rdpe_namearray[$rdpe_index]}" "${rdpe_parameterarray[$rdpe_index]}" || return 1
    done

    local rdpe_parameter_1="$1"
    local rdpe_parameter_2="$2"
    local rdpe_parameter_3="$3"

    requireParameterForFunction "$rdpe_parameter_1" "$rdpe_parameter_2" "$rdpe_parameter_3" || return 1
    verifyDirectoryExists "$rdpe_parameter_3" || return 1

    return 0
}

requireArrayParameterExists() {
    # string function ra_pe_parameter_1
    # string name of parameter ra_pe_parameter_2
    # string name of array ra_pe_parameter_3

    outputFunctionToLogFile "requireArrayParameterExists" "$1" "$2" "$3"

    declare -a ra_pe_parameterarray=( "$1" "$2" "$3" )
    declare -a ra_pe_namearray=( "function" "name of parameter" "array" )

    for ra_pe_index in "${!ra_pe_parameterarray[@]}"; do
        requireParameterForFunction "requireArrayParameterExists" "${ra_pe_namearray[$ra_pe_index]}" "${ra_pe_parameterarray[$ra_pe_index]}" || return 1
    done

    local ra_pe_parameter_1="$1"
    local ra_pe_parameter_2="$2"
    local ra_pe_parameter_3="$3"

    requireParameterForFunction "$ra_pe_parameter_1" "$ra_pe_parameter_2" "$ra_pe_parameter_3" || return 1

    verifyArrayExists "$ra_pe_parameter_3" || return 1

    return 0
}

# encode and decode

encodeMetadataValueMatrix() {
    # string service emvm_parameter_1
    # string datasource emvm_parameter_2
    # string filePath emvm_parameter_3
    # string impactedSourceValue emvm_parameter_4
    # string retirementDate emvm_parameter_5
    # string retirementFeatureName emvm_parameter_6
    # string serviceTreeId emvm_parameter_7

    outputFunctionToLogFile "encodeMetadataValueMatrix" "$1" "$2" "$3" "$4" "$5" "$6" "$7"

    requireParameterForFunction "encodeMetadataValueMatrix" "service value" "$1" || return 1
    requireParameterForFunction "encodeMetadataValueMatrix" "dataSource value" "$2" || return 1
    requireParameterForFunction "encodeMetadataValueMatrix" "filePath value" "$3" || return 1
    requireParameterForFunction "encodeMetadataValueMatrix" "impactedSourceValue value" "$4" || return 1
    requireParameterForFunction "encodeMetadataValueMatrix" "retirementDate value" "$5" || return 1
    requireParameterForFunction "encodeMetadataValueMatrix" "retirementFeatureName value" "$6" || return 1
    requireParameterForFunction "encodeMetadataValueMatrix" "serviceTreeId value" "$7" || return 1

    local emvm_parameter_1="$1"
    local emvm_parameter_2="$2"
    local emvm_parameter_3="$3"
    local emvm_parameter_4="$4"
    local emvm_parameter_5="$5"
    local emvm_parameter_6="$6"
    local emvm_parameter_7="$7"
    
    local emvm_encodedMetadataValueMatrix

    emvm_encodedMetadataValueMatrix=$(
        printf "%s%s" "$emvm_parameter_1" "^^"
        printf "%s%s" "$emvm_parameter_2" "^^"
        printf "%s%s" "$emvm_parameter_3" "^^"
        printf "%s%s" "$emvm_parameter_4" "^^"
        printf "%s%s" "$emvm_parameter_5" "^^"
        printf "%s%s" "$emvm_parameter_6" "^^"
        printf "%s%s" "$emvm_parameter_7" "^^"
    ) || {
        outputToLogFile "ERROR: \`encodeMetadataValueMatrix()\` failed to encode metadataValueMatrix value";
        return 1;
    }

    outputToLogFile "DEBUG: \`encodeMetadataValueMatrix()\` encoded \`$emvm_encodedMetadataValueMatrix\` metadataValueMatrix value"

    printf "%s" "$emvm_encodedMetadataValueMatrix"

    return 0
}

decodeMetadataValueMatrixForIndex() {
    # string metadataValuematrix dmvmfi_parameter_1
    # int index dmvmfi_parameter_2

    outputFunctionToLogFile "decodeMetadataValueMatrixForIndex" "$1" "$2"

    requireParameterForFunction "decodeMetadataValueMatrixForIndex" "metadataValuematrix value" "$1" || return 1
    requireParameterForFunction "decodeMetadataValueMatrixForIndex" "index value" "$2" || return 1

    local dmvmfi_parameter_1="$1"
    local dmvmfi_parameter_2="$2"

    local dmvmfi_field
    local dmvmfi_fields
    local dmvmfi_index
    local dmvmfi_targetIndex
    local dmvmfi_value

    dmvmfi_fields="$dmvmfi_parameter_1"
    dmvmfi_index=0
    dmvmfi_targetIndex="$((dmvmfi_parameter_2 + 1))"
    dmvmfi_value=""

    while [[ "$dmvmfi_fields" == *"^^"* ]]; do
        dmvmfi_index="$((dmvmfi_index + 1))"
        dmvmfi_field="${dmvmfi_fields%%^^*}"
        if [[ $dmvmfi_index -eq $dmvmfi_targetIndex ]]; then
            dmvmfi_value="$dmvmfi_field"
            break
        fi
        dmvmfi_fields="${dmvmfi_fields#*^^}"
    done

    if [[ -z "$dmvmfi_value" && $dmvmfi_index -lt $dmvmfi_targetIndex && -n "$dmvmfi_fields" ]]; then
        dmvmfi_index="$((dmvmfi_index + 1))"
        if [[ $dmvmfi_index -eq $dmvmfi_targetIndex ]]; then
            dmvmfi_value="$dmvmfi_fields"
        fi
    fi

    if [[ -z "$dmvmfi_value" ]]; then
        outputToLogFile "ERROR: \`decodeMetadataValueMatrixForIndex()\` \`$dmvmfi_parameter_2\` index is out of bounds"
        return 1
    fi

    printf "%s" "$dmvmfi_value"

    return 0
}

decodeMetadataValueMatrixForKey() {
    # string metadataValuematrix dmvmfk_parameter_1
    # string metadata key dmvmfk_parameter_2

    outputFunctionToLogFile "decodeMetadataValueMatrixForKey" "$1" "$2"

    requireParameterForFunction "decodeMetadataValueMatrixForKey" "metadataValuematrix value" "$1" || return 1
    requireParameterForFunction "decodeMetadataValueMatrixForKey" "metadata key value" "$2" || return 1

    local dmvmfk_parameter_1="$1"
    local dmvmfk_parameter_2="$2"

    local dmvmfk_index
    local dmvmfk_value

    dmvmfk_index=-1

    declare -a dmvmfk_metadatakeysarray=( "service" "recommendationResourceType" "dataSource" "filePath" "impactedSourceValue" "retirementDate" "retirementFeatureName" "serviceTreeId" )

    [[ "${dmvmfk_metadatakeysarray[*]}" =~ "$dmvmfk_parameter_2" ]] || {
        outputToLogFile "ERROR: \`decodeMetadataValueMatrixForKey()\` \`$dmvmfk_parameter_2\` is not a valid metadata key";
        return 1;
    }

    case "$dmvmfk_parameter_2" in
        service)
            dmvmfk_index=0
          ;;
        recommendationResourceType)
            dmvmfk_index=1
          ;;
        dataSource)
            dmvmfk_index=2
          ;;
        filePath)
            dmvmfk_index=3
          ;;
        impactedSourceValue)
            dmvmfk_index=4
          ;;
        retirementDate)
            dmvmfk_index=5
          ;;
        retirementFeatureName)
            dmvmfk_index=6
          ;;
        serviceTreeId)
            dmvmfk_index=7
          ;;
        *)
            for dmvmfk_metadataIndex in "${!dmvmfk_metadatakeysarray[@]}"; do
                [[ "${dmvmfk_metadatakeysarray[$dmvmfk_metadataIndex]}" == "$dmvmfk_parameter_2" ]] && {
                    dmvmfk_index="$((dmvmfk_metadataIndex+1))";
                    break;
                }
            done
          ;;
    esac

    (( dmvmfk_index >= 0 )) || {
        outputToLogFile "ERROR: \`decodeFileMetadataValueMatrix()\` failed to find \`$dmvmfk_parameter_2\` in \`dmvmfk_metadatakeysarray\` array"
        return 1
    }

    dmvmfk_value="$(decodeMetadataValueMatrixForIndex "$dmvmfk_parameter_1" "$dmvmfk_index")" || {
        outputToLogFile "ERROR: \`decodeMetadataValueMatrixForKey()\` failed to decode \`$dmvmfk_parameter_2\` from metadataValueMatrix value";
        return 1;
    }

    printf "%s" "$dmvmfk_value"

    return 0
}

# process

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

getMetadataValueForKeyInJson() {
    # string json value gmvfkij_parameter_1
    # string metadata key gmvfkij_parameter_2

    outputFunctionToLogFile "getMetadataValueForKeyInJson" "[***]" "$2"

    requireParameterForFunction "getMetadataValueForKeyInJson" "JSON value" "[***]" || return 1
    requireParameterForFunction "getMetadataValueForKeyInJson" "metadata key" "$2" || return 1

    local gmvfkij_parameter_1="$1"
    local gmvfkij_parameter_2="$2"

    local gmvfkij_checkType
    local gmvfkij_metadataValueTemp
    local gmvfkij_metadataValueCleanTemp
    local gmvfkij_stage1
    local gmvfkij_stage2
    local gmvfkij_stringDateGuidPattern
    local today

    gmvfkij_checkType=""
    gmvfkij_metadataValueTemp=""
    gmvfkij_metadataValueCleanTemp=""
    gmvfkij_stage1=""
    gmvfkij_stage2=""
    gmvfkij_stringDateGuidPattern="^[a-zA-Z0-9 _\-\.\:\,\/\(\)]*$|^[0-9]{2}-[0-9]{2}-[0-9]{4}$|^[0-9]{4}-[0-9]{2}-[0-9]{2}$|^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
    gmvfkij_today="$(date +%Y-%m-%d)"

    validateJsonValue "$gmvfkij_parameter_1" || {
        outputToLogFile "ERROR: \`getMetadataValueForKeyInJson()\` failed to validate JSON value"
        return 1
    }

    case "$gmvfkij_parameter_2" in
        "dataSource")
            gmvfkij_checkType="data"
          ;;
        "impactedSourceValue")
            gmvfkij_checkType="impact"
            gmvfkij_parameter_2="dataSource"
          ;;
        "retirementDate")
            gmvfkij_checkType="retirement"
          ;;
        *)
            gmvfkij_checkType="other"
          ;;
    esac

    {
        gmvfkij_stage1="$(printf "%s" "$gmvfkij_parameter_1" | grep -o "\"$gmvfkij_parameter_2\"[[:space:]]*:[[:space:]]*\"[^\"]*\"")" || true
        gmvfkij_stage2="$(printf "%s" "$gmvfkij_stage1" | sed -n -E "s/.*\"$gmvfkij_parameter_2\"[[:space:]]*:[[:space:]]*\"([^\"]*)\".*/\1/p")" || true
        gmvfkij_metadataValueTemp="$(printf "%s" "$gmvfkij_stage2")"
    } || {
        outputToLogFile "ERROR: \`getMetadataValueForKeyInJson()\` failed to parse value for \`gmvfkij_parameter_2\` metadata key";
        return 1;
    }

    if [[ "$gmvfkij_checkType" == "data" ]]; then
        if [[ -z "$gmvfkij_metadataValueTemp" || ! "$gmvfkij_metadataValueTemp" =~ ^(ARG|Cosmos|Kusto|SAS)$ ]]; then
            outputToLogFile "INFO: \`getMetadataValueForKeyInJson()\` missing or non-valid dataSource, returning \`nomatch\`"

            gmvfkij_metadataValueTemp="nomatch"
        fi
    elif [[ "$gmvfkij_checkType" == "impact" ]]; then
        if [[ -z "$gmvfkij_metadataValueTemp" ]]; then
            outputToLogFile "INFO: \`getMetadataValueForKeyInJson()\` missing dataSource for impactedSourceValue, returning \`Not available\`"

            printf "%s" "${availableresourcesarray[1]}"

            return 0
        fi
    elif [[ -z "$gmvfkij_metadataValueTemp" ]]; then
        outputToLogFile "ERROR: \`getMetadataValueForKeyInJson()\` failed to find \`$gmvfkij_parameter_2\` metadata key in JSON value"

        return 1
    fi

    gmvfkij_metadataValueCleanTemp="$(printf "%s" "$gmvfkij_metadataValueTemp" | sed -E "s/^[[:space:]]+//; s/[[:space:]]+$//")" || gmvfkij_metadataValueCleanTemp="$gmvfkij_metadataValueTemp"

    if ! printf '%s' "$gmvfkij_metadataValueCleanTemp" | grep -Eq "$gmvfkij_stringDateGuidPattern"; then
        if [[ "$gmvfkij_checkType" == "data" ]]; then
            gmvfkij_metadataValueCleanTemp="nomatch"
        else
            outputToLogFile "ERROR: \`getMetadataValueForKeyInJson()\` found special characters in \`$gmvfkij_parameter_2\` metadata value"

            return 1
        fi
    fi

    if [[ "$gmvfkij_checkType" == "impact" ]]; then
        if [[ "$gmvfkij_metadataValueTemp" =~ ^(ARG|Cosmos|Kusto|SAS)$ ]]; then
            outputToLogFile "INFO: \`getMetadataValueForKeyInJson()\` set impactedSourceValue for valid \`$gmvfkij_metadataValueTemp\` dataSource"

            gmvfkij_metadataValueCleanTemp="${availableresourcesarray[0]}"
        else
            outputToLogFile "INFO: \`getMetadataValueForKeyInJson()\` set impactedSourceValue for missing or non-valid \`$gmvfkij_metadataValueTemp\` dataSource"

            gmvfkij_metadataValueCleanTemp="${availableresourcesarray[1]}"
        fi
    elif [[ "$gmvfkij_checkType" == "data" && ! "$gmvfkij_metadataValueTemp" =~ ^(ARG|Cosmos|Kusto|SAS)$ ]]; then
        outputToLogFile "INFO: \`getMetadataValueForKeyInJson()\` missing dataSource, returning \`nomatch\`"

        gmvfkij_metadataValueCleanTemp="nomatch"
    fi

    if [[ "$gmvfkij_checkType" == "retirement" ]]; then
        if ! verifyYearMonthDayFormat "$gmvfkij_metadataValueCleanTemp"; then
            outputToLogFile "INFO: \`getMetadataValueForKeyInJson()\` convert \`$gmvfkij_metadataValueCleanTemp\` reverse date to standard date format";
            gmvfkij_metadataValueCleanTemp="$(getYearMonthDayFromMonthDayYear "$gmvfkij_metadataValueCleanTemp")" || {
                outputToLogFile "ERROR: \`getMetadataValueForKeyInJson()\` failed to convert \`$gmvfkij_metadataValueCleanTemp\` retirementDate";
                return 1;
            }
        fi

        if [[ "$gmvfkij_metadataValueCleanTemp" < "$gmvfkij_today" || "$gmvfkij_metadataValueCleanTemp" == "$gmvfkij_today" ]]; then
            outputToLogFile "INFO: \`getMetadataValueForKeyInJson()\` skip \`$gmvfkij_metadataValueCleanTemp\` retirementDate (not after today)"
            return 1
        fi
    fi

    printf "%s" "$gmvfkij_metadataValueCleanTemp"

    return 0
}

getMetadataValueMatrixForJson() {
    # decode key is service^^recommendationResourceType^^datasource^^filePath^^impactedSourceValue^^^retirementDate^^retirementFeatureName^^serviceTreeId^^
    # string file gmvmfj_parameter_1
    # string json value gmvmfj_parameter_2

    outputFunctionToLogFile "getMetadataValueMatrixForJson" "$1" "[***]"

    requireParameterForFunction "getMetadataValueMatrixForJson" "file value" "$1" || return 1
    requireParameterForFunction "getMetadataValueMatrixForJson" "JSON value" "[***]" || return 1

    local gmvmfj_parameter_1="$1"
    local gmvmfj_parameter_2="$2"

    local gmvmfj_metadataValue
    local gmvmfj_requiredValuesMatrixTemp

    local gmvmfj_dataSourceValue
    local gmvmfj_impactedSourceValue
    local gmvmfj_recommendationResourceTypeValue
    local gmvmfj_retirementDateValue
    local gmvmfj_retirementFeatureNameValue
    local gmvmfj_serviceValue
    local gmvmfj_serviceTreeIdValue

    (
        gmvmfj_dataSourceValue="$(getMetadataValueForKeyInJson "$gmvmfj_parameter_2" "dataSource")" || {
            outputToLogFile "DEBUG: \`getMetadataValueMatrixForJson()\` failed to get value for \`dataSource\` metadata key from JSON value";
            gmvmfj_dataSourceValue="nomatch"
        }
    ) & (
        gmvmfj_impactedSourceValue="$(getMetadataValueForKeyInJson "$gmvmfj_parameter_2" "impactedSourceValue")" || {
            outputToLogFile "ERROR: \`getMetadataValueMatrixForJson()\` failed to get value for \`impactedSourceValue\` metadata key from JSON value";
            return 1;
        }
    ) & (
        gmvmfj_retirementDateValue="$(getMetadataValueForKeyInJson "$gmvmfj_parameter_2" "retirementDate")" || {
            outputToLogFile "ERROR: \`getMetadataValueMatrixForJson()\` failed to get value for \`retirementDate\` metadata key from JSON value";
            return 1;
        }
    ) & (
        gmvmfj_retirementFeatureNameValue="$(getMetadataValueForKeyInJson "$gmvmfj_parameter_2" "retirementFeatureName")" || {
            outputToLogFile "ERROR: \`getMetadataValueMatrixForJson()\` failed to get value for \`retirementFeatureName\` metadata key from JSON value";
            return 1;
        }
    ) & (
        gmvmfj_serviceValue="$(getMetadataValueForKeyInJson "$gmvmfj_parameter_2" "service")" || {
            outputToLogFile "ERROR: \`getMetadataValueMatrixForJson()\` failed to get value for \`service\` metadata key from JSON value";
            return 1;
        }
    ) & (
        gmvmfj_recommendationResourceTypeValue="$(getMetadataValueForKeyInJson "$gmvmfj_parameter_2" "recommendationResourceType")" || {
            outputToLogFile "ERROR: \`getMetadataValueMatrixForJson()\` failed to get value for \`recommendationResourceType\` metadata key from JSON value";
            return 1;
        }
    ) & (
        gmvmfj_serviceTreeIdValue="$(getMetadataValueForKeyInJson "$gmvmfj_parameter_2" "serviceTreeId")" || {
            outputToLogFile "ERROR: \`getMetadataValueMatrixForJson()\` failed to get value for \`serviceTreeId\` metadata key from JSON value";
            return 1;
        }
    ) & wait

    gmvmfj_metadataValueMatrix="$(encodeMetadataValueMatrix "$gmvmfj_serviceValue" "$gmvmfj_recommendationResourceTypeValue" "$gmvmfj_dataSourceValue" "$gmvmfj_parameter_1" "$gmvmfj_impactedSourceValue" "$gmvmfj_retirementDateValue" "$gmvmfj_retirementFeatureNameValue" "$gmvmfj_serviceTreeIdValue")" || {
        outputToLogFile "ERROR: \`getMetadataValueMatrixForJson()\` failed to encode metadataValueMatrix from JSON value";
        return 1;
    }

    printf "%s" "$gmvmfj_metadataValueMatrix"

    return 0
}

getFileMetadataValueMatrix() {
    # decode key is service^^recommendationResourceType^^datasource^^filePath^^impactedSourceValue^^^retirementDate^^retirementFeatureName^^serviceTreeId^^
    # string file gfmvm_parameter_1

    outputFunctionToLogFile "getFileMetadataValueMatrix" "$1"
    requireFileParameterExists "getFileMetadataValueMatrix" "file" "$1" || return 1

    local gfmvm_parameter_1="$1"

    local gfmvm_fileMetadataValueMatrixTemp
    local gfmvm_jsonInput
    local gfmvm_metadataValueMatrixTemp

    if ! gfmvm_jsonInput="$(<"$gfmvm_parameter_1")"; then
        outputToLogFile "ERROR: \`getFileMetadataValueMatrix()\` failed to read \`$gfmvm_parameter_1\` file"
        return 1
    fi

    if ! gfmvm_metadataValueMatrixTemp="$(getMetadataValueMatrixForJson "$gfmvm_parameter_1" "$gfmvm_jsonInput")"; then
        outputToLogFile "ERROR: \`getFileMetadataValueMatrix()\` failed to create metadataValueMatrix from \`$gfmvm_parameter_1\` file"
        return 1
    fi

    if [[ -z "$gfmvm_metadataValueMatrixTemp" || "$gfmvm_metadataValueMatrixTemp" == "nomatch" ]]; then
        outputToLogFile "ERROR: \`getFileMetadataValueMatrix()\` metadataValueMatrix is empty or not valid for \`$gfmvm_parameter_1\` file"
        return 1
    fi

    outputToLogFile "DEBUG: \`getFileMetadataValueMatrix()\` \`$gfmvm_parameter_1\` file has \`$gfmvm_metadataValueMatrixTemp\` fileMetadataValueMatrix value"

    printf "%s" "$gfmvm_metadataValueMatrixTemp"

    return 0
}

# file system filter

verifyPublicNameMarkdownFile() {
    # string file vpnmf_parameter_1

    outputFunctionToLogFile "verifyPublicNameMarkdownFile" "$1"
    requireFileParameterExists "verifyPublicNameMarkdownFile" "file" "$1" || return 1

    local vpnmf_parameter_1="$1"

    local vpnmf_fileShortNameTemp
    local vpnmf_fileSuffixLower

    vpnmf_fileShortNameTemp="$(getShortNameForFile "$vpnmf_parameter_1")" || {
        outputToLogFile "ERROR: \`verifyPublicNameMarkdownFile()\` failed to get short name for \`$vpnmf_parameter_1\` file";
        return 1;
    }

    vpnmf_fileSuffixLower="$(toLowerString "${vpnmf_fileShortNameTemp##*[-_]}")"

    if [[ "$vpnmf_fileSuffixLower" == "public" ]]; then
        outputToLogFile "\`verifyPublicNameMarkdownFile\` \`$vpnmf_fileShortNameTemp\` ends with public"
        return 0
    fi

    for vpnmf_cloudTemp in "${cloudarray[@]}"; do
        [[ "$vpnmf_cloudTemp" == "public" ]] && continue

        if [[ "$vpnmf_fileSuffixLower" == "$vpnmf_cloudTemp" ]]; then
            outputToLogFile "ERROR: \`verifyPublicNameMarkdownFile\` \`$vpnmf_fileShortNameTemp\` ends with a non-public \`$vpnmf_fileSuffixLower\` cloud suffix"
            return 1
        fi
    done

    outputToLogFile "\`verifyPublicNameMarkdownFile\` \`$vpnmf_fileShortNameTemp\` does not end with a listed cloud suffix"

    return 0
}

verifyRequiredMetadataKeysExist() {
    # string file vrmke_parameter_1

    outputFunctionToLogFile "verifyRequiredMetadataKeysExist" "$1"

    requireFileParameterExists "verifyRequiredMetadataKeysExist" "file" "$1" || return 1

    local vrmke_parameter_1="$1"

    local vrmke_jsonInput
    local vrmke_metadataValue

    if ! vrmke_jsonInput="$(<"$vrmke_parameter_1")"; then
        outputToLogFile "ERROR: \`verifyRequiredMetadataKeysExist()\` failed to read \`$vrmke_parameter_1\` file"
        return 1
    fi

    for vrmke_metadataKey in "${metadatarequiredarray[@]}"; do
        vrmke_metadataValue="$(getMetadataValueForKeyInJson "$vrmke_jsonInput" "$vrmke_metadataKey")" || {
            outputToLogFile "ERROR: \`verifyRequiredMetadataKeysExist()\` missing \`$vrmke_metadataKey\` in \`$vrmke_parameter_1\`"
            return 1
        }

        if [[ -z "$vrmke_metadataValue" || "$vrmke_metadataValue" == "nomatch" || "$vrmke_metadataValue" == "MISSING" ]]; then
            outputToLogFile "ERROR: \`verifyRequiredMetadataKeysExist()\` missing or invalid \`$vrmke_metadataKey\` in \`$vrmke_parameter_1\`"
            return 1
        fi

        case "$vrmke_metadataKey" in
            recommendationScope)
                [[ "$(toLowerString "$vrmke_metadataValue")" == "public" ]] || {
                    outputToLogFile "ERROR: \`verifyRequiredMetadataKeysExist()\` skipping non-public \`$vrmke_metadataKey\` (\`$vrmke_metadataValue\`) in \`$vrmke_parameter_1\` file";
                    return 1;
                }
                ;;
            recommendationMetadataState)
                [[ "$(toLowerString "$vrmke_metadataValue")" == "active" ]] || {
                    outputToLogFile "ERROR: \`verifyRequiredMetadataKeysExist()\` skipping non-active \`$vrmke_metadataKey\` (\`$vrmke_metadataValue\`) in \`$vrmke_parameter_1\` file";
                    return 1;
                }
                ;;
            recommendationSubCategory|retirementDate|service|serviceTreeId|retirementFeatureName)
                [[ -n "$vrmke_metadataValue" && "$vrmke_metadataValue" != "MISSING" ]] || {
                    outputToLogFile "ERROR: \`verifyRequiredMetadataKeysExist()\` missing \`$vrmke_metadataKey\` metadata key in \`$vrmke_parameter_1\` file";
                    return 1;
                }
                ;;
        esac
    done

    return 0
}

# file system

searchFile() {
    # string file sf_parameter_1

    outputFunctionToLogFile "searchFile" "$1"
    requireFileParameterExists "searchFile" "file" "$1" || return 1

    local sf_parameter_1="$1"

    local sf_fileMetadataMatrix

    if sf_fileMetadataMatrix="$(getFileMetadataValueMatrix "$sf_parameter_1")" && [[ -n "$sf_fileMetadataMatrix" ]]; then
        addValuesToMultipleArrays "$sf_fileMetadataMatrix" || {
            outputToLogFile "ERROR: \`searchFile()\` failed to add values for \`$sf_parameter_1\` file";
            return 1;
        }
    else
        outputToLogFile "ERROR: \`searchFile()\` failed to get valid fileMetadataMatrix for \`$sf_parameter_1\` file"
        return 1
    fi

    return 0
}

searchDirectoryHasValidDescendant() {
    # string directory sdhvd_parameter_1

    outputFunctionToLogFile "searchDirectoryHasValidDescendant" "$1"

    requireDirectoryParameterExists "searchDirectoryHasValidDescendant" "directory" "$1" || return 1

    local sdhvd_parameter_1="$1"

    local sdhvd_baseNameTemp
    local sdhvd_entry
    local sdhvd_fileExtensionTemp

    for sdhvd_entry in "$sdhvd_parameter_1"/* "$sdhvd_parameter_1"/.*; do
        showProgress

        [[ -e "$sdhvd_entry" ]] || continue

        sdhvd_baseNameTemp=""

        sdhvd_baseNameTemp="$(basename -- "$sdhvd_entry")"

        [[ "$sdhvd_baseNameTemp" == "." || "$sdhvd_baseNameTemp" == ".." ]] && continue

        if [[ -f "$sdhvd_entry" ]]; then
            sdhvd_fileExtensionTemp="$(getFileExtensionForFile "$sdhvd_entry")" || continue

            [[ "$sdhvd_fileExtensionTemp" == "${coverageofservicessectionarray[8]}" ]] || continue

            if verifyPublicNameMarkdownFile "$sdhvd_entry"; then
                return 0
            fi
        elif [[ -d "$sdhvd_entry" ]]; then
            searchDirectoryHasValidDescendant "$sdhvd_entry" && return 0
        fi
    done

    return 1
}

searchDirectory() {
    # string directory sd_parameter_1

    outputFunctionToLogFile "searchDirectory" "$1"

    requireDirectoryParameterExists "searchDirectory" "directory" "$1" || return 1

    local sd_parameter_1="$1"

    local sd_baseNameTemp
    local sd_childTemp
    local sd_fileExtensionTemp

    local sd_current
    local sd_maximumJobs
    local sd_runningJobs
    local sd_total

    declare -a sd_childrenArray=()
    declare -a sd_processIdentifiers=()
    declare -a sd_validChildrenArray=()

    outputToConsole "searchDirectory() \`$(trimPathForDisplay "$sd_parameter_1")\` is a directory"

    for sd_entry in "$sd_parameter_1"/* "$sd_parameter_1"/.*; do
        showProgress

        [[ -e "$sd_entry" ]] || continue

        sd_baseNameTemp="$(basename -- "$sd_entry")"

        [[ "$sd_baseNameTemp" == "." || "$sd_baseNameTemp" == ".." ]] && continue

        if [[ -f "$sd_entry" || -d "$sd_entry" ]]; then
            sd_childrenArray+=( "$sd_entry" )
        fi
    done

    for sd_childTemp in "${sd_childrenArray[@]}"; do
        showProgress

        if [[ -f "$sd_childTemp" ]]; then
            sd_fileExtensionTemp="$(getFileExtensionForFile "$sd_childTemp")" || continue

            [[ "$sd_fileExtensionTemp" == "${coverageofservicessectionarray[8]}" ]] || continue

            if verifyPublicNameMarkdownFile "$sd_childTemp"; then
                sd_validChildrenArray+=( "$sd_childTemp" )
            fi
        elif [[ -d "$sd_childTemp" ]]; then
            if searchDirectoryHasValidDescendant "$sd_childTemp"; then
                sd_validChildrenArray+=( "$sd_childTemp" )
            fi
        fi
    done

    sd_total=${#sd_validChildrenArray[@]}
    sd_current=0

    if (( sd_total == 0 )); then
        outputToLogFile "INFO: \`searchDirectory()\` skipping \`$sd_parameter_1\`; no valid descendants matching \`verifyPublicNameMarkdownFile()\` and markdown extension"
        return 0
    fi

    sd_maximumJobs=4 # set maximum concurrent jobs to 4
    sd_runningJobs=0

    for sd_childTemp in "${sd_validChildrenArray[@]}"; do
        showProgress

        ((sd_current++))

        # showProgressBar "$sd_current" "$sd_total"

        [[ -e "$sd_childTemp" ]] || continue

        if [[ -d "$sd_childTemp" ]]; then
            searchDirectory "$sd_childTemp" & sd_processIdentifiers+=( $! )

            ((sd_runningJobs++))
        elif [[ -f "$sd_childTemp" ]]; then
            (
                sd_fileExtensionTemp="$(getFileExtensionForFile "$sd_childTemp")" || {
                    outputToLogFile "ERROR: \`searchDirectory()\` failed to get file extension for \`$sd_childTemp\` file";
                    exit 0;
                }

                [[ "$sd_fileExtensionTemp" == "${coverageofservicessectionarray[8]}" ]] || exit 0

                if verifyPublicNameMarkdownFile "$sd_childTemp" && verifyRequiredMetadataKeysExist "$sd_childTemp"; then
                    searchFile "$sd_childTemp" || {
                        outputToLogFile "ERROR: \`searchDirectory()\` failed to search \`$sd_childTemp\` file";
                        exit 0;
                    }
                fi
            ) & sd_processIdentifiers+=( $! )

            ((sd_runningJobs++))
        fi

        if (( sd_runningJobs >= sd_maximumJobs )); then
            wait -n

            ((sd_runningJobs--))
        fi
    done

    wait

    printf "\n"

    return 0
}

# search from file list

searchLinesFromListFile() {
    # string file slflf_parameter_1

    outputFunctionToLogFile "searchLinesFromListFile" "$1"

    requireFileParameterExists "searchLinesFromListFile" "file" "$1" || return 1

    local slflf_parameter_1="$1"

    local slflf_current
    local slflf_searchLines
    local slflf_total

    declare -a slflf_linesArray=()

    slflf_current=0
    slflf_total=0

    setLocalArrayFromFunction "slflf_linesArray" "$slflf_parameter_1" || {
        outputToLogFile "ERROR: \`searchLinesFromListFile()\` failed to read content from \`$slflf_parameter_1\` file";
        return 1;
    }

    slflf_total=${#slflf_linesArray[@]}

    for slflf_searchLineTemp in "${slflf_linesArray[@]}"; do
        ((slflf_current++))

        showProgressBar "$slflf_current" "$slflf_total"

        [[ -d "$slflf_searchLineTemp" ]] || {
            outputToLogFile "ERROR: \`searchLinesFromListFile()\` \`$slflf_searchLineTemp\` is not a valid directory";
            continue;
        }

        searchDirectory "$slflf_searchLineTemp" || {
            outputToLogFile "ERROR: \`main()\` failed to search \`$slflf_searchLineTemp\` directory";
            continue;
        }
    done

    printf "\n"

    return 0
}

searchDirectoryFromFile() {
    # ----

    outputFunctionToLogFile "searchDirectoryFromFile"

    verifyFileExists "$inputDirectoryDirectoryOutputTxt" || {
        outputToLogFile "ERROR: \`searchDirectoryFromFile()\` failed to find \`$inputDirectoryDirectoryOutputTxt\` file";

        return 1;
    }

    outputToConsole "Search list of directories from \`$(trimPathForDisplay "$inputDirectoryDirectoryOutputTxt")\` file"

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
        outputToConsole "Search all directories";

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

    local avta_found
    local avta_safeArrayName

    avta_safeArrayName="$(getSafeNameForArray "$avta_parameter_1")" || avta_safeArrayName="$avta_parameter_1"

    if ! declare -p "$avta_safeArrayName" 2>/dev/null | grep -q 'declare \-[aA]'; then
        eval "declare -g -a $avta_safeArrayName=()" || {
            outputToLogFile "ERROR: \`addValueToArray()\` failed to declare array \`$avta_safeArrayName\`";
            return 1;
        }
    fi

    if [[ -n "$avta_parameter_2" ]]; then
        declare -n avta_arrayTemp="$avta_safeArrayName"

        avta_found=0

        for item in "${avta_arrayTemp[@]}"; do
            [[ "$item" == "$avta_parameter_2" ]] && {
                avta_found=1;
                break;
            }
        done

        if (( avta_found == 0 )); then
            avta_arrayTemp+=( "$avta_parameter_2" )

            outputToLogFile "DEBUG: \`addValueToArray()\` added value \`$avta_parameter_2\` to \`$avta_safeArrayName\` array"
        else
            outputToLogFile "DEBUG: \`addValueToArray()\` \`$avta_parameter_2\` value already exists in \`$avta_safeArrayName\` array"
        fi

        if ((${#avta_arrayTemp[@]} > 1)); then
            declare -a avta_sortedarray=()

            mapfile -t avta_sortedarray < <(printf "%s\n" "${avta_arrayTemp[@]}" | sort -u)

            avta_arrayTemp=("${avta_sortedarray[@]}")

            outputToLogFile "DEBUG: \`addValueToArray()\` deduplicated and sorted \`$avta_safeArrayName\` array"
        fi
    fi

    return 0
}

addValuesToMultipleArrays() {
    # string fileMetadataMatrix value avtma_parameter_1

    outputFunctionToLogFile "addValuesToMultipleArrays" "$1"

    requireParameterForFunction "addValuesToMultipleArrays" "fileMetadataMatrix value" "$1" || return 1

    local avtma_parameter_1="$1"

    local avtma_filePath
    local avtma_directoryPath

    # decode key is service^^recommendationResourceType^^datasource^^filePath^^impactedSourceValue^^^retirementDate^^retirementFeatureName^^serviceTreeId^^

    avtma_filePath="$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "filePath")" || return 1

    [[ -f "$avtma_filePath" ]] || {
        outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to locate \`$avtma_filePath\` file";
        return 1;
    }

    avtma_directoryPath="$(getPathForFile "$avtma_filePath")" || return 1

    [[ -d "$avtma_directoryPath" ]] || {
        outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to locate \`$avtma_directoryPath\` directory";
        return 1;
    }

    (
        addValueToArray "directoryarray" "$avtma_directoryPath" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`$avtma_directoryPath\` to \`directoryarray\`";
            return 1;
        }

        addValueToArray "arraynamearray" "directoryarray" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`directoryarray\` to \`arraynamearray\`";
            return 1;
        }
    ) & (
        addValueToArray "metadatavaluearray" "$avtma_parameter_1" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`$avtma_parameter_1\` to \`metadatavaluearray\`";
            return 1;
        }

        addValueToArray "arraynamearray" "metadatavaluearray" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`metadatavaluearray\` to \`arraynamearray\`";
            return 1;
        }
    ) & (
        addValueToArray "impactedsourcevaluearray" "$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "impactedSourceValue")" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "impactedSourceValue")\` to \`impactedsourcevaluearray\`";
            return 1;
        }

        addValueToArray "arraynamearray" "impactedsourcevaluearray" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`impactedsourcevaluearray\` to \`arraynamearray\`";
            return 1;
        }
    ) & (
        addValueToArray "servicetreeidarray" "$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "serviceTreeId")" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "serviceTreeId")\` to \`servicetreeidarray\`";
            return 1;
        }

        addValueToArray "arraynamearray" "servicetreeidarray" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`servicetreeidarray\` to \`arraynamearray\`";
            return 1;
        }
    ) & (
        addValueToArray "retirementdatearray" "$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "retirementDate")" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "retirementDate")\` to \`retirementdatearray\`";
            return 1;
        }

        addValueToArray "arraynamearray" "retirementdatearray" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`retirementdatearray\` to \`arraynamearray\`";
            return 1;
        }
    ) & (
        addValueToArray "retirementfeaturearray" "$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "retirementFeatureName")" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "retirementFeatureName")\` to \`retirementfeaturearray\`";
            return 1;
        }

        addValueToArray "arraynamearray" "retirementfeaturearray" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`retirementfeaturearray\` to \`arraynamearray\`";
            return 1;
        }
    ) & (
        addValueToArray "datasourcearray" "$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "dataSource")" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "dataSource")\` to \`datasourcearray\`";
            return 1;
        }

        addValueToArray "arraynamearray" "datasourcearray" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`datasourcearray\` to \`arraynamearray\`";
            return 1;
        }
    ) & (
        addValueToArray "servicearray" "$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "service")" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "service")\` to \`servicearray\`";
            return 1;
        }

        addValueToArray "arraynamearray" "servicearray" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`servicearray\` to \`arraynamearray\`";
            return 1;
        }
    ) & (
        addValueToArray "servicearray" "$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "service")" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "service")\` to \`servicearray\`";
            return 1;
        }

        addValueToArray "arraynamearray" "servicearray" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`servicearray\` to \`arraynamearray\`";
            return 1;
        }
    ) & (
        addValueToArray "recommendationResourceType" "$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "recommendationResourceType")" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`$(decodeMetadataValueMatrixForKey "$avtma_parameter_1" "recommendationResourceType")\` to \`recommendationResourceType\`";
            return 1;
        }

        addValueToArray "arraynamearray" "recommendationResourceType" || {
            outputToLogFile "ERROR: \`addValuesToMultipleArrays()\` failed to add \`recommendationResourceType\` to \`arraynamearray\`";
            return 1;
        }
    ) & wait

    return 0
}

# retrieve array

getArrayByName() {
    # string name of array gabn_parameter_1

    requireArrayParameterExists "getArrayByName" "name of array" "$1" || return 1

    local gabn_parameter_1="$1"

    if [[ -z "$gabn_parameter_1" ]]; then
        outputToLogFile "ERROR: \`getArrayByName()\` name of array is empty"
        return 1
    fi

    if ! declare -p "$gabn_parameter_1" 2>/dev/null | grep -q 'declare \-[aA]'; then
        outputToLogFile "ERROR: \`getArrayByName()\` \`$gabn_parameter_1\` is not a valid array"
        return 1
    fi

    declare -n gabn_array="$gabn_parameter_1"

    printf "%s\n" "${gabn_array[@]}"

    return 0
}

setLocalArrayFromArrayName() {
    # string name of destination array slafan_parameter_1
    # string name of source array slafan_parameter_2

    outputFunctionToLogFile "setLocalArrayFromArrayName" "$1" "$2"

    requireParameterForFunction "setLocalArrayFromArrayName" "name of destination array" "$1" || return 1
    requireArrayParameterExists "setLocalArrayFromArrayName" "name of source array" "$2" || return 1

    local slafan_parameter_1="$1"
    local slafan_parameter_2="$2"

    if ! declare -p "$slafan_parameter_1" 2>/dev/null | grep -q 'declare \-[aA]'; then
        eval "declare -g -a $slafan_parameter_1=()"
    fi

    local -n slafan_destinationarray="$slafan_parameter_1"

    slafan_destinationarray=()

    local -n slafan_sourcearray="$slafan_parameter_2"

    slafan_destinationarray+=( "${slafan_sourcearray[@]}" )

    return 0
}

setLocalArrayFromFunction() {
    # string name of array slaff_parameter_1
    # string function slaff_parameter_2

    outputFunctionToLogFile "setLocalArrayFromFunction" "$1" "$2"

    requireParameterForFunction "setLocalArrayFromFunction" "name of destination array" "$1" || return 1
    requireParameterForFunction "setLocalArrayFromFunction" "function" "$2" || return 1

    local slaff_parameter_1="$1"
    local slaff_parameter_2="$2"

    if ! declare -p "$slaff_parameter_1" 2>/dev/null | grep -q 'declare \-[aA]'; then
        eval "declare -g -a $slaff_parameter_1=()"
    fi

    local -n destinationArrayReference="$slaff_parameter_1"

    destinationArrayReference=()

    mapfile -t destinationArrayReference < <("$slaff_parameter_2") || {
        outputToLogFile "ERROR: \`setLocalArrayFromFunction()\` failed to set \`$slaff_parameter_1\` array from function";
        return 1;
    }

    return 0
}

# create summary file

loopAllActiveArrays() {
    # ----

    outputFunctionToLogFile "loopAllActiveArrays"

    verifyArrayExists "arraynamearray" || return 1

    outputToConsole "\`loopAllActiveArrays()\` Loop through all active arrays"

    declare -a laaa_arraynamearray=()
    declare -a laaa_arrayitemsarray=()

    setLocalArrayFromArrayName "laaa_arraynamearray" "arraynamearray" || {
        outputToLogFile "ERROR: \`loopAllActiveArrays()\` failed to set \`laaa_arraynamearray\` from \`arraynamearray\`";
        return 1;
    }

    outputToRawNamedFile "final.arraynamearray" "txt" "$(printf "%s\n" "${laaa_arraynamearray[@]}")" || {
        outputToLogFile "ERROR: \`loopAllActiveArrays()\` failed to create \`final.arraynamearray.txt\`";
        return 1;
    }

    local laaa_total=${#laaa_arraynamearray[@]}
    local laaa_current=0

    for laaa_arraynametemp in "${laaa_arraynamearray[@]}"; do
        ((laaa_current++))

        showProgressBar "$laaa_current" "$laaa_total"

        outputToLogFile "DEBUG: \`loopAllActiveArrays()\` entry \`$laaa_arraynametemp\` array name from \`arraynamearray\`"

        laaa_arrayitemsarray=()

        setLocalArrayFromArrayName "laaa_arrayitemsarray" "$laaa_arraynametemp" || {
            outputToLogFile "ERROR: \`loopAllActiveArrays()\` failed to set \`laaa_arrayitemsarray\` from \`$laaa_arraynametemp\`";
            continue;
        }

        if (( ${#laaa_arrayitemsarray[@]} > 0 )); then
            outputToRawNamedFile "final.$laaa_arraynametemp" "txt" "$(printf "%s\n" "${laaa_arrayitemsarray[@]}")" || {
                outputToLogFile "ERROR: \`loopAllActiveArrays()\` failed to create \`final.$laaa_arraynametemp.txt\`";
                continue;
            }
        fi
    done

    printf "\n"

    return 0
}

# get include content

getMetadataForIncludeOutput() {
    # ----

    outputToLogFile "\`getMetadataForIncludeOutput()\`"

    local gmfio_output

    gmfio_output=$(
        printf "%s\n" "${progressArray[6]}"
        printf "%s\n" "${includefrontmatterarray[0]}"
        printf "%s\n" "${includefrontmatterarray[1]}"
        printf "%s\n\n" "${includefrontmatterarray[2]}"
        printf "%s" "${progressArray[6]}"
    ) || {
        outputToLogFile "ERROR: \`getMetadataForIncludeOutput()\` failed to create include metadata value";
        return 1;
    }

    printf "%s" "$gmfio_output"

    return 0
}

createTableHeaderForIncludeSection() {
    # ----

    outputToLogFile "\`createTableHeaderForIncludeSection()\`"

    local cthfis_tableHeaderRow

    cthfis_tableHeaderRow=$(
        printf "%s\n" "${sectiontablearray[0]}"
        printf "%s\n" "${sectiontablearray[1]}"
        printf "%s\n" "${sectiontablearray[2]}"
    ) || {
        outputToLogFile "ERROR: \`createTableHeaderForIncludeSection()\` failed to create table header row value";
        return 1;
    }

    printf "%s" "$cthfis_tableHeaderRow"

    return 0
}

getYearMonthInclude() {
    outputFunctionToLogFile "getYearMonthInclude"

    verifyArrayExists "metadatavaluearray" || {
        outputToLogFile "ERROR: \`getYearMonthInclude()\` failed to find \`metadatavaluearray\` array";
        return 1;
    }

    verifyArrayExists "retirementdatearray" || {
        outputToLogFile "ERROR: \`getYearMonthInclude()\` failed to find \`retirementdatearray\` array";
        return 1;
    }

    local gymi_addtoincludearray
    local gymi_currentYearMonth
    local gymi_impactedSourceTemp
    local gymi_includeFileOutput
    local gymi_includeMetadata
    local gymi_metadataMatrixTemp
    local gymi_monthStringDayYearTemp
    local gymi_previousRow
    local gymi_recommendationResourceTemp
    local gymi_retirementDatetemp
    local gymi_retirementYearMonthTemp
    local gymi_retiringFeatureTemp
    local gymi_rowTemp
    local gymi_sectionRows
    local gymi_sectionContent
    local gymi_sectionTable
    local gymi_serviceTemp
    local gymi_tableHeaderRow
    local gymi_yearMonthDayHeading
    local gymi_yearMonthDayPrevious
    local gymi_yearMonthDayTemp
    local gymi_yearMonthPrevious
    local gymi_yearMonthTemp

    declare -a gymi_metadatavaluearray=()
    declare -a gymi_retirementdatearray=()

    setLocalArrayFromArrayName "gymi_metadatavaluearray" "metadatavaluearray" || {
        outputToLogFile "ERROR: \`getYearMonthInclude()\` failed to set local \`gymi_metadatavaluearray\` array from \`metadatavaluearray\` array";
        return 1;
    }

    setLocalArrayFromArrayName "gymi_retirementdatearray" "retirementdatearray" || {
        outputToLogFile "ERROR: \`getYearMonthInclude()\` failed to set local \`gymi_retirementdatearray\` array from \`retirementdatearray\` array";
        return 1;
    }

    gymi_currentYearMonth=""
    gymi_sectionContent=""
    gymi_yearMonthDayPrevious=""
    gymi_yearMonthPrevious=""

    gymi_includeMetadata="$(getMetadataForIncludeOutput)" || {
        outputToLogFile "ERROR: \`getYearMonthInclude()\` failed to create include metadata value";
        return 1;
    }

    [[ -n "$gymi_includeMetadata" ]] || {
        outputToLogFile "ERROR: \`getYearMonthInclude()\` include metadata value is empty";
        return 1;
    }

    gymi_tableHeaderRow="$(createTableHeaderForIncludeSection)" || {
        outputToLogFile "ERROR: \`getYearMonthInclude()\` failed to create table header row for include section";
        return 1;
    }

    for gymi_yearMonthDayTemp in "${gymi_retirementdatearray[@]}"; do
        gymi_sectionTable=""

        gymi_yearMonthTemp="$(getYearMonthFromYearMonthDay "$gymi_yearMonthDayTemp")" || continue

        if [[ "$gymi_yearMonthTemp" != "$gymi_currentYearMonth" && -n "$gymi_sectionContent" ]]; then
            gymi_includeFileOutput="$(printf "%s/%s-%s.%s" "$retiringFeatureDirectory" "retirement-date" "$gymi_currentYearMonth" "${coverageofservicessectionarray[8]}")"

            printf "%s\n%s\n" "$gymi_includeMetadata" "$gymi_sectionContent" > "$gymi_includeFileOutput"

            gymi_sectionContent=""
        fi

        gymi_monthStringDayYearTemp="$(getMonthDayYearStringFromYearMonthDay "$gymi_yearMonthDayTemp")" || continue

        gymi_yearMonthDayHeading="$(printf "%s%s" "${headingarray[4]}" "$gymi_monthStringDayYearTemp")"

        gymi_sectionTable="$gymi_yearMonthDayHeading"$'\n\n'"$gymi_tableHeaderRow"

        gymi_previousRow=""

        for gymi_metadataMatrixTemp in "${gymi_metadatavaluearray[@]}"; do
            gymi_retirementDatetemp="$(decodeMetadataValueMatrixForKey "$gymi_metadataMatrixTemp" "retirementDate")" || continue

            [[ "$gymi_retirementDatetemp" == "$gymi_yearMonthDayTemp" ]] || continue

            (
                gymi_impactedSourceTemp="$(decodeMetadataValueMatrixForKey "$gymi_metadataMatrixTemp" "impactedSourceValue")" || continue
            ) & (
                gymi_recommendationResourceTemp="$(decodeMetadataValueMatrixForKey "$gymi_metadataMatrixTemp" "recommendationResourceType")" || continue
                ) & (
                gymi_retiringFeatureTemp="$(decodeMetadataValueMatrixForKey "$gymi_metadataMatrixTemp" "retirementFeatureName")" || continue
            ) & (
                gymi_serviceTemp="$(decodeMetadataValueMatrixForKey "$gymi_metadataMatrixTemp" "service")" || continue
            ) & wait

            gymi_rowTemp="$(printf "> | %s (%s) | %s | %s |" "$gymi_serviceTemp" "$gymi_recommendationResourceTemp" "$gymi_retiringFeatureTemp" "$gymi_impactedSourceTemp")"

            if [[ "$gymi_previousRow" != "$gymi_rowTemp" ]]; then
                gymi_sectionTable+=$'\n'"$gymi_rowTemp"

                gymi_previousRow="$gymi_rowTemp"
            fi
        done

        if [[ "$gymi_sectionTable" != "$gymi_yearMonthDayHeading"$'\n\n'"$gymi_tableHeaderRow" ]]; then
            gymi_sectionContent+=$'\n\n'"$gymi_sectionTable"
        fi

        gymi_currentYearMonth="$gymi_yearMonthTemp"
    done

    if [[ -n "$gymi_sectionContent" && -n "$gymi_currentYearMonth" ]]; then
        gymi_includeFileOutput="$(printf "%s/%s-%s.%s" "$retiringFeatureDirectory" "retirement-date" "$gymi_currentYearMonth" "${coverageofservicessectionarray[8]}")"

        printf "%s\n%s\n" "$gymi_includeMetadata" "$gymi_sectionContent" > "$gymi_includeFileOutput"
    fi

    return 0
}

# coverage of services output

getCoverageOfServicesSectionOutput() {
    # ----

    outputFunctionToLogFile "getCoverageOfServicesSectionOutput"

    verifyArrayExists "retirementdatearray" || {
        outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to find \`retirementdatearray\` array";
        return 1;
    }

    local gcosso_yearMonthDayPrevious
    local gcosso_yearMonthPrevious
    local gcosso_yearPrevious
    local gcosso_monthStringDayYearTemp
    local gcosso_yearTemp

    declare -a gcosso_addtosectionarray=()

    setLocalArrayFromArrayName "gcosso_retirementdatearray" "retirementdatearray" || {
        outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to set local \`gcosso_retirementdatearray\` array from \`retirementdatearray\` array";
        return 1;
    }

    gcosso_yearMonthDayPrevious=""
    gcosso_yearMonthPrevious=""
    gcosso_yearPrevious=""

    gcosso_cosheading="$(
        printf "%s%s\n\n" "${headingarray[1]}" "${coverageofservicessectionarray[0]}"
        printf "%s\n\n" "${coverageofservicessectionarray[1]}"
        printf "%s" "${coverageofservicessectionarray[2]}"
    )" || {
        outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to create coverage of services heading";
        return 1;
    }

    gcosso_cosFooter="$(
        printf "%s%s\n\n" "${progressArray[6]}"
        printf "%s%s" "${headingarray[1]}" "${coverageofservicessectionarray[9]}"
    )" || {
        outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to create coverage of services heading";
        return 1;
    }

    gcosso_addtosectionarray=( "$gcosso_cosheading" ) || {
        outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to add coverage of services heading to \`addtosectionarray\`";
        return 1;
    }

    for gcosso_yearMonthDayTemp in "${gcosso_retirementdatearray[@]}"; do

        IFS='-' read -r gcosso_year gcosso_month gcosso_day <<< "$gcosso_yearMonthDayTemp" || {
            outputToLogFile "ERROR: \`getMonthDayYearStringFromYearMonthDay()\` failed to split gcosso_yearMonthDayTemp: $gcosso_yearMonthDayTemp";
            continue;
        }

        [[ -n "$gcosso_yearMonthDayTemp" ]] || continue

        gcosso_monthStringDayYearTemp="$(getMonthDayYearStringFromYearMonthDay "$gcosso_yearMonthDayTemp")" || {
            outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to get month day year string from \`$gcosso_yearMonthDayTemp\` value";
            continue;
        }

        gcosso_yearMonthTemp="$(getYearMonthFromYearMonthDay "$gcosso_yearMonthDayTemp")" || {
            outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to get year month from \`$gcosso_yearMonthDayTemp\` value";
            continue;
        }

        [[ -n "$gcosso_yearMonthTemp" ]] || continue

        gcosso_monthStringTemp="$(getMonthStringFromMonth "$gcosso_month")" || {
            outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to get month string from \`$gcosso_month\` value";
            continue;
        }

        [[ -n "$gcosso_monthStringTemp" ]] || {
            outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` month string from \`$gcosso_yearMonthDayTemp\` value is empty";
            continue;
        }

        gcosso_yearTemp="$(getYearFromMonthDayYear "$gcosso_yearMonthDayTemp")" || {
            outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to get year from \`$gcosso_yearMonthDayTemp\` value";
            continue;
        }
        
        [[ -n "$gcosso_yearTemp" ]] || continue
        
        gcosso_yearSectionHeading=$(printf "%s[%s %s](#%s-%s)" "${headingarray[2]}" "${coverageofservicessectionarray[3]}" "$gcosso_yearTemp" "${coverageofservicessectionarray[4]}" "$gcosso_yearTemp") || {
            outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to create section heading for \`$gcosso_yearTemp\` year";
            continue;
        }

        gcosso_yearMonthSectionHeading=$(printf "%s%s %s %s" "${headingarray[3]}" "${coverageofservicessectionarray[5]}" "$gcosso_monthStringTemp" "$gcosso_yearTemp") || {
            outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to create month year section heading for \`$gcosso_yearTemp\` year";
            continue;
        }

        gcosso_yearMonthSection=$(printf "[%s %s %s](%s-%s.%s)]" "${coverageofservicessectionarray[6]}" "$gcosso_monthStringTemp" "$gcosso_yearTemp" "${coverageofservicessectionarray[7]}" "$gcosso_yearMonthTemp" "${coverageofservicessectionarray[8]}") || {
            outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to create year month section for \`$gcosso_yearTemp\` year";
            continue;
        }

        if [[ "$gcosso_yearTemp" != "$gcosso_yearPrevious" ]]; then
            gcosso_addtosectionarray+=( "$gcosso_yearSectionHeading" ) || {
                outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to add year section heading to \`addtosectionarray\`";
                continue;
            }
        fi

        if [[ "$gcosso_yearMonthTemp" != "$gcosso_yearMonthPrevious" ]]; then
            gcosso_addtosectionarray+=( "$gcosso_yearMonthSectionHeading" "$gcosso_yearMonthSection" ) || {
                outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to add year month section to \`addtosectionarray\`";
                continue;
            }
        fi

        gcosso_yearMonthDayPrevious="$gcosso_yearMonthDayTemp"
        gcosso_yearMonthPrevious="$gcosso_yearMonthTemp"
        gcosso_yearPrevious="$gcosso_yearTemp"
    done

    gcosso_addtosectionarray+=( "$gcosso_cosFooter" ) || {
        outputToLogFile "ERROR: \`getCoverageOfServicesSectionOutput()\` failed to add coverage of services footer to \`addtosectionarray\`";
        return 1;
    }

    printf "%s\n\n" "${gcosso_addtosectionarray[@]}"

    return 0
}

getLatestSectionsFromCoverageOfServicesFile() {
    # ----

    outputFunctionToLogFile "getCoverageOfServicesSection"

    verifyFileExists "$(printf "%s/%s.%s" "$learnAdvisorDirectory" "advisor-how-to-use-service-upgrade-retirement-recommendations" "${coverageofservicessectionarray[8]}")" || return 1

    local glsfcosf_inputFilePath
    local glsfcosf_section1
    local glsfcosf_section2
    local glsfcosf_section3
    local glsfcosf_section4
    local glsfcosf_sectionSeparator1
    local glsfcosf_sectionSeparator2
    local glsfcosf_sectionSeparators

    glsfcosf_sectionSeparator1="ms.date: *"
    glsfcosf_sectionSeparator2="${headingarray[1]}${coverageofservicessectionarray[0]}"
    glsfcosf_sectionSeparator3="${headingarray[1]}${coverageofservicessectionarray[9]}"

    glsfcosf_inputFilePath="$(printf "%s/%s.%s" "$learnAdvisorDirectory" "advisor-how-to-use-service-upgrade-retirement-recommendations" "${coverageofservicessectionarray[8]}")" || {
        outputToLogFile "ERROR: \`getLatestSectionsFromCoverageOfServicesFile()\` failed to create \`$glsfcosf_inputFilePath\` input file path";
        return 1;
    }

    glsfcosf_section1="$(sed "/$glsfcosf_sectionSeparator1/ q" "$glsfcosf_inputFilePath" | sed '$d')" || {
        outputToLogFile "ERROR: \`getLatestSectionsFromCoverageOfServicesFile()\` failed to get top content from \`$glsfcosf_inputFilePath\` file";
        return 1;
    }

    glsfcosf_section2="$(sed -n "/$glsfcosf_sectionSeparator1/,\$p" "$glsfcosf_inputFilePath" | sed "1d" | sed "/$glsfcosf_sectionSeparator2/ q" | sed '$d')" || {
        outputToLogFile "ERROR: \`getLatestSectionsFromCoverageOfServicesFile()\` failed to get coverage of services section from \`$glsfcosf_inputFilePath\` file";
        return 1;
    }

    glsfcosf_section3="$(sed -n "/$glsfcosf_sectionSeparator2/,\$p" "$glsfcosf_inputFilePath" | sed "1d" | sed "/$glsfcosf_sectionSeparator3/ q" | sed '$d')" || {
        outputToLogFile "ERROR: \`getLatestSectionsFromCoverageOfServicesFile()\` failed to get coverage of services section from \`$glsfcosf_inputFilePath\` file";
        return 1;
    }

    glsfcosf_section4="$(sed -n "/$glsfcosf_sectionSeparator3/,\$p" "$glsfcosf_inputFilePath" | sed '1d')" || {
        outputToLogFile "ERROR: \`getLatestSectionsFromCoverageOfServicesFile()\` failed to get coverage of services section from \`$glsfcosf_inputFilePath\` file";
        return 1;
    }

    printf "%s^^%s^^%s^^%s^^" "$glsfcosf_section1" "$glsfcosf_section2" "$glsfcosf_section3" "$glsfcosf_section4" || {
        outputToLogFile "ERROR: \`getLatestSectionsFromCoverageOfServicesFile()\` failed to create coverage of services section from \`$glsfcosf_inputFilePath\` file";
        return 1;
    }

    return 0
}

outputNewCoverageOfServicesFile() {
    # string content oncosf_parameter_1

    outputFunctionToLogFile "outputNewCoverageOfServicesFile" "$1"

    requireParameterForFunction "outputNewCoverageOfServicesFile" "content value" "$1" || return 1

    local oncosf_parameter_1="$1"

    local oncosf_outputFile
    local oncosf_dateReplacement
    local oncosf_section1
    local oncosf_section2
    local oncosf_section3
    local oncosf_sourceFile
    local oncosf_sectionReplacement


    outputToConsole "\`outputNewCoverageOfServicesFile()\` Insert coverage of services section"

    oncosf_outputFile="$(printf "%s/%s.%s" "$outputDirectory" "advisor-how-to-use-service-upgrade-retirement-recommendations-temp" "${coverageofservicessectionarray[8]}")" || {
        outputToLogFile "ERROR: \`outputNewCoverageOfServicesFile()\` failed to create \`$oncosf_outputFile\` output file path";
        return 1;
    }

    oncosf_sourceFile="$(getLatestSectionsFromCoverageOfServicesFile)" || {
        outputToLogFile "ERROR: \`outputNewCoverageOfServicesFile()\` failed to get latest coverage of services section";
        return 1;
    }

    (
        oncosf_section1="$(decodeMetadataValueMatrixForIndex "$oncosf_sourceFile" "0")" || {
            outputToLogFile "ERROR: \`outputNewCoverageOfServicesFile()\` failed to get top section from coverage of services section";
            return 1;
        }
    ) & (
        oncosf_section2="$(decodeMetadataValueMatrixForIndex "$oncosf_sourceFile" "1")" || {
            outputToLogFile "ERROR: \`outputNewCoverageOfServicesFile()\` failed to get section 2 from coverage of services section";
            return 1;
        }
    ) & (
        oncosf_section3="$(decodeMetadataValueMatrixForIndex "$oncosf_sourceFile" "2")" || {
            outputToLogFile "ERROR: \`outputNewCoverageOfServicesFile()\` failed to get section 3 from coverage of services section";
            return 1;
        }
    ) & (
        oncosf_section4="$(decodeMetadataValueMatrixForIndex "$oncosf_sourceFile" "3")" || {
            outputToLogFile "ERROR: \`outputNewCoverageOfServicesFile()\` failed to get bottom section from coverage of services section";
            return 1;
        }
    ) & (
        oncosf_dateReplacement=$(printf "%s" "${includefrontmatterarray[2]}") || {
            outputToLogFile "ERROR: \`outputNewCoverageOfServicesFile()\` failed to create date replacement value";
            return 1;
        }
    ) & (
        oncosf_sectionReplacement=$(printf "%s" "$oncosf_parameter_1") || {
            outputToLogFile "ERROR: \`outputNewCoverageOfServicesFile()\` failed to create section replacement value";
            return 1;
        }
    ) & wait

    if [[ "$$oncosf_parameter_1" == "$oncosf_section3" ]]; then
        outputToLogFile "INFO: \`outputNewCoverageOfServicesFile()\` no change to include coverage of services section"
    else
        oncosf_outputContent=$(
            printf "%s\n" "$oncosf_section1"
            printf "%s\n" "$oncosf_dateReplacement"
            printf "%s\n" "$oncosf_section2"
            printf "%s\n" "$oncosf_sectionReplacement"
            printf "%s\n" "$oncosf_section4"
        ) || {
            outputToLogFile "ERROR: \`outputNewCoverageOfServicesFile()\` failed to create output content";
            return 1;
        }

        printf "%s\n" "$oncosf_outputContent" > "$oncosf_outputFile" || {
            outputToLogFile "ERROR: \`outputNewCoverageOfServicesFile()\` failed to write output content to \`$oncosf_outputFile\` file";
            return 1;
        }
    fi

    return 0
}

# add files to learn directory

addFilesToLearnDirectory() {
    # ----

    outputFunctionToLogFile "addFilesToLearnDirectory"

    verifyDirectoryExists "$includesAdvisorLearnRetiringFeatureDirectory" || return 1

    rsync -av --delete "$retiringFeatureDirectory/" "$includesAdvisorLearnRetiringFeatureDirectory/" || {
        outputToLogFile "ERROR: \`addFilesToLearnDirectory()\` failed to sync include files to \`$includesAdvisorLearnRetiringFeatureDirectory\` directory";
        return 1;
    }

    rsync -avz "$outputDirectory/advisor-how-to-use-service-upgrade-retirement-recommendations-temp.md" "$learnAdvisorDirectory/advisor-how-to-use-service-upgrade-retirement-recommendations.md" || {
        outputToLogFile "ERROR: \`addFilesToLearnDirectory()\` failed to sync files to \`$learnAdvisorDirectory\` directory";
        return 1;
    }

    return 0
}

main() {
    # ----

    printf "%s\n\n" "\`main()\` for \`searchTypeIdInFile.sh\` started at: \`$(date +"%Y-%m-%d %H:%M:%S")\`"

    validateDirectories || {
        printf '%s\n' "ERROR: \`main()\` failed to validate directories" >&2
        return 1
    }

    chooseSearch || {
        printf '%s\n' "ERROR: \`main()\` directory search failed" >&2
        return 1
    }

    (
        loopAllActiveArrays || {
            printf '%s\n' "ERROR: \`main()\` failed to find one or more arrays" >&2
            exit 1
        }
    ) & (
        getYearMonthInclude || {
            printf '%s\n' "ERROR: \`main()\` failed to create year-month include files" >&2
            exit 1
        }
    ) & (
        outputNewCoverageOfServicesFile "$(getCoverageOfServicesSectionOutput)" || {
            printf '%s\n' "ERROR: \`main()\` failed to create year-month output array" >&2
            exit 1
        }
    ) &  wait

    addFilesToLearnDirectory || {
        printf '%s\n' "ERROR: \`main()\` failed to add files to learn directory" >&2
        return 1
    }

    printf "%s\n\n" "\`main()\` for \`searchTypeIdInFile.sh\` finished at: \`$(date +"%Y-%m-%d %H:%M:%S")\`"
}

time main
