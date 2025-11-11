# Content review for recommendation pull requests

## recommendationCategory

*    Blocking: recommendation category should be one of the supported values: `Cost`, `HighAvailability`, `OperationalExcellence`, `Performance`.

*    Selected value should be consistent with the recommendation `description`, `longDescription`, and `displayLabel`.

### examples of recommendationCategory

````markdown
The value of `recommendationControl` must one of the supported values.

*   `Cost`

*   `HighAvailability`

*   `OperationalExcellence`

*   `Performance`
````

````markdown
The value of `recommendationControl` should be consistent with the values of `description`, `longDescription`, and `displayLabel` for your recommendation.
````

---

## recommendationControl

*    Only used for recommendation in the reliability category.

*    Selected value should be one of the supported values.

     *   `BusinessContinuity`

     *   `DisasterRecovery`

     *   `HighAvailability`

     *   `MonitoringAndAlerting`

     *   `OtherBestPractices`

     *   `Personalized`

     *   `Scalability`

     *   `ServiceUpgradeAndRetirement`

     Read more about [reliability score controls](https://azsupportdocs.azurewebsites.net/advisor/articles/score/ReliabilityScore.html#controls "Controls - Reliability score (new) | Azure CXP Support Docs").

*    Should be consistent with recommendation `description`, `longDescription`, and `displayLabel`.

### examples of recommendationControl

````markdown
The value of `recommendationControl` is missing.

The `redommendationControl` is required when the value of `recommendationCategory` is set to `HighAvailability`.
````

````markdown
Remove `recommendationControl` when the value of `recommendationCategory` is not set to `HighAvailability`.
````

````markdown
The value of `recommendationControl` must align with the following guidance.

*   https://azsupportdocs.azurewebsites.net/advisor/articles/score/ReliabilityScore.html#controls
````

---

## recommendationFriendlyName

*    Blocking: the maximum length is 60 characters.

*    Blocking: must be contiguous and readable with no punctuation. Underscore and dash are allowed.

### examples of recommendationFriendlyName

````markdown
The value of `recommendationFriendlyName` exceeds maximum length of 60 characters.
````

````markdown
The value of `recommendationFriendlyName` must be contiguous and readable with no punctuation; underscore and dash are allowed.

The maximum length is 60 characters.
````

---

## learnMoreLink

Acceptable links: `https://aka.ms/<sample_route>`  and `https://go.microsoft.com/fwlink`

*    Blocking: links that opens a generic page, like "Bing" or `https://www.microsoft.com` are not acceptable.

*    Blocking: links should not contain localization.

*    Should link to an article on learn platform that provides detailed explanation, instructions, or both for the recommendation.

### examples of learnMoreLink

````markdown
The value of `learnMoreLink` is missing.

The value of `learnMoreLink` must be a url to an article on Learn that provides detailed explanation, instructions, or both.
The value of `learnMoreLink` must be clean and free of localized metadata.

The value of `learnMoreLink` may be a `https://aka.ms` or `https://go.microsoft.com/fwlink` link.
````

````markdown
Remove locale from `learnMoreLink`.

The value of `learnMoreLink` must be clean and free of localized metadata.

> **Example**: <br />
> `...`
````

````markdown
Update the value of `learnMoreLink` to an article on Learn.

The value of `learnMoreLink` must be a url to an article on Learn that provides detailed explanation, instructions, or both.
````

````markdown
Update the value of `learnMoreLink` to a secure url.

> **Example**: <br />
> `https://...`
````

---

## description

> **IMPORTANT**: <br />
> The value of this field is published on the Learn platform.

Displayed in [description](https://azsupportdocs.azurewebsites.net/advisor/articles/AdvisorExperience.html "Advisor experience | Azure CXP Support Docs") column in the recommendation list view.

*    Blocking: the maximum length is 60 characters.

*    Should represent a condensed version of the longDescription property.

*    Should be specific and actionable. Use examples as a reference on [examples](https://azsupportdocs.azurewebsites.net/advisor/articles/CreateAdvisorRecommendations.html#examples "Examples - Creating Advisor recommendations | Azure CXP Support Docs").

### examples of description

````markdown
The value of `description` exceeds maximum length of 60 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `description` must use active voice, present tense, and be direct.
The value of `description` must be actionable and specific.

To review the examples of metadata for a recommendation, see [Examples](https://azsupportdocs.azurewebsites.net/advisor/articles/CreateAdvisorRecommendations.html#examples "Examples - Creating Advisor recommendations | Azure CXP Support Docs").

The maximum length for the value of `description` is 60 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `description` should be a condensed version of the value of `longDescription`.

The maximum length for the value of `description` is 60 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `description` is published on Learn and must meet the requirements for articles on Learn and Azure Advisor.

The value of `description` must follow the Microsoft style guidelines.

To learn more about the Microsoft style guidelines, see [Starting points](https://review.learn.microsoft.com/help/contribute/style-guide-hierarchy?branch=main#starting-points "Starting points - Use style guides for content on learn.microsoft.com | Documentation contributor guide | Microsoft Learn (main:review)").

The maximum length for the value of `description` is 60 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `description` must follow Microsoft Style and should not use `enable`.

*   https://styleguides.azurewebsites.net/Styleguide/Read?id=2696&topicid=31470

The maximum length for the value of `description` is 60 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `description` must follow Microsoft Style and should not use `disable`.

*   https://styleguides.azurewebsites.net/Styleguide/Read?id=2696&topicid=53839

The maximum length for the value of `description` is 60 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
Clarification.

```suggestion
    ...
```
````

---

## longDescription

> **IMPORTANT**: <br />
> The value of this field is published on the Learn platform.

Displayed in [recommendation detailed view](https://azsupportdocs.azurewebsites.net/advisor/articles/AdvisorExperience.html "Advisor experience | Azure CXP Support Docs").

*    Blocking: the maximum length is 300 characters.

*    Should bring clarity.

### examples of longDescription

````markdown
The value of `longDescription` exceeds maximum length of 300 characters.

```suggestion
    ...
```
````

````markdown
The `longDescription` must use active voice, present tense, and be direct.
The `longDescription` must be specific and easy to understand.

To review the examples of metadata for a recommendation, see [Examples](https://azsupportdocs.azurewebsites.net/advisor/articles/CreateAdvisorRecommendations.html#examples "Example - Creating Advisor recommendations | Azure CXP Support Docs").

The maximum length for the value of `longDescription` is 300 characters.

```suggestion
    ...
```
````

````markdown
Move consequence and benefit statements to `potentialBenefits`.

The maximum length for the value of `longDescription` is 300 characters.

```suggestion
    ...
```
````

````markdown
If you require additional steps or information for your recommendation, create a new article or update an existing article on Learn and add a `learnMoreLink` or `documentLink`.

The maximum length for the value of `longDescription` is 300 characters.

```suggestion
    ...
```
````

````markdown
The value of `longDescription` is published on Learn and must meet the requirements for articles on Learn and Azure Advisor.

The value of `longDescription` must follow the Microsoft style guidelines.

To learn more about the Microsoft style guidelines, see [Starting points](https://review.learn.microsoft.com/help/contribute/style-guide-hierarchy?branch=main#starting-points "Starting points - Use style guides for content on learn.microsoft.com | Documentation contributor guide | Microsoft Learn (main:review)").

The maximum length for the value of `longDescription` is 300 characters.

```suggestion
    ...
```
````

````markdown
The value of `longDescription` must follow Microsoft Style and should not use `enable`.

*   https://styleguides.azurewebsites.net/Styleguide/Read?id=2696&topicid=31470

The maximum length for the value of `longDescription` is 300 characters.

```suggestion
    ...
```
````

````markdown
The value of `longDescription` must follow Microsoft Style and should not use `disable`.

*   https://styleguides.azurewebsites.net/Styleguide/Read?id=2696&topicid=53839

The maximum length for the value of `longDescription` is 300 characters.

```suggestion
    ...
```
````

````markdown
Clarification.

```suggestion
  ...
```
````

---

## potentialBenefits

> **IMPORTANT**: <br />
> The value of this field is published on the Learn platform.

*    Blocking: the maximum length is 60 characters.

*    Should clearly articulate the advantage of implementing and disadvantage of not implementing the recommendation.

### examples of potentialBenefits

````markdown
The value of `potentialBenefits` exceeds maximum length of 60 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `potentialBenefits` should use active voice, present tense, and be direct.
The value of `potentialBenefits` should clearly articulate the advantage of implementing the recommendation and disadvantage of not implementing the recommendation.

To review the examples of metadata for a recommendation, see [Examples](https://azsupportdocs.azurewebsites.net/advisor/articles/CreateAdvisorRecommendations.html#examples "Example - Creating Advisor recommendations | Azure CXP Support Docs").

The maximum length for the value of `potentialBenefits` is 60 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `potentialBenefits` is published on Learn and must meet the requirements for articles on Learn and Azure Advisor.

The value of `potentialBenefits` should follow the Microsoft style guidelines.

To learn more about the Microsoft style guidelines, see [Starting points](https://review.learn.microsoft.com/help/contribute/style-guide-hierarchy?branch=main#starting-points "Starting points - Use style guides for content on learn.microsoft.com | Documentation contributor guide | Microsoft Learn (main:review)").

The maximum length for the value of `potentialBenefits` is 60 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
Clarification.

```suggestion
  ...
```
````

---

## displayLabel

Displayed as page title in recommendation detailed view on [Advisor Experience](https://azsupportdocs.azurewebsites.net/advisor/articles/AdvisorExperience.html "Advisor experience | Azure CXP Support Docs").

*    Blocking: The maximum length is 100 characters.

*    Should clearly identify the recommendation.

### examples of displayLabel

````markdown
The value of `displayLabel` exceeds maximum length of 100 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `displayLabel` must use active voice, present tense, and be direct.
The value of `displayLabel` must be actionable and specific. 
The value of `displayLabel` must clearly identify the recommendation.

The value of `displayLabel` should be similar to the value of `description`.

To review the examples of metadata for a recommendation, see [Examples](https://azsupportdocs.azurewebsites.net/advisor/articles/CreateAdvisorRecommendations.html#examples "Example - Creating Advisor recommendations | Azure CXP Support Docs").

The maximum length for the value of `potentialBenefits` is 100 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `displayLabel` should follow the Microsoft style guidelines.

To learn more about the Microsoft style guidelines, see [Starting points](https://review.learn.microsoft.com/help/contribute/style-guide-hierarchy?branch=main#starting-points "Starting points - Use style guides for content on learn.microsoft.com | Documentation contributor guide | Microsoft Learn (main:review)").

The maximum length for the value of `displayLabel` is 100 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `displayLabel` should follow Microsoft Style and should not use `enable`.

*   https://styleguides.azurewebsites.net/Styleguide/Read?id=2696&topicid=31470

The maximum length for the value of `displayLabel` is 100 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `displayLabel` should follow Microsoft Style and should not use `disable`.

*   https://styleguides.azurewebsites.net/Styleguide/Read?id=2696&topicid=53839

The maximum length for the value of `description` is 100 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
Clarification.

```suggestion
    ...
```
````

---

## costSavingInfo

*    Only applicable to cost recommendations with cost category

````markdown
The value of `costSavingInfo` is missing.

The `costSavingInfo` is required when value of`redommendationControl` is set to `cost`.
````

````markdown
Clarification.

```suggestion
    ...
```
````

---

## tip

*    Optional field

---
---

## actions

### actions > description

*    At least one action should be defined.

#### examples of description for action

````markdown
The value of `description` exceeds maximum length of 60 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `description` should use active voice, present tense, and be direct.
The value of `description` should be actionable and specific.

To review the examples of metadata for a recommendation, see [Examples](https://azsupportdocs.azurewebsites.net/advisor/articles/CreateAdvisorRecommendations.html#examples "Example - Creating Advisor recommendations | Azure CXP Support Docs").

The maximum length for the value of `description` is 60 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `description` should follow the Microsoft style guidelines.

To learn more about the Microsoft style guidelines, see [Starting points](https://review.learn.microsoft.com/help/contribute/style-guide-hierarchy?branch=main#starting-points "Starting points - Use style guides for content on learn.microsoft.com | Documentation contributor guide | Microsoft Learn (main:review)").

The maximum length for the value of `description` is 60 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `description` should follow Microsoft Style and should not use `enable`.

*   https://styleguides.azurewebsites.net/Styleguide/Read?id=2696&topicid=31470

The maximum length for the value of `description` is 60 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
The value of `description` should follow Microsoft Style and should not use `disable`.

*   https://styleguides.azurewebsites.net/Styleguide/Read?id=2696&topicid=53839

The maximum length for the value of `description` is 60 characters.

> **EXAMPLE**: <br />
> `...`
````

````markdown
Clarification.

```suggestion
    ...
```
````

---

### actions > documentLink

#### examples of documentLink for action

````markdown
The value of `documentLink` is missing.

The value of `documentLink` must be a url to an article on Learn that provides detailed explanation, instructions, or both.
The value of `documentLink` must be clean and free of localized metadata.

The value of `documentLink` may be a `https://aka.ms` or `https://go.microsoft.com/fwlink` link.
````

````markdown
Remove locale from `documentLink`.

The value of `documentLink` must be clean and free of localized metadata.

> **Example**: <br />
> `...`
````

````markdown
Update the value of `documentLink` to an article on Learn.

The value of `documentLink` must be a url to an article on Learn that provides detailed explanation, instructions, or both.
````

````markdown
Update the value of `documentLink` to a secure url.

> **Example**: <br />
> `https://...`
````

---
---

## Review summary

````markdown
Content review completed.
Please address feedback.
````
