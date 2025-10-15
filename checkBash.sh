#!/bin/bash

windowsProfile="/mnt/c/users/v-martinjos"
workingDirectory="$windowsProfile/git/jm-247-ms/selfhelpcontent/articles"
scriptDirectory="$windowsProfile/bash/scripts"
outputDirectory="$scriptDirectory/output"

arrayCheck=( "apt" "bash" "code" "csh" "git" "plantml" "ssh" "ssl" "tsch" "zsh" )

dateStamp=$(printf "%s" "$(date +%Y%b%d-%H)00")

debug="0"

main() {
    currentDirectory=$(pwd)

    cd $scriptsDirectory

    sudo apt update -y
    sudo apt upgrade -y

    for item in ${arrayCheck[@]}; do
        printf "%s" "checking for \`$item\`... "

        tempCommand="$item --version"

        if $tempCommand &> /dev/null ; then
            printf "%s\n" "found"
            if [[ "$debug" -gt "0" ]]; then
                printf "%s\n> " "---"

                $item --version

                printf "%s\n" "---"
            fi
        else
            printf "\t%s\n" "not found"
        fi
    done

    if $windowsProfile$scriptsDirectory &> /dev/null ; then
        mkdir $windowsProfile$scriptsDirectory/output
    fi

    sudo apt autoremove -y

    printf "%s\n" "Starting directory: $currentDirectory"
    printf "%s\n" "Current directory: $(pwd)"
}

main
