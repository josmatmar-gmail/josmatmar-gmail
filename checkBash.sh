#!/bin/bash

windowsProfile="/mnt/c/users/v-martinjos"
workingDirectory="$windowsProfile/git/jm-247-ms/selfhelpcontent/articles"
scriptDirectory="$windowsProfile/bash/scripts"
outputDirectory="$scriptDirectory/output"

arrayCheck=( "apt" "bash" "code" "csh" "git" "plantml" "ssh" "ssl" "tsch" "zsh" )

dateStamp=$(printf "%s" "$(date +%Y%b%d-%H)00")

debug="0"

main() {
    local currentDirectory=$(pwd)

    cd $scriptDirectory

    sudo apt update -y
    apt list --upgradeable || sudo apt upgrade -y

    for item in ${arrayCheck[@]}; do
        printf "%s" "checking for \`$item\`..."

        local tempCommand="$item --version"

        $tempCommand &>/dev/null && {
            printf "\t%s\n" "found";

            if [[ "$debug" -gt "0" ]]; then
                printf "%s\n> " "---"

                $item --version

                printf "%s\n" "---"
            fi;
        } || {
            printf "\t%s\n" "not found";
        }
    done

    [[ -d "$scriptDirectory" ]] || mkdir "$scriptDirectory";
    [[ -d "$outputDirectory" ]] || mkdir "$outputDirectory";

    sudo apt autoremove -y

    printf "%s\n" "Starting directory: $currentDirectory"
    printf "%s\n" "Current directory: $(pwd)"
}

main
