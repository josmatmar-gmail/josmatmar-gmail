# Task add an action

## Locate the recommendation

1.  In **Supportability Hub**, on **Solution management** > **Azure advisor**.

    1.  In the **Search by keyword** text box, enter the `recommendationFriendlyName` or `description` of the recommendation.

    See [View a recommendation using Supportability Hub](https://azsupportdocs.azurewebsites.net/advisor/articles/SupportabilityHubViewRecommendation.html).

## Update the recommendation

1.  Update the following text boxes with the following values.

    | Key | Value |
    |:--- |:--- |
    | Entension name | `HubsExtension` |
    | Blade name | `ResourceMenuBlade` |
    | Blade parameter | `{"id":"{resourceId}"}` |

    See [Create a recommendation](https://azsupportdocs.azurewebsites.net/advisor/articles/SupportabilityHubCreateRecommendation.html#create-a-recommendation), Section 3.1.15.1 to Section 3.1.15.3.

1.  Update the following drop-down menus and text boxes with the following values.

    | Key | Value |
    |:--- |:--- |
    | Select cloud environment(s) where you want to add action | `all` |
    | Action description | `Buy a reservation` |
    | Select action type | `Document` |
    | Document link for action | `https://aka.ms/aa_ri_instructions` |

    See [Create a recommendation](https://azsupportdocs.azurewebsites.net/advisor/articles/SupportabilityHubCreateRecommendation.html#create-a-recommendation), Section 4.1 to Section 4.4.

1.  Select **Validate**.

1.  Select **Submit**.
