# Update include files from source

Update include files for `articles/advisor/includes/retiring-feature` directory

## Save data

1.  Save file as tab-delimited file format.

## Format data

1.  Open .txt file in Visual Studio Code.

1.  Search and replace one time

    ```search
    ^(.+)\t(.+)\t(.+)\t(.+)\t(.+)\t(.+)\t(.+)\t
    ```

    ```replace
    sol - $3 | $1 | $2 | $3 | $4 | - eol
    ```

1.  Search and replace one time

    ```search
    ^(.+)\t(.+)\t(.+)\t(.+)\t(.+)\t(.+)\t
    ```

    ```replace
    sol - $3 | $1 | $2 | $3 | $4 | - eol
    ```

1.  Search and replace.

    ```search
    ((eol(.+)$(\n((?!sol).)+$)+)|(eol$(\n((?!sol).)+$)+)|(eol(.+)$))
    ```

    ```replace
    eol
    ```

1.  Search and replace until no results.

    ```search
    ^(.+) \| (.+) \| Support for TLS 1.0 and 1.1 \| (.+) \| (.+)\| (.+)$
    ```

    ```replace
    $1 | $2 | Support for TLS 1.0 | $3 | $4 | $5
    $1 | $2 | Support for TLS 1.1 | $3 | $4 | $5
    ```

    Verify the separation and clean-up the feature names.

1.  Search and replace one time.

    ```search
    ^(.+) \| (.+) \| "(.+)(, and |, )(.+)" \| (.+) \| (.+) \| (.+)$
    ```

    ```replace
    $1 | $2 | $3 | $6 | $7 | $8
    $1 | $2 | $5 | $6 | $7 | $8
    ```

    Verify the separation and clean-up the feature names.

1.  Search and replace until no valid results.

    ```search
    ^(.+) \| (.+) \| (.+)(; |, |. | &  | and )(.+) \| (.+) \| (.+) \| (.+)$
    ```

    ```replace
    $1 | $2 | $3 | $5 | $6 | $7
    $1 | $2 | $4 | $5 | $6 | $7
    ```

    Verify the separation and clean-up the feature names.

1.  Search and remove.

    ```search
    (�)
    ```

    ```replace
    ```

1.  Replace date format.

    1.  Search and replace one time.

        ```search
        \|\s(\d{4})-01-(0[1-9]|[12][0-9]|3[01])\s\|
        ```

        ```replace
        | January $2, $1 |
        ```

    1.  Search and replace one time.

        ```search
        \|\s(\d{4})-02-(0[1-9]|[12][0-9]|3[01])\s\|
        ```

        ```replace
        | February $2, $1 |
        ```

    1.  Search and replace one time.

        ```search
        \|\s(\d{4})-03-(0[1-9]|[12][0-9]|3[01])\s\|
        ```

        ```replace
        | March $2, $1 |
        ```

    1.  Search and replace one time.

        ```search
        \|\s(\d{4})-04-(0[1-9]|[12][0-9]|3[01])\s\|
        ```

        ```replace
        | April $2, $1 |
        ```

    1.  Search and replace one time.

        ```search
        \|\s(\d{4})-05-(0[1-9]|[12][0-9]|3[01])\s\|
        ```

        ```replace
        | May $2, $1 |
        ```

    1.  Search and replace one time.

        ```search
        \|\s(\d{4})-06-(0[1-9]|[12][0-9]|3[01])\s\|
        ```

        ```replace
        | June $2, $1 |
        ```

    1.  Search and replace one time.

        ```search
        \|\s(\d{4})-07-(0[1-9]|[12][0-9]|3[01])\s\|
        ```

        ```replace
        | July $2, $1 |
        ```

    1.  Search and replace one time.

        ```search
        \|\s(\d{4})-08-(0[1-9]|[12][0-9]|3[01])\s\|
        ```

        ```replace
        | August $2, $1 |
        ```

    1.  Search and replace one time.

        ```search
        \|\s(\d{4})-09-(0[1-9]|[12][0-9]|3[01])\s\|
        ```

        ```replace
        | September $2, $1 |
        ```

    1.  Search and replace one time.

        ```search
        \|\s(\d{4})-10-(0[1-9]|[12][0-9]|3[01])\s\|
        ```

        ```replace
        | October $2, $1 |
        ```

    1.  Search and replace one time.

        ```search
        \|\s(\d{4})-11-(0[1-9]|[12][0-9]|3[01])\s\|
        ```

        ```replace
        | November $2, $1 |
        ```

    1.  Search and replace one time.

        ```search
        \|\s(\d{4})-12-(0[1-9]|[12][0-9]|3[01])\s\|
        ```

        ```replace
        | December $2, $1 |
        ```

1.  Add check marks.

    1.  Search and replace one time.

        ```search
        \|\sYes\s\|
        ```

        ```replace
        | :white_check_mark: |
        ```

    1.  Search and replace one time.

        ```search
        \|\sNo\s\|
        ```

        ```replace
        |  |
        ```

1.  Search and replace one time.

    ```search
    ^sol - (.+) - eol$
    ```

    ```replace
    $1
    ```

1.  Search and replace one time.

    ```search
    ^(.+)\| Service Name \| Retiring Feature \| Date \| Impacted resources available\? \|
    ```

    ```replace
    $1 | Service name | Retiring feature | Date | Impacted resources available? |
    $1 |:--- |:--- |:--- |:--- |
    ```

## Filter content for each year and month combination

1.  Search for earliest date. `01` and `2025` are used as an example.

    ```search
    ^2025-01
    ```

1.  Create new file using `yyyy` and `mm` format in a temporary directory. `01`, and `2025` are used as an example.

    ```file
    retirement-date-2025-01.md
    ```

1.  Copy content.

1.  Search and remove, match the combination of `yyyy` and `mm` used for the file. `01` and `2025` are used as an example.

    ```search
    ^(?=20)(?:(?!25-01).)*$
    ```

    ```replace
    ```

1.  Group retiring features and **Impacted resources available?** under service name.

    1.  Example of two features.

        ```search
        | Virtual Machines | Standard_M192is_v2 | March 31, 2027 | :white_check_mark: |
        | Virtual Machines | Standard_M192ims_v2 | March 31, 2027 | :white_check_mark: |
        ```

        ```replace
        | Virtual Machines | Standard_M192is_v2 <br />&#9492; Standard_M192ims_v2 | March 31, 2027 | :white_check_mark: |
        ```

    1.  Example of more than 2 features.

        ```search
        | Virtual Machines | Standard_NC6s_v3 | September 30, 2025 |  |
        | Virtual Machines | Standard_NC12s_v3 | September 30, 2025 |  |
        | Virtual Machines | Standard_NC24s_v3 | September 30, 2025 |  |
        ```

        ```replace
        | Virtual Machines | Standard_NC6s_v3 <br />&#9500; Standard_NC12s_v3 <br />&#9492; Standard_NC24s_v3 | September 30, 2025 |  |
        ```

1.  Search and remove the content only used to filter.

    ```search
    ^(.+)\|(.+)\|(.+)\|(.+)\|(.+)\|$
    ```

    ```replace
    |$2|$3|$4|$5|
    ```

## Replace include files

!.  Remove all files in `articles/advisor/includes/retiring-feature` directory.

1.  Move all files from temporary directory to `articles/advisor/includes/retiring-feature` directory.

## Update articles/advisor/advisor-how-to-use-service-retirement-upgrade-recommendations

1.  Open `advisor-how-to-use-service-retirement-upgrade-recommendations.md` in the `articles/advisor` directory.

1.  Under the **Coverage of services** section, replace the content.

    The format for the year. `2025` is used as an example.

    ```markdown
    
    ### [Retiring in 2025](#tab/service-retire-2025)
    
    ```

    The format for each month abd year under each year. `January`, `01`, and `2025` are used as an example.

    ```markdown
    
    #### Retiring January 2025
    
    [!INCLUDE [Table for retiring January 2025](./includes/retiring-feature/retirement-date-2025-01.md)]
    
    ```

1.  Verify the content correctly ends.

    ```markdown
    
    ---
    
    ```
