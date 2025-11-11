---
title: Edit a recommendation in GitHub
description: Use web browser to edit a recommendation.
ms.topic: article
ms.date: 03/03/2025

---

# Edit a recommendation in GitHub

How to edit the metadata of a recommendation in GitHub using GitHub UI.

## Why use GitHub UI

Lightweight changes that only require a web browser.

## Prerequisites

1.  Configure your GitHub account for SelfHelp repo.

    > **NOTE**: <br />
    > To learn how to configure your Github account, see [Setup your GitHub account and permissions](../../portal/articles/SetupGithub.html "Setup your GitHub account and permissions | Content Publishing Service | Portal | Azure Support Docs").

## Open a recommendation for specific product on GitHub

1.  On **Azure** / **SelfHelpContent**, select **articles**.

1.  On **SelfHelpContent** / **articles**, select the directory for your recommendation.

1.  On **SelfHelpContent** / **articles** / recommendation directory, select the recommendation file.

<!---
    > **NOTE**: <br />
    > A recommendation has at least one markdown file.
    >
    > ```
    > <recommendationname>_public.md
    > ```
    >
    > A markdown file for a recommendation is configured for at least one cloud environment. 
    > A recommendation for a single cloud environment is named for the cloud environment.
    >
    > | Cloud environment | File name <br /> Metadata |
    > |:--- |:--- |
    > | All public | `<recommendationname>_public.md` <br /> `cloudEnvironments="Public, USNat, USSec"` |
    > | Fairfax | `<recommendationname>_fairfax.md` <br /> `cloudEnvironments="Fairfax"` |
    > | Mooncake | `<recommendationname>_mooncake.md` <br /> `cloudEnvironments="Mooncake"` |
    > | Public | `<recommendationname>_public.md` <br /> `cloudEnvironments="Public"` |
    > | USNat | `recommendationname>_usnat.md` <br /> `cloudEnvironments="USNat"` |
    > | USSec | `recommendationname>_ussec.md` <br /> `cloudEnvironments="USSec"` |
--->

## Edit a recommendation

### Edit recommendation metadata in github.dev

1.  On **SelfHelpContent** / **articles** / recommendation directory / recommendation file, next to **Edit**, select the drop-down menu > **github.dev**.

1.  Allow the **GitHub Repositories** extension to authenticate using GitHub.

1.  Select the account for the **GitHub Repositories** to use.

1.  Confirm that **github.dev** opens **SELFHELPCONTENT[GITHUB]** > **articles** > recommendation directory > recommendation file.

#### Scenario: Unpublish a published recommendation

1.  In **github.dev** on **SELFHELPCONTENT[GITHUB]** > **articles** > recommendation directory > recommendation file.

    1.  Set the value of `recommendationMetadataState` from `Active` to `Disable`.

    1.  Increment the value of `version` from `x.y` to `x+1.y`.

#### Scenario: Change the refresh rate for a recommendation

1.  In **github.dev** on **SELFHELPCONTENT[GITHUB]** > **articles** > recommendation directory > recommendation file.

    1.  Update the value of `refreshInterval`.

    1.  Increment the value of `version` from `x.y` to `x+1.y`.

#### Scenario: Correct a spelling error in a recommendation

1.  In **github.dev** on **SELFHELPCONTENT[GITHUB]** > **articles** > recommendation directory > recommendation file.

    1.  Update the text in metadata.

        *   `description`

        *   `longDescription`

        *   `potentialBenefits`

        *   `description` of an `action`

        *   `displayLabel`

        *   `tip`

        *   `costSavingsIssue`

    1.  Increment the value of `version` from `x.y` to `x.y+1`.

### Save changes to new branch in github.dev

in **github.dev**, on the recommendation file 

1.  Select **Source Control** or press <key>ctrl</key> + <key>shift</key> + <key>G</key>.

1.  On **SOURCE CONTROL**, in the **Message** textbox, enter the commit message, and select **Commit & Push**.

1.  Confirm that you want to commit your changes to a new branch.

1.  In **New Branch Name** textbox, enter the name of the new branch, and press <key>enter</key>.

1.  Confirm that you want to switch to the new branch.

## Create a pull request

1.  On **Azure** / **SelfHelpContent**, select **Branches**.

1.  On **Branches**, select **Yours**, under the **Branch** heading, select the name of your branch.

1. On **Azure** / **SelfHelpContent** : branch name, select **Compare & pull request**.

On **Open a pull request**.

1.  Add a title that includes the name of the recommendation.

1.  Add a description that includes the reason for the change.

1.  Add the GitHub aliases for reviewers on your team.

1.  Select **Create pull Request**.

## Create a new recommendation from template

1.  On **Azure** / **SelfHelpContent**, select **documents**.

1.  On **SelfHelpContent** / **documents**, select **AdvisorRecommendationMetadata-templates**.

1.  On **SelfHelpContent** / **documents** / **AdvisorRecommendationMetadata-templates**, select **AdvisorRecommendationMetadata-template.md**.
