#!/bin/bash

userProfile="/mnt/c/users/v-martinjos"

scriptDirectory="$userProfile/bash/scripts"
inputDirectory="$scriptDirectory/input"
outputDirectory="$scriptDirectory/output"

gitDirectory="$userProfile/git"

learnAdvisorDirectory="$gitDirectory/jm-247-ms/azure-monitor-docs-pr/articles/advisor"
includesAdvisorLearnDirectory="$learnAdvisorDirectory/includes"

guidPattern='^\{?[A-Z0-9a-z]{8}-[A-Z0-9a-z]{4}-[A-Z0-9a-z]{4}-[A-Z0-9a-z]{4}-[A-Z0-9a-z]{12}\}?$'

dateStamp=$(printf "%s" "$(date +%Y%b%d-%H%M)")

outDateRawLogTxt="$outputDirectory/$dateStamp-RAW-Log.txt"

outDateFoundLearnSummaryTxt="$outputDirectory/$dateStamp-learn-foundDeprecated-summary.txt"
outDateFoundLearnSummaryRegExText="$outputDirectory/$dateStamp-learn-foundDeprecated-regex-summary.txt"

outDateMissingLearnSummaryTxt="$outputDirectory/$dateStamp-learn-missingActive-summary.txt"
outDateMissingLearnSummaryRegExText="$outputDirectory/$dateStamp-learn-missingActive-regex-summary.txt"

categoryArray=( "Cost" "HighAvailability" "OperationalExcellence" "Performance" )
stateArray=( "Active" "Disabled" )

foundDeprecatedArray=()
missingActiveArray=()

outputToLogFile() {
    # string message otlf_parameter_1

    otlf_parameter_1="$1"

    printf "%s\n" "$otlf_parameter_1" >> "$outDateRawLogTxt"
}

loadArraysToSearchLearn() {
    # string categoryState lafls_parameter_1

    lafls_parameter_1="$1"

    for lafls_fileTemp in $inputDirectory/clean-$lafls_parameter_1-output.txt; do
        printf "%s " "."

        #local lafls_pathTemp=${lafls_fileTemp%/*} 
        #local lafls_fileLongTemp="${lafls_fileTemp##*/}"
        #local lafls_fileExtensionTemp="${lafls_fileLongTemp##*.}"
        #local lafls_fileShortTemp="${lafls_fileLongTemp%.*}"

        lafls_fileContentTemp=$(cat "$lafls_fileTemp")
        lafls_oldLineTemp=""

        for lafls_lineTemp in $lafls_fileContentTemp; do
            outputToLogFile "\`> $ [[ \"$lafls_oldLineTemp\" != \"$lafls_lineTemp\" ]] && [[ \"$lafls_lineTemp\" =~ $guidPattern ]]\`"
            printf "%s " "."

            if [[ "$lafls_oldLineTemp" != "$lafls_lineTemp" ]] && [[ "$lafls_lineTemp" =~ $guidPattern ]]; then
                printf "%s    " "+"

                arrayLines+=("$lafls_lineTemp")

                lafls_oldLineTemp=$lafls_lineTemp
            fi
        done
    done
}

searchLearnFileForTypeID() {
    # string category slffti_parameter_1
    # string state slffti_parameter_2
    # string type ID slffti_parameter_3

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
    # string category slifc_parameter_1
    # string state slifc_parameter_2

    local slifc_parameter_1="$1"
    local slifc_parameter_2="$2"

    for slifc_searchLine in "${arrayLines[@]}"; do
        outputToLogFile "\`> $ find "$includesAdvisorLearnDirectory/" -type f -name \"$slifc_parameter_1*.md\" -exec grep -q \"$slifc_searchLine\" {} +\`"
        printf "%s " "."

        if (find "$includesAdvisorLearnDirectory/" -type f -name "$slifc_parameter_1*.md" -exec grep -q "$slifc_searchLine" {} +); then
            outputToLogFile "\`> $ searchLearnFileForTypeID \"$slifc_parameter_1\" \"$slifc_parameter_2\" \"$slifc_searchLine\"\`"
            printf "%s " "."

            searchLearnFileForTypeID "$slifc_parameter_1" "$slifc_parameter_2" "$slifc_searchLine"
        fi
    done
}

createSummaryForLearnFiles(){
    # ----

    outputToLogFile "\`> $ createSummaryForLearnFiles()\`"

    olatf_foundCount=0

    printf "%s" "(\"|<!--)(" >> $outDateFoundLearnSummaryRegExText

    for olatf_deprectedLineTemp in "${foundDeprecatedArray[@]}"; do
        ((olatf_foundCount=olatf_foundCount+1))
    
        printf "%s" ". "
        printf "%s\n" "\`$olatf_deprectedLineTemp\` found in \`$slffti_includeFile\`" >> "$outDateFoundLearnSummaryTxt"
        printf "%s" "$olatf_deprectedLineTemp" >> "$outDateFoundLearnSummaryRegExText"

        if [[ $olatf_foundCount -lt ${#foundDeprecatedArray[@]} ]]; then
            printf "%s" "|" >> $outDateFoundLearnSummaryRegExText
        fi
    done

    printf "%s" ")(\"|_begin-->|_end-->)" >> $outDateFoundLearnSummaryRegExText

    olatf_missingCount=0

    printf "%s" "(\"|<!--)(" >> $outDateMissingLearnSummaryRegExText

    for olatf_activeLineTemp in "${missingActiveArray[@]}"; do
        ((olatf_missingCount=olatf_missingCount+1))

        printf "%s" ". "
        printf "%s\n" "\`$olatf_activeLineTemp\` is Active and not found" >> "$outDateMissingLearnSummaryTxt"
        printf "%s" "$olatf_activeLineTemp" >> "$outDateMissingLearnSummaryRegExText"

        if [[ $olatf_missingCount -lt ${#missingActiveArray[@]} ]]; then
            printf "%s" "|" >> $outDateMissingLearnSummaryRegExText
        fi
    done
    printf "%s" ")(\"|_begin-->|_end-->)" >> $outDateMissingLearnSummaryRegExText
}

main() {
    # ----

    printf "%s\n" "Search Learn..."

    for m_stateTemp in "${stateArray[@]}"; do
        for m_categoryTemp in "${categoryArray[@]}"; do
            outputToLogFile "\`> $ \"$m_categoryTemp\" \"$m_stateTemp\"\`"
            printf "%s " "."

            outputToLogFile "\`> $ arrayLines=()\`"

            arrayLines=()

            lafls_categoryStateTemp="${m_categoryTemp// /_}${m_stateTemp// /_}"

            printf "\n%s\n" "Load type ID for \`$m_stateTemp\` \`$m_categoryTemp\`"

            loadArraysToSearchLearn "$lafls_categoryStateTemp"
            
            printf "\n%s\n" "Search Learn by \`$m_stateTemp\` \`$m_categoryTemp\` for type ID"

            searchLearnDirectoriesByCategory "$m_categoryTemp" "$m_stateTemp"
        done
    done

    printf "\n%s\n" "Output search results"

    createSummaryForLearnFiles
}

time main
