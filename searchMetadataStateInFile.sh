#!/bin/bash

# search if Metadata State exists in file

windowsProfile="/mnt/c/users/v-martinjos"
workingDirectory="$windowsProfile/git/jm-247-ms/selfhelpcontent/articles"
scriptDirectory="$windowsProfile/bash/scripts"
outputDirectory="$scriptDirectory/output"

debug=0
searchState="recommendationMetadataState"

dateStamp=$(date +%Y%b%d-%H)

main() {
    # string file m_parameter_1
    # string metadata state m_parameter_2

    if [[ -f $1 ]]; then
        m_parameter_1=$1

        if [[ -n $2 ]]; then
            m_parameter_2=$2
            m_stateTemp="\"$searchState\": \"$m_parameter_2\""

            if grep -iqw "$m_stateTemp" "$m_parameter_1"; then
                if [[ "$debug" -gt "0" ]]; then
                    printf "%s" "\`$m_stateTemp\` found \`$m_parameter_1\`"
                fi

                printf "%s" "match"
            else
                if [[ "$debug" -gt "0" ]]; then
                    printf "%s" "\`$m_stateTemp\` not found \`$m_parameter_1\`"
                fi

                printf "%s" "nomatch"
            fi
        else
            if [[ "$debug" -gt "0" ]]; then
                printf "ERROR: %s\n" "\`metadata state\` not provided to \`main()\`"
            fi
        fi
    else
        if [[ "$debug" -gt "0" ]]; then
            printf "ERROR: %s\n" "\`file\` not provided to \`main()\`"
        fi
    fi
}

# main "$1" "$2" > $outputDirectory/smsif-$dateStamp.txt
main "$1" "$2"