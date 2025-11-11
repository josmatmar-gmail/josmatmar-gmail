## Advisor Recommendation Review Checklist

### Reviewer Responsibilities

- Submit and review pull requests for Advisor recommendation edits
- Ensure content quality, clarity, and consistency

## Structure Validation

- Confirm JSON format is valid
- "description" and "displayLabel": ≤ 100 characters; must be identical.
- "longDescription": ≤ 300 characters
- "potentialBenefits": ≤ 60 characters
- "recommendationFriendlyName": must be contiguous with no puctuation, except underscores or hyphens

### Content Alignment

- Check alignment with [Azure Well-Architected Service Guides](https://learn.microsoft.com/en-us/azure/well-architected/service-guides); add links if relevant

### Content Style

- Apply [Microsoft Style Guide](https://learn.microsoft.com/en-us/style-guide) rules since content is published to [Azure Advisor Reference](https://learn.microsoft.com/en-us/azure/advisor/advisor-reference-*) documentation and to an Azure Advisor pane

### Feedback Guidelines

- Provide examples in the feedback
- Align feedback to content review [checklist](https://azsupportdocs.azurewebsites.net/advisor/articles/ReviewProcess.html#checklist)
-  Group required and optional feedback
-  Do not use [Latin-based acronyms](https://en.wikipedia.org/wiki/List_of_Latin_abbreviations) in feedback

### Writing Guidelines

- Use active, present-tense voice
- Avoid passive, future, or past tense
- Do not use "can", "might", "please", "would"; be specific and actionable
- Do not use "that", "this" as a subject or object of a phrase; be specific
- Replace "we" with "the platform"
- Replace "your" or "their" with "the" or specific subject
- Avoid "enable", "disable", "valid", "invalid", "execute"
- Avoid possessive pronouns; use explicit subjects or objects
- Do not use Latin-based acronyms, [reference](https://en.wikipedia.org/wiki/List_of_Latin_abbreviations)

### Recommendation Category Checks

- "recommendationCategory": must be one of `Cost`, `HighAvailability`, `OperationalExcellence`, `Performance`
- For `Cost`: align with [FinOps Framework](https://www.finops.org/framework); add links if relevant
- For `HighAvailability` subcategory: "recommendationCategory" must be one of `HighAvailability`, `BusinessContinuity`, `DisasterRecovery`, `Scalability`, `MonitoringAndAlerting`, `ServiceUpgradeAndRetirement`, `Other`, `Personalized`, `Validation`. Align with [Azure Reliability](https://learn.microsoft.com/en-us/azure/reliability); add links if relevant
- For `OperationalExcellence`: must be one of `EfficiencyOptimization`, `FailureMitigation`, `MonitoringAndAlerting`, `SafeAndSecureDeployment`, `Scalability`, `ServiceUpgradeAndRetirement`, `Other`
- For `Performance`: must be one of `ComputeOptimization`, `DataPerformance`, `MonitoringAndAlerting`, `StorageOptimization`, `NetworkOptimization`, `Scalability`, `ServiceUpgradeAndRetirement`, `Other`

### Naming and Linking

- "recommendationFriendlyName": unique in [SelfHelpContent articles](https://github.com/Azure/SelfHelpContent/articles)
- "learnMoreLink" and "documentLink": must be secure, Microsoft Learn or valid "aka.ms" links; not broken, not generic, not a search page, not locale-specific, and not a `en-us` link
- "learnMoreLink": relevant to "longDescription" and "description"

### Consistency Checks

- "description", "displayLabel", "longDescription", "potentialBenefits": identical across all clouds
- "description": states the action, summarizes "longDescription", no ending punctuation
- "longDescription": states the advantage
- "potentialBenefits": states value proposition and outcome

### Action Type Validation

- If "actionType" is `Blade`:
    - "bladeName": opens valid Azure Blade pane, consistent with "longDescription"
- If "actionType" is `document`:
    - "description": relevant to "documentLink"
    - "documentLink": consistent with "longDescription"

### Review Communication

- Create copy-and-paste GitHub-flavored markdown for the list of issues as feedback
