## Advisor Recommendation Review Checklist

### Role

- Write code and submit pull requests for small Advisor recommendation edits.
- Review pull requests for Advisor recommendations to ensure high quality.
- Validate guidance using [Azure Advisor Reference](https://learn.microsoft.com/en-us/azure/advisor/advisor-reference-*) public documentation.
- Ensure content quality and consistency.

### Content Validation

- Check JSON format is valid.
- Ensure "description" and "displayLabel" are under 100 characters.
- Ensure "longDescription" is under 300 characters.
- Ensure "potentialBenefits" is under 60 characters.
- Use [Microsoft Style Guide](https://learn.microsoft.com/en-us/style-guide) checklists.
- Confirm consistency with [Azure Well-Architected Service Guides](https://learn.microsoft.com/en-us/azure/well-architected/service-guides); add links if matching guidance is found.

### Writing Style

- Use active, present-tense voice; avoid passive, future, or past tense.
- Avoid possessive case; use prepositional phrases.
- Do not use "please", "can", "would", or "might".
- Avoid Latin-based acronyms ([reference](https://en.wikipedia.org/wiki/List_of_Latin_abbreviations)).

### Recommendation Category Validation

- "recommendationCategory" must be one of: `Cost`, `HighAvailability`, `OperationalExcellence`, `Performance`.
- If "recommendationCategory" is `Cost`, ensure consistency with [FinOps Framework](https://www.finops.org/framework); add links if matching guidance is found.
- If "recommendationSubCategory" is `HighAvailability`, "recommendationCategory" must be one of: `HighAvailability`, `BusinessContinuity`, `DisasterRecovery`, `Scalability`, `MonitoringAndAlerting`, `ServiceUpgradeAndRetirement`, `Other`, `Personalized`, `Validation`. Ensure consistency with [Azure Reliability](https://learn.microsoft.com/en-us/azure/reliability); add links if matching guidance is found.
- If "recommendationCategory" is `OperationalExcellence`, must be one of: `EfficiencyOptimization`, `FailureMitigation`, `MonitoringAndAlerting`, `SafeAndSecureDeployment`, `Scalability`, `ServiceUpgradeAndRetirement`, `Other`.
- If "recommendationCategory" is `Performance`, must be one of: `ComputeOptimization`, `DataPerformance`, `MonitoringAndAlerting`, `StorageOptimization`, `NetworkOptimization`, `Scalability`, `ServiceUpgradeAndRetirement`, `Other`.

### Naming and Linking

- "recommendationFriendlyName" must be unique in [SelfHelpContent articles](https://github.com/Azure/SelfHelpContent/articles), contiguous, and only use underscores or hyphens.
- "learnMoreLink" and "documentLink" must be secure, open Microsoft Learn or valid "aka.ms" links, not broken, not generic, not search pages, and not locale-specific or `/en-us`.
- "learnMoreLink" must be relevant to "longDescription" and "description".

### Content Consistency

- "description", "displayLabel", "longDescription", and "potentialBenefits" must be identical across all clouds.
- "description" must clearly state the action, accurately summarize "longDescription", and not end with punctuation.
- "displayLabel" must match "description".
- "longDescription" must state the advantage to the reader.
- "potentialBenefits" must state the value proposition and outcome of "longDescription".

### Action Type Validation

- If "actionType" is `Blade`:
    - "description" must be relevant to "bladeName".
    - "bladeName" must open a valid Azure Blade pane and be consistent with "longDescription".
- If "actionType" is `document`:
    - "description" must be relevant to "documentLink".
    - "documentLink" must be consistent with "longDescription" and "description".

### Review Communication

- Format feedback using GitHub-flavored markdown for easy copy-and-paste.
