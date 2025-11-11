---
title: Run docfx server for Microsoft One Azure DevOps git repo
description: Run docfx server for Microsoft One Azure DevOps git repo
author: github.com/jm-247-ms
ms.author: v-martinjos@microsoft.com
date: 08-25-2025

---

# Run docfx server for Microsoft One Azure DevOps git repo

To review the latest readme file for `EngSys-Supportability-Docs` Azure DevOps git repo, see [Azure CXP - Support Documentation](https://msazure.visualstudio.com/One/_git/EngSys-Supportability-Docs?path=/README.md).

## Prerequisites

1.  Install Mono on linux.

    1.  Update

        ```bash
        sudo apt update
        sudo upgrade
        ```

    1.  Install prerequisites.

        ```bash
        sudo apt install software-properties-common
        sudo apt install gnupg ca-certificates
        ```

    1.  Add Mono GPG key.

        ```bash
        wget -qO - https://download.mono-project.com/repo/xamarin.gpg | sudo apt-key add -
        ```

    1.  Add Mono apt repo.

        ```bash
        sudo add-apt-repository "deb https://download.mono-project.com/repo/ubuntu stable main"
        ```

    1.  Update apt index.

        ```bash
        sudo apt update
        ```

    1.  Install Mono.

        ```bash
        sudo apt install -y mono-complete
        ```

    1.  Verify version.

        ```bash
        mono --version
        ```

1.  Install .NET SDK on linux.

    1.  Update

        ```bash
        sudo apt update
        sudo upgrade
        ```

    1.  Install .NET SDK and runtime.

        ```bash
        curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
        chmod +x ./dotnet-install.sh
        ./dotnet-install.sh --channel 9.0 --version latest
        ./dotnet-install.sh --channel 9.0 --version latest --runtime dotnet
        ```

    1.  Verify versions.

        ```bash
        dotnet --list-sdks
        dotnet --list-runtimes
        ```

1.  Install unzip on linux.

    1.  Update

        ```bash
        sudo apt update
        sudo upgrade
        ```

    1.  Install unzip.

        ```bash
        sudo apt install unzip
        ```

    1.  Verify versions.

        ```bash
        unzip --version
        ```

## Install

1.  Install docfx v2.59.4 on linux.

    1.  Set docfx runtime location.

        ```bash
        export docfxZipUrl="https://github.com/dotnet/docfx/releases/download/v2.59.4/docfx.zip"
        ```

    1.  Customize where you want to store the docfx runtime.

        ```bash
        export localUserProfile="/home/$USER"
        export docfxDestinationPath="$localUserProfile/downloads/docfx-v2-59-4"
        export docfxCopyPath="$docfxDestinationPath\docfx.zip"
        export docfxExtractPath="$docfxDestinationPath\docfx"
        ```

    1.  Download the zip file.

        ```bash
        curl -L -o $docfxCopyPath "$docfxZipUrl"
        ```

    1.  Extract the zip file.

        ```bash
        unzip $docfxCopyPath -d $docfxExtractPath
        ```

    1.  Make able to run.

        ```bash
        chmod +x $docfxExtractPath/docfx.exe
        ```

1.  Clone repository on linux.

    1.  Customize where you want to store the `EngSys-Supportability-Docs` Azure DevOps git repo.

        ```bash
        export adoOneEngSysSuppHubUrl="https://dev.azure.com/msazure/One/_git/EngSys-Supportability-Docs"
        export gitCodePath="/mnt/c/Users/$USER/git/One"
        export adoOneEngSysSuppHubPath="$gitCodePath/EngSys-Supportability-Docs"
        ```

    1.  Create location for repo.

        ```bash
        mkdir $gitCodePath
        cd $gitCodePath
        ```

    1.  Clone repo.

        ```bash
        git clone $adoOneEngSysSuppHubUrl
        ```

1.  Run docfx server for the desired branch.

    ```bash
    cd $adoOneEngSysSuppHubPath

    git checkout <name-of-desired-branch>

    $extractPath/docfx.exe docfx.json --serve
    ```

## Single script

### Install

```bash
#!/usr/bin/env bash

sudo apt update
apt list --upgradable || sudo apt upgrade

dpkg -s software-properties-common &>/dev/null || sudo apt install -y software-properties-common

dpkg -s gnupg ca-certificates &>/dev/null || sudo apt install -y gnupg ca-certificates

dpkg -s unzip &>/dev/null || sudo apt install -y unzip

dpkg -s mono-complete &>/dev/null || {
    wget -qO - https://download.mono-project.com/repo/xamarin.gpg | sudo apt-key add -
    sudo add-apt-repository "deb https://download.mono-project.com/repo/ubuntu stable main"
    curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
    chmod +x ./dotnet-install.sh
    ./dotnet-install.sh --channel 9.0 --version latest
    ./dotnet-install.sh --channel 9.0 --version latest --runtime dotnet

    sudo apt update
    sudo apt install -y mono-complete
    sudo apt install -y dotnet-sdk-9.0
    sudo apt install -y dotnet-runtime-9.0
}

sudo apt update
apt list --upgradable || sudo apt upgrade

mono --version
dotnet --list-sdks
dotnet --list-runtimes
unzip --version

[[ -n "$gitCodePath" ]] || export gitCodePath="/mnt/c/Users/$USER/git/One"

[[ -n "$localUserProfile" ]] || export localUserProfile="/home/$USER"

[[ -n "$docfxZipUrl" ]] || export docfxZipUrl="https://github.com/dotnet/docfx/releases/download/v2.59.4/docfx.zip"

[[ -n "$docfxDestinationPath" ]] || export docfxDestinationPath="$localUserProfile/downloads/docfx-v2-59-4"

[[ -n "$docfxCopyPath" ]] || export docfxCopyPath="$docfxDestinationPath/docfx.zip"

[[ -n "$docfxExtractPath" ]] || export docfxExtractPath="$docfxDestinationPath/docfx"

[[ -n "$adoOneEngSysSuppHubUrl" ]] || export adoOneEngSysSuppHubUrl="https://dev.azure.com/msazure/One/_git/EngSys-Supportability-Docs"

[[ -n "$adoOneEngSysSuppHubPath" ]] || export adoOneEngSysSuppHubPath="$gitCodePath/EngSys-Supportability-Docs"

[[ -d "$gitCodePath" ]] || mkdir "$gitCodePath"

[[ -d "$localUserProfile/downloads" ]] || mkdir "$localUserProfile/downloads"

[[ -d "$docfxDestinationPath" ]] || mkdir "$docfxDestinationPath"

cd $docfxDestinationPath

curl -L -o docfx.zip "$docfxZipUrl"

unzip $docfxCopyPath -d $docfxExtractPath

chmod +x $docfxExtractPath/docfx.exe

cd $gitCodePath

git clone $adoOneEngSysSuppHubUrl
```

### Run server

```bash
cd $adoOneEngSysSuppHubPath

# cd "/mnt/c/Users/$USER/git/One/EngSys-Supportability-Docs"

git checkout <name-of-desired-branch>

$docfxExtractPath/docfx.exe docfx.json --serve

# /home/$USER/downloads/docfx-v2-59-4/docfx/docfx.exe docfx.json --serve
```
