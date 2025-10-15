#!/bin/bash

# search contents of file

windowsProfile="/mnt/c/users/v-martinjos"
workingDirectory="$windowsProfile/git/jm-247-ms/selfhelpcontent/articles"
scriptDirectory="$windowsProfile/bash/scripts"
outputDirectory="$scriptDirectory/output"

debug=0
searchState="recommendationTypeId"

dateStamp=$(printf "%s" "$(date +%Y%b%d-%H)00")

main() {
    # string file m_parameter_1
    # string option m_parameter_2

    if [[ -f $1 ]]; then
        m_parameter_1=$1

        if [[ -n $2 ]]; then
            m_parameter_2=$2
            currentPath=${m_parameter_1%/*} 
            currentFileLong="${m_parameter_1##*/}"
            currentFileExtension="${currentFileLong##*.}"
            currentFileShort="${currentFileLong%.*}"

            if [[ "$debug" -gt "0" ]]; then
                printf "*   FILE: %s\n" "$m_parameter_1"
            fi

            case "$m_parameter_2" in
                
              "0")
                # return type ID for all files in directory
                tempTypeId=$($scriptDirectory/getTypeIdInFile.sh "$m_parameter_1")

                if [[ "$tempTypeId" != "nomatch" ]]; then
                    if [[ "$debug" -gt "0" ]]; then
                        printf "    *   Type ID: %s\n" "$tempTypeId"
                    fi

                    printf "%s\n" "$tempTypeId" >> $outputDirectory/allTypeIdList-$dateStamp.txt
                    printf "%s\n" "$currentPath" >> $outputDirectory/allDirectories-$dateStamp.txt
                else
                    printf "%s\n" "\`recommendationTypeId\` not found"
                fi
                ;;
              "1")
                # return type ID for all recommendations in directory
                tempTypeId=$($scriptDirectory/getTypeIdInFile.sh "$m_parameter_1")

                if [[ "$tempTypeId" != "nomatch" ]]; then
                    if [[ "$debug" -gt "0" ]]; then
                        printf "    *   Type ID: %s\n" "$tempTypeId"
                    fi

                    printf "%s\n" "$tempTypeId" >> $outputDirectory/recommendationTypeIdList-$dateStamp.txt
                    printf "%s\n" "$currentPath" >> $outputDirectory/recommendationDirectories-$dateStamp.txt
                else
                    if [[ "$debug" -gt "0" ]]; then
                        printf "ERROR: %s\n" "\`recommendationTypeId\` not found"
                    fi
                fi
               ;;
              "2")
                # return type ID for all deprecated recommendations in directory
                tempMetadataState=$($scriptDirectory/searchMetadataStateInFile.sh "$m_parameter_1" "Disabled")

                if [[ "$tempMetadataState" == "match" ]]; then
                    tempTypeId=$($scriptDirectory/getTypeIdInFile.sh "$m_parameter_1")

                    if [[ "$tempTypeId" != "nomatch" ]]; then
                        if [[ "$debug" -gt "0" ]]; then
                            printf "    *   Type ID: %s\n" "$tempTypeId"
                        fi

                    printf "%s\n" "$tempTypeId" >> $outputDirectory/deprectatedRecommendationTypeIdList-$dateStamp.txt
                    printf "%s\n" "$currentPath" >> $outputDirectory/deprecatedRecommendationDirectories-$dateStamp.txt
                    else
                        if [[ "$debug" -gt "0" ]]; then
                            printf "ERROR: %s\n" "\`recommendationTypeId\` not found"
                        fi
                    fi
                fi
                ;;
            esac
        else
            if [[ "$debug" -gt "0" ]]; then
                printf "ERROR: %s\n" "\`directory\` not provided to \`main()\`"
            fi
        fi
    else
        if [[ "$debug" -gt "0" ]]; then
            printf "ERROR: %s\n" "\`file\` not provided to \`main()\`"
        fi
    fi
}

# main "$1" "$2" > $outputDirectory/scif-$dateStamp.txt
main "$1" "$2"
