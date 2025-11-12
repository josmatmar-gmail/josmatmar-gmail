#!/usr/bin/env bash

linuxProfileDirectory="/home/$USER"
windowsProfileDirectory="/mnt/c/Users/$USER"

docfxZipFileName="docfx.zip"
githubDotnetDocfxReleasesDownloadV2594DocfxZip="https://github.com/dotnet/docfx/releases/download/v2.59.4/$docfxZipFileName"
localDocfxZipPath="$localDownloadsDocfxDirectory/$docfxZipFileName"
localDocfxDirectory="$localDownloadsDocfxDirectory/docfx"
localDownloadsDocfxDirectory="$linuxProfileDirectory/downloads/docfx-v2-59-4"

adoOneGitUri="https://dev.azure.com/msazure/One/_git"
engSupDocRepoName="EngSys-Supportability-Docs"
gitOneDirectory="$windowsProfileDirectory/git/One"

prerequisitepackagelistarray=(
    "software-properties-common"
    "gnupg"
    "ca-certificates"
    "unzip"
)

requireddirectoriesarray=(
    "$windowsProfileDirectory"
    "$gitOneDirectory"
    "$gitOneDirectory/$engSupDocRepoName"
    "$linuxProfileDirectory"
    "$linuxProfileDirectory/downloads"
    "$localDownloadsDocfxDirectory"
)

# utility

requestSudoPassword() {
    # ----

    read -s -p "Enter your password: " rsp_password
    printf "%s" "--password=\"$rsp_password\""
}

updateApt() {
    # string password phrase ua_parameter_1

    ua_parameter_1="$1"

    printf "%s" "$ua_parameter_1" | sudo apt update

    apt list --upgradable || {
        printf "%s" "$ua_parameter_1" | sudo apt upgrade
    }
}

verifyAptPackage() {
    # string package name vap_parameter_1

    vap_parameter_1="$1"

    dpkg -s "$vap_parameter_1" &>/dev/null
    return $?
}

installAptPackage() {
    # string package name iap_parameter_1
    # string password phrase iap_parameter_2

    iap_parameter_1="$1"
    iap_parameter_2="$2"

    printf "%s" "$iap_parameter_2" | sudo apt install -y "$iap_parameter_1"
}

installPrerequisitePackages() {
    # string password phrase ipp_parameter_1

    ipp_parameter_1="$1"

    for packageName in "${prerequisitepackagelistarray[@]}"; do
        verifyAptPackage "$packageName" || {
            {
                printf "%s" "$ipp_parameter_1" | installAptPackage "$packageName"
            } || {
                printf "%s\n" "\`installPrerequisitePackages()\` failed to install '$packageName' package";
                return 1;
            }
        }

        $packageName --version &>/dev/null || {
            printf "%s\n" "\`installPrerequisitePackages()\` '$packageName' package is not functioning properly";
            return 1;
        }
    done

    updateApt "$ipp_parameter_1" || {
        printf "%s\n" "\`installPrerequisitePackages()\` failed to update apt";
        return 1;
    }

    return 0
}

# install mono and dotnet

verifyMonoDotnet() {
    verifyAptPackage "mono-complete" || return 1
    mono --version &>/dev/null || return 1
    dotnet --list-sdks &>/dev/null || return 1
    dotnet --list-runtimes &>/dev/null || return 1
    return $?
}

installMonoDotnetAptPackage() {
    # string password phrase imd_parameter_1

    imdap_parameter_1="$1"

    wget -qO xamarin.gpg https://download.mono-project.com/repo/xamarin.gpg || {
        printf "%s\n" "\`installMonoDotnetAptPackage()\` failed to download mono gpg key";
        return 1;
    }

   printf "%s" "$imdap_parameter_1" | sudo apt-key add xamarin.gpg || {
        printf "%s\n" "\`installMonoDotnetAptPackage()\` failed to add mono gpg key";
        return 1;
    }

    rm -f xamarin.gpg
        printf "%s\n" "\`installMonoDotnetAptPackage()\` failed to add mono gpg key";
        return 1;
    }

    printf "%s" "$imdap_parameter_1" | sudo add-apt-repository "deb https://download.mono-project.com/repo/ubuntu stable main" || {
        printf "%s\n" "\`installMonoDotnetAptPackage()\` failed to add mono apt repository";
        return 1;
    }

    curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh || {
        printf "%s\n" "\`installMonoDotnetAptPackage()\` failed to download dotnet install script";
        return 1;
    }

    chmod +x ./dotnet-install.sh || {
        printf "%s\n" "\`installMonoDotnetAptPackage()\` failed to make dotnet install script executable";
        return 1;
    }

    ./dotnet-install.sh --channel 9.0 --version latest || {
        printf "%s\n" "\`installMonoDotnetAptPackage()\` failed to install dotnet sdk";
        return 1;
    }

    ./dotnet-install.sh --channel 9.0 --version latest --runtime dotnet || {
        printf "%s\n" "\`installMonoDotnetAptPackage()\` failed to install dotnet runtime";
        return 1;
    }

    updateApt "$imdap_parameter_1" || {
        printf "%s\n" "\`installPrerequisitePackages()\` failed to update apt";
        return 1;
    }

    printf "%s" "$imdap_parameter_1" | sudo apt install -y mono-complete  || {
        printf "%s\n" "\`installMonoDotnetAptPackage()\` failed to install mono package";
        return 1;
    }

    printf "%s" "$imdap_parameter_1" | sudo apt install -y dotnet-sdk-9.0 || {
        printf "%s\n" "\`installMonoDotnetAptPackage()\` failed to install mono and dotnet packages";
        return 1;
    }

    printf "%s" "$imdap_parameter_1" | sudo apt install -y dotnet-runtime-9.0 || {
        printf "%s\n" "\`installMonoDotnetAptPackage()\` failed to install mono and dotnet packages";
        return 1;
    }

    updateApt "$imdap_parameter_1" || {
        printf "%s\n" "\`installPrerequisitePackages()\` failed to update apt";
        return 1;
    }

    return 0
}

# verify paths

verifyDirectoryExists() {
    # string directory path vde_parameter_1

    vde_parameter_1="$1"

    [[ -d "$vde_parameter_1" ]] && return 0 || return 1
}

addDirectory() {
    # string directory path ad_parameter_1

    ad_parameter_1="$1"

    verifyDirectoryExists "$ad_parameter_1" || mkdir -p "$ad_parameter_1"
    return $?
}

addDirectories() {
    # ----

    for ad_directoryPathTemp in "${requireddirectoriesarray[@]}"; do
        verifyDirectoryExists "$ad_directoryPathTemp" || {
            addDirectory "$ad_directoryPathTemp" || {
                printf "%s\n" "\`addDirectories()\` failed to add '$ad_directoryPathTemp' directory";
                return 1;
            }
        }
    done

    return 0
}

verifyDocfx() {
    # ----

    cd $localDocfxDirectory || return 1

    [[ -f $localDocfxDirectory/docfx.exe ]] || return 1

    $localDocfxDirectory/docfx.exe --version &>/dev/null || return 1

    return 0
}

installDocfx() {
    # ----

    cd $localDocfxDirectory

    curl -L -o docfx.zip "$githubDotnetDocfxReleasesDownloadV2594DocfxZip" || {
        printf "%s\n" "\`installDocfx()\` failed to download docfx";
        return 1;
    }

    unzip $localDocfxZipPath -d $localDocfxDirectory || {
        printf "%s\n" "\`installDocfx()\` failed to unzip docfx";
        return 1;
    }

    chmod +x $localDocfxDirectory/docfx.exe || {
        printf "%s\n" "\`installDocfx()\` failed to make docfx executable";
        return 1;
    }

    printf "%s\n" "run Docfx: \`$localDocfxDirectory/docfx.exe docfx.json --serve\`"



    return 0
}

# ADO One repo

verifyLocalRepo() {
    $ string local Repo Name vlr_parameter_1

    vlr_parameter_1="$1"

    local localRepoDirectory

    cd $gitOneDirectory || {
        printf "%s\n" "\`verifyLocalRepo()\` failed to locate git code path";
        return 1;
    }

    [[ -d $vlr_parameter_1 ]] || {
        printf "%s\n" "\`verifyLocalRepo()\` '$vlr_parameter_1' directory does not exist.";
        return 1;
    }

    localRepoDirectory=$(printf "%s/%s" "$gitOneDirectory" "$vlr_parameter_1")

    cd $localRepoDirectory || {
        printf "%s\n" "\`verifyLocalRepo()\` failed to locate \`$localRepoDirectory\` path";
        return 1;
    }

    git rev-parse --is-inside-work-tree &>/dev/null || {
        printf "%s\n" "\`verifyLocalRepo()\` \`$localRepoDirectory\` directory is not a local git repo.";
        return 1;
    }

    return 0
}

cloneLocalRepo() {
    $ string local Repo Name clr_parameter_1

    clr_parameter_1="$1"

    local adoGitRepoUri
    local localRepoDirectory

    cd $gitOneDirectory || {
        printf "%s\n" "\`cloneLocalRepo()\` failed to locate git code path";
        return 1;
    }

    adoGitRepoUri=$(printf "%s/%s" "$adoOneGitUri" "$clr_parameter_1")

    git clone $adoGitRepoUri || {
        printf "%s\n" "\`cloneLocalRepo()\` failed to clone '$adoGitRepoUri' repo to local repo =";
        return 1;
    }

    return 0
}

# ADO One repo branch

verifyBranch() {
    # string local repo name vb_parameter_1
    # string branch name vb_parameter_2

    vb_parameter_1="$1"
    vb_parameter_2="$2"

    local vb_localRepoDirectory

    vb_localRepoDirectory=$(printf "%s/%s" "$gitOneDirectory" "$vb_parameter_1")

    cd $vb_localRepoDirectory || {
        printf "%s\n" "\`verifyBranch()\` failed to locate \`$vb_localRepoDirectory\` path";
        return 1;
    }

    git rev-parse --is-inside-work-tree &>/dev/null || {
        printf "%s\n" "\`verifyBranch()\` \`$vb_localRepoDirectory\` directory is not a local git repo.";
        return 1;
    }

    git branch --list "$vb_parameter_2" || {
        git ls-remote --heads origin "$vb_parameter_2" || {
            printf "%s\n" "\`setBranch()\` '$vb_parameter_2' branch does not exist.";
            return 1;
        };
    
        git fetch origin "$vb_parameter_2":"$vb_parameter_2" || {
            printf "%s\n" "\`setBranch()\` failed to fetch branch '$vb_parameter_2' from origin.";
            return 1;
        };
    }

    return 0
}

setBranch() {
    # string local repo name sb_parameter_1
    # string branch name sb_parameter_2

    sb_parameter_1="$1"
    sb_parameter_2="$2"

    local sb_localRepoDirectory

    sb_localRepoDirectory=$(printf "%s/%s" "$gitOneDirectory" "$sb_parameter_1")

    cd $sb_localRepoDirectory || {
        printf "%s\n" "\`setBranch()\` failed to locate repo path";
        return 1;
    }

    git checkout $sb_parameter_2 || {
        printf "%s\n" "\`setBranch()\` failed to checkout '$sb_parameter_2' branch";
        return 1;
    }
}

# Docfx server

runDocfxServer() {
    [[ -d $localDocfxDirectory ]] && {
        cd $localDocfxDirectory;
        $localDocfxDirectory/docfx.exe docfx.json --serve;
    } || {
        printf "%s\n" "\`runDocfxServer()\` failed to locate docfx path";
        return 1;
    }
}

main () {
    local m_passWord

    m_passWord=$(requestSudoPassword)

    updateApt "$m_passWord" || {
        printf "%s\n" "\`main()\` failed to update apt";
        return 1;
    }

    installPrerequisitePackages

    verifyMonoDotnet || {
        installMonoDotnetAptPackage "$m_passWord" || {
            printf "%s\n" "\`main()\` failed to install mono and dotnet packages";
            return 1;
        };
    }

    addDirectories "$m_passWord" || {
        printf "%s\n" "\`main()\` failed to add required directories";
        return 1;
    };

    verifyLocalRepo "$engSupDocRepoName" || {
        cloneLocalRepo "$engSupDocRepoName" || {
            printf "%s\n" "\`main()\` failed to clone repo";
            return 1;
        };
    }

    printf "%s\n" "Enter the name of the branch to use (default is \`main\`)";

    read -r userBranchNameInput

    userBranchNameInput=${userBranchNameInput:-main}

    verifyBranch "$engSupDocRepoName" "$userBranchNameInput" || {
        setBranch "$engSupDocRepoName" "$userBranchNameInput" || {
            printf "%s\n" "\`main()\` failed to set branch";
            return 1;
        };
    };

    verifyDocfx || {
        installDocfx || {
            printf "%s\n" "\`main()\` failed to install docfx";
            return 1;
        };
    }

    runDocfxServer || {
        printf "%s\n" "\`main()\` failed to run docfx server";
        return 1;
    };
}

time main
