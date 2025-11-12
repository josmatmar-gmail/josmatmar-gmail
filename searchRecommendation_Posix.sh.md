---
author: github.com/jm-247-ms
ms.author: v-martinjos@microsoft.com
description: POSIX-portable, multi-process, fastest-runtime rewrite
title: searchRecommendation_Posix.sh bash script
lastrun: 2025-08-04

---

## Update home directory for bash scripts

```bash
userProfile="/mnt/c/users/v-martinjos"
```

## Update scripts directory for bash scripts

```bash
scriptDirectory="$userProfile/bash/scripts"
```

## Update local git directory

```bash
gitDirectory="$userProfile/git"
```

### Update local advisor directory for MicrosoftDocs/azure-monitor-docs-pr repository

```bash
learnAdvisorDirectory="$gitDirectory/jm-247-ms/azure-monitor-docs-pr/articles/advisor"
```

### Update local Azure/SelfHelpContent repository directory

```bash
selfHelpContentDirectory="$gitDirectory/jm-247-ms/SelfHelpContent"
```

### Update local articles directory for Azure/SelfHelpContent repository

```bash
articlesSelfhelpcontentDirectory="$selfHelpContentDirectory/articles"
```

## File list

| File | Detail |
|:--- |:--- |
| addDirectoryToList.sh | Utility: Add directory to list with deduplication and sort |
| addLearnActiveNotFound.sh | Utility: Add active not found on Learn |
| addLearnDeprecatedFound.sh | Utility: Add deprecated found on Learn |
| addTypeIdToList.sh | Utility: Add type ID to category and state list |
| checkDirectoryExists.sh | Utility: Directory verification and creation |
| createLearnSummary.sh | Create Learn summary files |
| getFileExtensionForFile.sh | Utility: Get extension of file |
| getMetadataValueInFile.sh | Utility: Get metadata value from file |
| getPathForFile.sh | Utility: Get directory path of file |
| log.sh | Utility: Log |
| mergeAndDeduplicate.sh | Merge and deduplicate results |
| parallelSearch.sh | Main: search for markdown files in parallel |
| processMarkdownFile.sh | Process a single markdown file in parallel |
| searchLearnParallel.sh | Search for type IDs on Learn in parallel |
| searchRecommendation_Posix.sh | Main script |
