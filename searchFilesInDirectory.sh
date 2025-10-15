#!/bin/bash

# search files in directory

windowsProfile="/mnt/c/users/v-martinjos"
workingDirectory="$windowsProfile/git/jm-247-ms/selfhelpcontent/articles"
scriptDirectory="$windowsProfile/bash/scripts"
outputDirectory="$scriptDirectory/output"

debug=0
searchState="recommendationTypeId"

dateStamp=$(printf "%s" "$(date +%Y%b%d-%H)00")

main() {
    # string directory m_parameter_1
    # string option m_parameter_2

    if [[ -d $1 ]]; then
        m_parameter_1=$1

        if [[ -n $2 ]]; then
            m_parameter_2=$2

            if [[ "$debug" -gt "0" ]]; then
                printf "DIRECTORY: %s\n" "$m_parameter_1"
            fi
            
            # for all files set to "0"
            # for all recommendations set to "1"
            # for deprecated recommendations set to "2"
            for currentChild in $m_parameter_1/* ; do
                if [[ -d $currentChild ]]; then
                    main "$currentChild" "$m_parameter_2"
                elif [[ -f $currentChild ]]; then
                    $scriptDirectory/searchContentInFile.sh "$currentChild" "$m_parameter_2"
                fi
            done
        else
            if [[ "$debug" -gt "0" ]]; then
                printf "ERROR: %s\n" "\`option\` not provided to \`main()\`"
            fi
        fi
    else
        if [[ "$debug" -gt "0" ]]; then
            printf "ERROR: %s\n" "\`directory\` not provided to \`main()\`"
        fi
    fi
}

# main "$1" "$2" > $outputDirectory/sfid-$dateStamp.txt
main "$workingDirectory" "2"
