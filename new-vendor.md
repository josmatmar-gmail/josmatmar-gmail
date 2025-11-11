---
title: Onboard a new vendor
description: List to help sponsor to onboard a new vendor
author: github.com/jm-247-ms
ms.author: v-martinjos@microsoft.com
date: 07-25-2025

---

# Onboard a new vendor

## Alias and temporary passcode

1.  The Employee ID and new alias for the vendor is provided to the sponsor.

1.  The vendor must complete the actions on **I am new**.

    See [aka.ms/iamnew](https://aka.ms/iamnew "Welcome to the Microsoft Corporate Access Guidelines | Microsoft Corp Access Guidelines").

## RAS and VPN access

1.  The sponsor must request RAS access on behalf of the vendor.

    See [coreidentity.microsoft.com/landing-page/redmond/CRG-ras-exceptions/submit](https://coreidentity.microsoft.com/landing-page/redmond/CRG-ras-exceptions/submit "Submit RAS Access Request | CoreIdentity").

## Requests that require VPN access

1.  The vendor must use the Azure VPN to request membership to `AzWIRW` entitlement.

    See [coreidentity.microsoft.com/manage/entitlement/entitlement/azwirw-zzdc](https://coreidentity.microsoft.com/manage/entitlement/entitlement/azwirw-zzdc "AzWIRW | Manage Entitlement | CoreIdentity").

## Requests that do not require VPN access

1.  The vendor must configure a github account and request access to the Microsoft organization, Azure organization, and Azure self help content team.

    See [azsupportdocs.azurewebsites.net/advisor/articles/ConfigureGitHubAccount.html](https://azsupportdocs.azurewebsites.net/advisor/articles/ConfigureGitHubAccount.html "Create GitHub account to access the Azure/SelfHelpContent repository | Azure Support Docs").

1.  Join **Microsoft Docs** organization.

    See [repos.opensource.microsoft.com/orgs/microsoftdocs](https://repos.opensource.microsoft.com/orgs/microsoftdocs "Microsoft Docs | orgs | Microsoft open source").

1.  Select **Join Microsoft Docs**.

1.  Join **SelfHelp-Content-Approver** team.

    See [github.com/orgs/Azure/teams/selfhelp-content-approver](https://github.com/orgs/Azure/teams/selfhelp-content-approver "SelfHelp-Content-Approver | teams | Microsoft Azure | GitHub").

1.  Select **Request to join**.

## Configure access to internal Advisor documentation

The internal support content hosted in the Azure Support Docs and the Engineering docs requires access to the `One/EngSys-Supportability-Docs`  AzureDevOps repository.

1.  Request access from your sponsor or the site owner of the following repository.

    ```https
    https://msazure.visualstudio.com/One/_git/EngSys-Supportability-Docs
    ```

## Configuration for offline workflows

To work offline or on larger content changes, the vendor should use the following tools.

### Create a fork of your repositories

1.  On github.com, sign into your account.

1.  Select your account icon > **Your repositories**.

    > [!NOTE]
    > If you have a fork, the source is listed under the name of the repository.

1.  Select the name of the repository.

1.  Select **Fork**.

1.  On **Create a new fork**. select **Create fork**.

### Configure Visual Studio Code

1.  Download and install **Visual Studio Code** app.

1.  Install the following extensions.

    *   Acrolinx for Visual Studio Code.

        See [review.learn.microsoft.com/en-us/help/platform/acrolinx-vscode-setup?branch=main#install-acrolinx-in-visual-studio-code](https://review.learn.microsoft.com/en-us/help/platform/acrolinx-vscode-setup?branch=main#install-acrolinx-in-visual-studio-code "Install Acrolinx in Visual Studio Code | Learn")

        1.  In the **Acrolinx URL**, enter the following url.

            ```https
            https://microsoft-ce-csi.acrolinx.cloud
            ```

    *   Learn Authoring Pack

        see [review.learn.microsoft.com/en-us/help/platform/learn-authoring-pack-description?branch=main](https://review.learn.microsoft.com/en-us/help/platform/learn-authoring-pack-description?branch=main "Microsoft Learn Authoring Pack | Learn").

### Configure Windows Subsystem for Linux

1.  Open **Terminal** app.

1.  Enter the following code.

    ```powershell
    wsl --install
    ```

1.  After you create an `admin` account, enter the following code to update GNU/Linux.

    ```bash
    sudo apt update
    apt list --upgradable
    sudo apt upgrade
    ```

1.  After you update GNU/Linux, enter the following code to get the version of `git`.

    ```bash
    git --version
    ```

1.  Change the directory to the parent directory for your local github repositories.

    ```bash
    cd /mnt/c/users/<ms-alias>/<path>/<to>/</local>/<github>/<parent>/
    ```

#### Use SSH to connect to GitHub

See [docs.github.com/en/authentication/connecting-to-github-with-ssh](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).

### Configure GitHub Desktop

1.  Download and install **GitHub Desktop** app.

1.  Sign into Github.com.

1.  Select **File** > **Options**

1.  Select **Options** > **Integrations**.

1.  Under **External Editor**, select `Visual Studio Code`.

1.  Under **Shell**, select `Windows Terminal`.

1.  Select **Clone repository**.

1.  On **Clone a repository** > **GitHub.com**.

    1.  Under **Your repositories**, select your fork.

    1.  Under **Local path**, choose the parent directory for your for the local copy of your fork.

    1.  Select **Clone**.

## Timekeeping

1.  The vendor must track hours using Beeline.

    See [prod.beeline.com/microsoft](https://prod.beeline.com/microsoft "Microsoft | Beeline").

1.  Select **Continue with SSO**.

1.  Select **Regular Time**.

1.  Enter hours worked.

1.  Select **Save Changes**.

1.  Select **Sign out**.
