#!/bin/bash
#
# author: github.com/jm-247-ms
# ms.author: v-martinjos@microsoft.com
#
# POSIX-portable, multi-process, fastest-runtime rewrite
# Logging: all output via printf
# Comments: included for all sections

set -euo pipefail

# --- Configurable paths ---
dateStamp=$(date +%Y%b%d-%H%M)

userProfile="/mnt/c/users/v-martinjos"

scriptDirectory="$userProfile/bash/scripts"
temporaryDirectory="$scriptDirectory/temporaryFiles"
outDateRawLogTxt="$temporaryDirectory/$dateStamp-RAW-Log.txt"

# --- Utility: Log ---
log() {
    printf "%s\n" "$*" >> "$outDateRawLogTxt";
}

main() {
    if [ -n "$1" ]; then
        log "$1"
    else
        printf "%s\n" "No message provided to log file"
    fi
}

main "$@"
