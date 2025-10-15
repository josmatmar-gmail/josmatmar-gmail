#!/bin/bash
#
# author: github.com/jm-247-ms
# ms.author: v-martinjos@microsoft.com
#
# full-lastrun 2025.08.12
# ---
#
# list-lastrun 2025.08.06
# ---

set -euo pipefail

dateStamp=$(printf "%s" "$(date +%Y%b%d-%H%M)")

# userProfile="/home/v-martinjos" # linux
# userProfile="/Users/v-martinjos" # macOS
userProfile="/mnt/c/users/v-martinjos" # wsl

scriptDirectory="$userProfile/bash/scripts"
outputDirectory="$scriptDirectory/output"
outputIncludesDirectory="$outputDirectory/includes"

inputDirectory="$scriptDirectory/input"
temporaryDirectory="$scriptDirectory/temporary"

gitDirectory="$userProfile/git"

selfHelpContentDirectory="$gitDirectory/jm-247-ms/SelfHelpContent"
articlesSelfhelpcontentDirectory="$selfHelpContentDirectory/articles"

# learnAdvisorDirectory="$gitDirectory/jm-247-ms/azure-monitor-docs-pr/articles/advisor"
# includesAdvisorLearnDirectory="$learnAdvisorDirectory/includes"

outputDateRawLogTxt="$outputDirectory/$dateStamp-RAW-Log.txt"

# outputDateTestIncludeTxt="$outputIncludesDirectory/$dateStamp-test-include.txt"

temporaryDirectoryListTxt="$temporaryDirectory/$dateStamp-directoryList.txt"
temporaryMarkdownFilesTxt="$temporaryDirectory/$dateStamp-markdownFiles.txt"

# inputDirectoryDirectoryOutputTxt="$inputDirectory/directory-Output.txt"

outDateLearnSummaryTxt="$outputDirectory/$dateStamp-learn-summary.txt"

contentCreatedNote="This content is automatically generated using API calls to Azure. Any edits made on these files will be overwritten in the next run of the script."
learnLinkNote="For more information, see"

# guidPattern='^\{?[A-Z0-9a-z]{8}-[A-Z0-9a-z]{4}-[A-Z0-9a-z]{4}-[A-Z0-9a-z]{4}-[A-Z0-9a-z]{12}\}?$'
# integerPattern='^\{?[0-9]+\}?$'

authorArray=( "kapasrij" "kanika1894" )
# actionVerbsArray=( "add" "get" "output" "remove" "search" "set" "update" )
categoryArray=( "Cost" "HighAvailability" "OperationalExcellence" "Performance" )
headingArray=( "# " "## " "### " "#### " "##### " )
htmlCommentArray=( "<!--" "-->" "_begin" "_end" )
subCategoryArray=( "BusinessContinuity" "ComputeOptimization" "DataPerformance" "DisasterRecovery" "EfficiencyOptimization" "FailureMitigation" "HighAvailability" "MonitoringAndAlerting" "NetworkOptimization" "Other" "Personalized" "SafeAndSecureDeployment" "Scalability" "ServiceUpgradeAndRetirement" "StorageOptimization" "Validation" )
metadataArray=( "description" "displayLabel" "learnMoreLink" "longDescription" "potentialBenefits" "recommendationCategory" "recommendationImpact" "recommendationMetadataState" "recommendationResourceType" "recommendationSubCategory" "recommendationTypeId" )
stateArray=( "Active" "Disabled" )

recommendationFileList=( "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorecommendation.agrifood" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorecommendation.dlmfeature" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.CertificateRegistration" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.DomainRegistration" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.acceleratednetworking" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.apicenter" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.apimanagement" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.appservicestagingenv" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.attestation" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.automanage" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.avs" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.azurebackupservice" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.azurecli" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.azuredataexplorer" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.azurepowershell" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.azurespringcloud" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.azureupdatemanager" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.azureworkloads.epic" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.azureworkloadshub.ehr" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.azureworkloadshub.sap" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.batchbatchaccounts" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.cacheredis" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.capacityreservationordersreservations" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.cdn" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.classiccomputevirtualmachines" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.communicationservices" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.compute.sap" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.compute.sapmigratediscovery" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.computeavailabilitysets" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.computesnapshots" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.computevirtualmachines" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.computevirtualmachinesscaleset" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.containerapps" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.datafactoryfactoriespipelines" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.datafactoryfactoriestriggers" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.dbformariadbservers" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.dbformysqlflexibleservers" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.dbformysqlservers" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.dbforpostgresqlcitusservergroups" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.dbforpostgresqlflexibleservers" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.dbforpostgresqlservers" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.deid" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.documentdbdatabaseaccounts" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.ephemeralosdisk" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.expressroute" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.fleet" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.fluidrelay" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.hdinsight" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.highvmutilizationv0" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.hybridcompute" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.insightsscheduledqueryrules" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.iothubplatform" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.keyvault" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.keyvault.mhsm" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.languageservice" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.lowusagevmss" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.lowusagevmv2" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.manageddisksstorageaccount" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.managedservices" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.mediaservice" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.mocks" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.networkapplicationgateways" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.networkbastionhosts" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.networkexpressroutecircuits" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.networktrafficmanagerprofiles" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.networkvirtualappliances" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.networkvirtualnetworkgateways" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.networkwatcher" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.operationalexcellence.cga" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.premiumstorage" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.reservedinstancesreservedinstances" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.resiliencyhub" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.resourcemover" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.search" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.sqlserversdatabases" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.sqlsqldatawarehouses" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.sqlvirtualmachine" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.storagestorageaccounts" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.subscriptionssubscriptions" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.synapse" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.textanalytics" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.websites" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.workloadsmonitors" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/advisorrecommendation.wvd" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/cognitiveservices.immersivereader" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/microsoft.containerservice" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/microsoft.hdinsight-hilo" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/recommendationmetadata" "/mnt/c/users/v-martinjos/git/jm-247-ms/SelfHelpContent/articles/synthetics" )

trimPathForDisplay() {
    # string path tpfd_parameter_1

    outputToLogFile "\`> $ trimPathForDisplay() \"$1\"\`"

    tpfd_parameter_1="$1"

    tpfd_shortPath=$(printf "%s\n" "$tpfd_parameter_1" | cut -b $((${#userProfile}+1))-)

    printf "%s%s" "~" "$tpfd_shortPath"
}

outputToLogFile() {
    # string message otlf_parameter_1

    # printf "%s" "\`outputToLogFile() \"$1\"\` -->" >> "$outputDateRawLogTxt"

    otlf_parameter_1="$1"

    printf "%s\n" "$otlf_parameter_1" >> "$outputDateRawLogTxt"
}

outputFunctionToLogFile() {
    # string function oftlf_parameter_1

    local oftlf_parameter_1="$1"

    shift

    outputToLogFile "\`> $ $oftlf_parameter_1() \"$*\"\`"
}

showProgress() {
    # ----

    outputFunctionToLogFile "showProgress"

    local sp_progressTemp

    outputToLogFile "\`> $ sp_progressTemp=\"${progressArray[0]}\"\`"

    sp_progressTemp="${progressArray[0]}"

    printf "%s" "$sp_progressTemp"
}

checkCreateDirectory() {
    # string directory ccd_parameter_1

    outputToLogFile "\`checkCreateDirectory() \"$1\"\`"

    ccd_parameter_1="$1"

    outputToLogFile "\`> $ [ ! -d \"$ccd_parameter_1\" ]\`"

    if [ ! -d "$ccd_parameter_1" ]; then
        printf "\n%s\n" "\`$(trimPathForDisplay "$ccd_parameter_1")\` directory not found"

        outputToLogFile "\`> $ mkdir -p \"$ccd_parameter_1\"\`"

        mkdir -p "$ccd_parameter_1"
    else
        printf "\n%s\n" "\`$(trimPathForDisplay "$ccd_parameter_1")\` directory found"
    fi
}

requireParameterForFunction() {
    # Usage:
    #  requireParameterForFunction parameter_value parameter_name function_name
    #
    # string value of parameter rpff_parameter_1
    # string name of parameter rpff_parameter_2
    # string name of function rpff_paramter_3

    local rpff_parameter_1="${1:-}"
    local rpff_parameter_2="${2:-parameter}"
    local rpff_parameter_3="${3:-function}"

    if [[ -n "$rpff_parameter_1" ]]; then
        outputToLogFile "\`> $ $rpff_parameter_3() \"$rpff_parameter_1\": \"$rpff_parameter_2\" - \"$rpff_parameter_3\"\`"

        return 0
    else
        outputToLogFile "ERROR: \`requireParameterForFunction()\` \`$rpff_parameter_2\` not provided to \`$rpff_parameter_3\`"

        return 1
    fi
}

normalizeString() {
    # string input ns_parameter_1

    outputFunctionToLogFile "normalizeString" "$1"

    requireParameterForFunction "$1" "input" "normalizeString" || return 1

    ns_parameter_1="$1"

    ns_stringTemp="$(printf '%s' "$ns_parameter_1" | tr -cd '[:alnum:]_' | tr '[:upper:]' '[:lower:]')"

    printf '%s' "$ns_stringTemp"

    return 0
}

outputArrayNameFromMetadataValues() {
    # string category oanfmv_parameter_1
    # string resource type oanfmv_parameter_2
    # string state oanfmv_parameter_3

    outputFunctionToLogFile "outputArrayNameFromMetadataValues" "$1" "$2" "$3"

    requireParameterForFunction "$1" "recommendationCategory" "outputArrayNameFromMetadataValues" || return 1
    requireParameterForFunction "$2" "recommendationResourceType" "outputArrayNameFromMetadataValues" || return 1
    requireParameterForFunction "$3" "recommendationMetadataState" "outputArrayNameFromMetadataValues" || return 1

    local oanfmv_parameter_1="$1"
    local oanfmv_parameter_2="$2"
    local oanfmv_parameter_3="$3"

    local oanfmv_categoryCleanTemp
    local oanfmv_categoryPatternCleanTemp
    local oanfmv_outputValueTemp
    local oanfmv_resourceTypeCleanTemp
    local oanfmv_resourceTypePatternCleanTemp
    local oanfmv_metadataStateCleanTemp
    local oanfmv_metadataStatePatternCleanTemp

    oanfmv_categoryCleanTemp=$(normalizeString "$oanfmv_parameter_1")
    oanfmv_resourceTypeCleanTemp=$(normalizeString "$oanfmv_parameter_2")
    oanfmv_metadataStateCleanTemp=$(normalizeString "$oanfmv_parameter_3")
    oanfmv_outputValueTemp=""

    if [[ "$1" == "${loadCleanArray[0]}" ]] || [[ "$2" == "${loadCleanArray[0]}" ]] || [[ "$3" == "${loadCleanArray[0]}" ]]; then
        oanfmv_outputValueTemp="${loadCleanArray[0]}"
    elif [[ "$1" == "${loadCleanArray[1]}" ]] || [[ "$2" == "${loadCleanArray[1]}" ]] || [[ "$3" == "${loadCleanArray[1]}" ]]; then
        oanfmv_outputValueTemp="${loadCleanArray[1]}"
    elif [[ "$1" == "${loadCleanArray[4]}" ]] || [[ "$2" == "${loadCleanArray[4]}" ]] || [[ "$3" == "${loadCleanArray[4]}" ]]; then
        oanfmv_outputValueTemp="${loadCleanArray[4]}"
    else
        oanfmv_categoryPatternCleanTemp=" $oanfmv_categoryCleanTemp "
        oanfmv_resourceTypePatternCleanTemp=" $oanfmv_resourceTypeCleanTemp "
        oanfmv_metadataStatePatternCleanTemp=" $oanfmv_metadataStateCleanTemp "

        if [[ " ${recommendationCategoryCleanArray[*]} " =~ $oanfmv_categoryPatternCleanTemp ]]; then
            if [[ " ${recommendationResourceTypeCleanArray[*]} " =~ $oanfmv_resourceTypePatternCleanTemp ]]; then
                if [[ " ${recommendationMetadataStateCleanArray[*]} " =~ $oanfmv_metadataStatePatternCleanTemp ]]; then
                    oanfmv_outputValueTemp=$(printf "%s_%s_%s" "$oanfmv_categoryCleanTemp" "$oanfmv_resourceTypeCleanTemp" "$oanfmv_metadataStateCleanTemp")
                else
                    outputToLogFile "ERROR: \`$oanfmv_parameter_3\` not a valid metadata state for \`outputArrayNameFromMetadataValues()\`"

                    printf "%s" "nomatch"

                    return 1
                fi
            else
                outputToLogFile "ERROR: \`$oanfmv_parameter_2\` not a valid resource type for \`outputArrayNameFromMetadataValues()\`"

                printf "%s" "nomatch"

                return 1
            fi
        else
            outputToLogFile "ERROR: \`$oanfmv_parameter_1\` not a valid category for \`outputArrayNameFromMetadataValues()\`"

            printf "%s" "nomatch"

            return 1
        fi
    fi

    outputToLogFile "\`> $ \"$oanfmv_outputValueTemp\"\`"

    printf "%s" "$oanfmv_outputValueTemp"

    return 0
}

getArrayNameByMetadataKey() {
    # string category ganbmk_parameter_1
    # string resource type ganbmk_parameter_2
    # string metadata state ganbmk_parameter_3

    outputFunctionToLogFile "getArrayNameByMetadataKey" "$1" "$2" "$3"

    requireParameterForFunction "$1" "recommendationCategory" "getArrayNameByMetadataKey" || return 1
    requireParameterForFunction "$2" "recommendationResourceType" "getArrayNameByMetadataKey" || return 1
    requireParameterForFunction "$3" "recommendationMetadataState" "getArrayNameByMetadataKey" || return 1

    local ganbmk_parameter_1="$1"
    local ganbmk_parameter_2="$2"
    local ganbmk_parameter_3="$3"

    local ganbmk_arrayNameTemp
    
    ganbmk_arrayNameTemp=$(outputArrayNameFromMetadataValues "$ganbmk_parameter_1" "$ganbmk_parameter_2" "$ganbmk_parameter_3") || {
        outputToLogFile "ERROR: \`getArrayNameByMetadataKey()\` \`$ganbmk_parameter_1|$ganbmk_parameter_2|$ganbmk_parameter_3\` metadata key matrix is not valid"

        printf "%s" "nomatch"

        return 1
    }

    printf "%s" "$ganbmk_arrayNameTemp"

    return 0
}

getMetadataValueInFile() {
    # string file gmvif_parameter_1
    # string key gmvif_parameter_2

    outputToLogFile "\`getMetadataValueInFile() \"$1\" \"$2\"\`"

    gmvif_parameter_1="$1"
    gmvif_parameter_2="$2"

    outputToLogFile "\`> $ [ -f \"$gmvif_parameter_1\" ]\`"

    if [ -f "$gmvif_parameter_1" ]; then
        outputToLogFile "\`> $ gmvif_valueMetadata=\$(grep \"$gmvif_parameter_2\" \"$gmvif_parameter_1\" | cut -d '\"' -f 4)\`"

        gmvif_valueMetadata=$(grep "$gmvif_parameter_2" "$gmvif_parameter_1" | cut -d '"' -f 4)

        outputToLogFile "\`> $ \"$gmvif_valueMetadata\"\`"

        printf "%s" "${gmvif_valueMetadata:-nomatch}"
    else
        printf "%s" "nomatch"
    fi
}

getSubCategoryForCostByResourceType(){
    # string resource type gscfcbrt_parameter_1

    outputToLogFile "\`getSubCategoryForCostByResourceType() \"$1\"\`"

    local gscfcbrt_parameter_1="$1"

    case "$gscfcbrt_parameter_1" in
        "microsoft.web/sites")
            printf "%s" "app-service"
            ;;
        "microsoft.network/frontdoors")
            printf "%s" "application-gateway"
            ;;
        "microsoft.documentdb/databaseaccounts")
            printf "%s" "azure-cosmos-db"
            ;;
        "microsoft.kusto/clusters")
            printf "%s" "azure-data-explorer"
            ;;
        "microsoft.dbformysql/servers")
            printf "%s" "azure-database-for-mysql"
            ;;
        "microsoft.databricks/workspaces")
            printf "%s" "azure-databricks"
            ;;
        "microsoft.containerservice/managedclusters")
            printf "%s" "azure-kubernetes-service-(aks)"
            ;;
        "microsoft.operationalinsights/workspaces")
            printf "%s" "azure-monitor"
            ;;
        "microsoft.recoveryservices/vaults")
            printf "%s" "azure-site-recovery"
            ;;
        "microsoft.synapse/workspaces")
            printf "%s" "azure-synapse-analytics"
            ;;
        "microsoft.cognitiveservices/accounts")
            printf "%s" "cognitive-services"
            ;;
        "microsoft.cdn/profiles")
            printf "%s" "content-delivery-network"
            ;;
        "microsoft.datafactory/factories/pipelines")
            printf "%s" "data-factory"
            ;;
        "microsoft.capacity/reservationorders/reservations")
            printf "%s" "reservations"
            ;;
        "microsoft.storage/storageaccounts")
            printf "%s" "storage"
            ;;
        "microsoft.subscriptions/subscriptions")
            printf "%s" "subscriptions"
            ;;
        "microsoft.compute/disks")
            printf "%s" "virtual-machines"
            ;;
        *)
            printf "%s" "Other"
            ;;
    esac
}

encodeMetadataToString() {
    # string description emts_paramter_1
    # string displayLabel emts_paramter_2
    # string learnMoreLink emts_paramter_3
    # string longDescription emts_paramter_4
    # string potentialBenefits emts_paramter_5
    # string recommendationCategory emts_paramter_6
    # string recommendationImpact emts_paramter_7
    # string recommendationMetadataState emts_paramter_8
    # string recommendationResourceType emts_paramter_9
    # string recommendationSubCategory emts_paramter_10
    # string recommendationTypeId emts_paramter_11

    outputFunctionToLogFile "encodeMetadataToString"

    requireParameterForFunction "$1" "description" "encodeMetadataToString" || return 1
    requireParameterForFunction "$2" "displayLabel" "encodeMetadataToString" || return 1
    requireParameterForFunction "$3" "learnMoreLink" "encodeMetadataToString" || return 1
    requireParameterForFunction "$4" "longDescription" "encodeMetadataToString" || return 1
    requireParameterForFunction "$5" "potentialBenefits" "encodeMetadataToString" || return 1
    requireParameterForFunction "$6" "recommendationCategory" "encodeMetadataToString" || return 1
    requireParameterForFunction "$7" "recommendationImpact" "encodeMetadataToString" || return 1
    requireParameterForFunction "$8" "recommendationMetadataState" "encodeMetadataToString" || return 1
    requireParameterForFunction "$9" "recommendationResourceType" "encodeMetadataToString" || return 1
    requireParameterForFunction "${10}" "recommendationSubCategory" "encodeMetadataToString" || return 1
    requireParameterForFunction "${11}" "recommendationTypeId" "encodeMetadataToString" || return 1

    local -i emts_metadataKeyCount=${#metadataArray[@]}

    local emts_metadataValueArrayTemp=( "$@" )

    local emts_metadataKeyIndexTemp
    local emts_metadataValueTemp
    local emts_outputStringTemp

    emts_outputStringTemp=""

    if (( $# < emts_metadataKeyCount )); then
        outputToLogFile "ERROR: \`encodeMetadataToString()\` expects \`$emts_metadataKeyCount\` parameters, got \`$#\`"

        return 1
    fi

    for emts_metadataKeyTemp in "${!metadataArray[@]}"; do
        local emts_metadataKeyIndexTemp

        emts_metadataKeyIndexTemp=$((emts_metadataKeyTemp + 1))

        requireParameterForFunction "${emts_metadataValueArrayTemp[emts_metadataKeyTemp]}" "${metadataArray[emts_metadataKeyTemp]}" "encodeMetadataToString" || return 1
    done

    for (( emts_metadataKeyIndexTemp = 0; emts_metadataKeyIndexTemp < emts_metadataKeyCount; emts_metadataKeyIndexTemp++ )); do
        emts_metadataValueTemp="${emts_metadataValueArrayTemp[emts_metadataKeyIndexTemp]}"

        if (( emts_metadataKeyIndexTemp == 0 )); then
            emts_outputStringTemp="${emts_metadataValueTemp}"
        else
            emts_outputStringTemp="${emts_outputStringTemp}|${emts_metadataValueTemp}"
        fi
    done

    outputToLogFile "INFO: \`encodeMetadataToString()\` output: $emts_outputStringTemp"

    printf "%s" "$emts_outputStringTemp"

    return 0
}

addMetadataValuesInFile() {
    # string file gamvif_parameter_1

    outputFunctionToLogFile "addMetadataValuesInFile" "$1"

    requireFileExists "$1" "file" "addMetadataValuesInFile" || return 1

    local gamvif_parameter_1="$1"

    local -a amvif_metadataArray

    local amvif_recommendationTemp
    local amvif_recommendationCategoryCleanTemp
    local amvif_recommendationResourceTypeCleanTemp
    local amvif_recommendationMetadataStateCleanTemp

    amvif_shortFileNameTemp=$(trimPathForDisplay "$gamvif_parameter_1")

    amvif_metadataArray=()


    for amvif_indexTemp in "${!amvif_metadataArray[@]}"; do
        amvif_metadataArray[$amvif_indexTemp]=$(printf '%s\n' "${amvif_metadataArray[$amvif_indexTemp]}" | sed -n '1p' || true)
    done

    while (( ${#amvif_metadataArray[@]} < ${#metadataArray[@]} )); do
        amvif_metadataArray+=('')
    done

    for amvif_indexTemp in "${!amvif_metadataArray[@]}"; do
        outputToLogFile "\`${metadataArray[$amvif_indexTemp]}\` is \`${amvif_metadataArray[$amvif_indexTemp]}\`"
    done

    while (( ${#amvif_metadataArray[@]} < ${#metadataArray[@]} )); do
        amvif_metadataArray+=('')
    done

    amvif_recommendationTemp=$(encodeMetadataToString "${amvif_metadataArray[@]:0:11}")

    amvif_recommendationCategoryCleanTemp="$(normalizeString "${amvif_metadataArray[5]}")"
    amvif_recommendationResourceTypeCleanTemp="$(normalizeString "${amvif_metadataArray[8]}")"
    amvif_recommendationMetadataStateCleanTemp="$(normalizeString "${amvif_metadataArray[7]}")"

    if [[ "$amvif_recommendationCategoryCleanTemp" == "missing" || \
          "$amvif_recommendationResourceTypeCleanTemp" == "missing" || \
          "$amvif_recommendationMetadataStateCleanTemp" == "missing" ]]; then

        outputToLogFile "ERROR: \`addMetadataValuesInFile()\` Skipping \`$gamvif_parameter_1\` file due to missing essential metadata; \`recommendationCategory=\"$amvif_recommendationCategoryCleanTemp\"\`, \`recommendationResourceType=\"$amvif_recommendationResourceTypeCleanTemp\"\`, \`recommendationMetadataState=\"$amvif_recommendationMetadataStateCleanTemp\"\`"

        return 1
    fi

    ---

    showProgress
            
    amvif_recommendationCategoryTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[5]}")
    amvif_recommendationMetadataStateTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[7]}")
    amvif_recommendationResourceTypeTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[8]}")
    amvif_recommendationSubCategoryTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[9]}")

    if [[ "$amvif_recommendationCategoryTemp" == "${categoryArray[0]}" ]]; then
        amvif_recommendationSubCategoryTemp="$(getSubCategoryForCostByResourceType "$amvif_recommendationResourceTypeTemp")"
    fi

    if [[ "$amvif_recommendationSubCategoryTemp" == "${subCategoryArray[13]}" ]] && [[ "$amvif_recommendationMetadataStateTemp" == "${stateArray[0]}" ]]; then
        amvif_descriptionTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[0]}")
        amvif_learnMoreLinkTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[2]}")
        amvif_longDescriptionTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[3]}")
        amvif_potentialBenefitsTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[4]}")
        amvif_recommendationImpactTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[6]}")
        amvif_recommendationTypeIdTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[10]}")

        printf "%s\n" "$amvif_arrayNameSafe" >> "$temporaryDateRaw.metadataValueMatrix.txt"

        createBodyItem "$amvif_recommendationCategoryTemp" "$amvif_descriptionTemp" "$amvif_recommendationImpactTemp" "$amvif_longDescriptionTemp" "$amvif_potentialBenefitsTemp" "$amvif_recommendationResourceTypeTemp" "$amvif_recommendationSubCategoryTemp" "$amvif_recommendationTypeIdTemp" "$amvif_learnMoreLinkTemp"
    fi

    ---

    addValueToArray "$amvif_recommendationTemp" "$(getArrayNameByMetadataKey "$amvif_recommendationCategoryCleanTemp" "$amvif_recommendationResourceTypeCleanTemp" "$amvif_recommendationMetadataStateCleanTemp")"

    return 0
}

addValueToArray() {
    # Usage:
    #   addValueToArray avta_parameter_1 directory
    #   addValueToArray avta_parameter_1 learnAdvisor-avta_parameter_4
    #   addValueToArray avta_parameter_1 loadDirectory
    #   addValueToArray avta_parameter_1 selfHelpContent-avta_parameter_4
    #   addValueToArray avta_parameter_1 avta_parameter_2-avta_parameter_3-avta_parameter_4
    #
    # string value avta_parameter_1
    # string name of array avta_parameter_2

    outputFunctionToLogFile "addValueToArray" "$1" "$2"

    requireParameterForFunction "$1" "input" "addValueToArray" || return 1
    requireParameterForFunction "$2" "name of array" "addValueToArray" || return 1

    local avta_parameter_1="$1"
    local avta_parameter_2="$2"

    if [[ -z "$avta_parameter_2" || "$avta_parameter_2" == "nomatch" ]]; then
        outputToLogFile "ERROR: \`addValueToArray()\` \`$avta_parameter_2\` metadata key matrix is not valid"

        return 1
    fi

    if ! [[ "$avta_parameter_2" =~ $alphanumericPattern ]] && [[ "$avta_parameter_2" != "${loadCleanArray[0]}" ]] && [[ "$avta_parameter_2" != "${loadCleanArray[1]}" ]]; then
        outputToLogFile "ERROR: \`addValueToArray()\` \`$avta_parameter_2\` array name is not valid"

        return 1
    fi

    local avta_arrayNameSafe="${avta_parameter_2//-/_}"

    if [[ "$avta_parameter_2" != "${loadCleanArray[0]}" && "$avta_parameter_2" != "${loadCleanArray[1]}" ]]; then
        if ! declare -p arrayNameList >/dev/null 2>&1; then
            declare -g -a arrayNameList=()
        fi
    fi

    if ! declare -p "$avta_arrayNameSafe" >/dev/null 2>&1; then
        eval "declare -g -a $avta_arrayNameSafe=()"
    fi

    declare -n avta_destinationArray="$avta_arrayNameSafe"

    if ! printf '%s\n' "${avta_destinationArray[@]:-}" | grep -xFq -- "$avta_parameter_1"; then
        avta_destinationArray+=( "$avta_parameter_1" )
    fi

    mapfile -t avta_sortedArrayTemp < <(printf "%s\n" "${avta_destinationArray[@]:-}" | sed '/^$/d' | LC_ALL=C sort -u)

    setArrayByName "$avta_arrayNameSafe" "${avta_sortedArrayTemp[@]}"

    if [[ "$avta_parameter_2" != "${loadCleanArray[0]}" && "$avta_parameter_2" != "${loadCleanArray[1]}" ]]; then
        if ! printf '%s\n' "${arrayNameList[@]:-}" | grep -xFq -- "$avta_arrayNameSafe"; then
            arrayNameList+=( "$avta_arrayNameSafe" )

            printf "%s\n" "$avta_arrayNameSafe" >> "$temporaryDateRaw.arrayNameList.txt"
        fi
    fi

    printf "%s\n" "$avta_parameter_1" >> "$temporaryDateRaw.$avta_parameter_2.txt"

    unset avta_sortedArrayTemp

    return 0
}

searchFile() {
    # string file sf_parameter_1

    outputFunctionToLogFile "searchFile" "$1"

    requireFileExists "$1" "file" "searchFile" || return 1

    local sf_parameter_1="$1"

    local sf_checkRecommendationFile
    local sf_checkFileForValidMetadata
    local sf_directoryPathTemp

    showProgress

    # sf_shortFileNameTemp=$(trimPathForDisplay "$sf_parameter_1")

    # outputToConsole "Search \`$sf_shortFileNameTemp\` file for metadata keys and values"

    checkUniqueRecommendationFile "$sf_parameter_1" >/dev/null 2>&1 || {  outputToLogFile "ERROR: \`searchFile()\` \`$sf_parameter_1\` file  is not a valid recommendation"; return 0; }

    addMetadataValuesInFile "$sf_parameter_1" >/dev/null 2>&1 || { outputToLogFile "ERROR: \`searchFile()\` \`$sf_parameter_1\` file one or metadata values are missing or not valid"; return 0; }

    sf_directoryPathTemp=$(getPathForFile "$sf_parameter_1")

    addValueToArray "$sf_directoryPathTemp" "$(getArrayNameByMetadataKey "${loadCleanArray[0]}" "${loadCleanArray[0]}" "${loadCleanArray[0]}")"

   return 0
}

searchDirectory() {
    # string directory sd_parameter_1

    outputFunctionToLogFile "searchDirectory" "$1"

    requireDirectoryExists "$1" "${loadCleanArray[0]}" "searchDirectory" || {
        if [[ -f "$sd_parameter_1" ]]; then
            searchFile "$sd_parameter_1"

            return 0
        else
            outputToLogFile "ERROR: \`searchDirectory()\` \`$sd_parameter_1\` is not a valid directory or file"

            return 1
        fi
    }

    local sd_parameter_1="$1"

    local sd_shortFileName

    sd_shortFileName=$(trimPathForDisplay "$sd_parameter_1")

    outputToConsole "Search \`$sd_shortFileName\` ${loadCleanArray[0]}"

    for sd_fileTemp in "$sd_parameter_1"/*.md; do
        if [[ -f "$sd_fileTemp" ]]; then
            searchFile "$sd_fileTemp"
        else
            continue
        fi
    done

    return 0
}

captureContentMatrixFromFiles() {
    # ----

    outputToLogFile "\`captureContentMatrixFromFiles()\`"

    printf "%s" "Capturing content matrix from files."

    searchDirectory "$articlesSelfhelpcontentDirectory" || {
        outputToLogFile "ERROR: \`captureContentMatrixFromFiles()\` error capturing content matrix"

        printf "%s\n" "ERROR: Failed capturing content matrix."

        return 1
    }

    printf "\n%s\n" "Completed capturing content matrix."

    return 0
}

getWebPageTitle() {
    # string url gwpt_parameter_1

    outputToLogFile "\`> $ getWebPageTitle() \"$1\"\`"

    local gwpt_parameter_1="$1"

    gwpt_titleTemp=$(curl -s "$gwpt_parameter_1" | grep -o '<title>[^<]*' | sed 's/<title>//')

    printf "%s" "${gwpt_titleTemp:-nomatch}"
}

createHeader(){
    # string category ch_parameter_1
    # string subcategory ch_parameter_2

    outputToLogFile "\`createHeader() \"$1\" \"$2\"\`"

    local ch_parameter_1="$1"
    local ch_parameter_2="$2"

    local ch_date

    ch_date=$(date +%Y/%m/%d)

    ch_outputFileTemp="$outputIncludesDirectory/$ch_parameter_1/$ch_parameter_1-$ch_parameter_2.md"

    {
        printf "%s\n" "---"
        printf "%s: %s\n" "ms.service" "azure"
        printf "%s: %s\n" "ms.topic" "include"
        printf "%s: %s\n" "ms.date" "$ch_date"
        printf "%s: %s\n" "author" "${authorArray[1]}"
        printf "%s: %s\n" "ms.author" "${authorArray[0]}"
        printf "%s: %s %s\n" "ms.custom" "$ch_parameter_1" "$ch_parameter_2"
        printf "\n# %s: %s\n" "NOTE" "$contentCreatedNote"
        printf "\n%s\n" "---"
        printf "\n%s%s\n" "${headingArray[1]}" "$ch_parameter_2"
    } >> "$ch_outputFileTemp"
}

createBodyItem(){
    # string category cbi_parameter_1
    # string description cbi_parameter_2
    # string impact cbi_parameter_3
    # string long description cbi_parameter_4
    # string potential benefits cbi_parameter_5
    # string resource type cbi_parameter_6
    # string subcategory cbi_parameter_7
    # string type ID cbi_parameter_8
    # string learnmore url cbi_parameter_9

    outputToLogFile "\`createBodyItem() \"$1\" \"$2\" \"$3\" \"$4\" \"$5\" \"$6\" \"$7\" \"$8\" \"$9\"\`"

    local cbi_parameter_1="$1"
    local cbi_parameter_2="$2"
    local cbi_parameter_3="$3"
    local cbi_parameter_4="$4"
    local cbi_parameter_5="$5"
    local cbi_parameter_6="$6"
    local cbi_parameter_7="$7"
    local cbi_parameter_8="$8"
    local cbi_parameter_9="$9"

    local cbi_learnMoreLinkTempTitleTemp
    
    cbi_learnMoreLinkTempTitleTemp=$(getWebPageTitle "$cbi_parameter_8")

    local cbi_outputFileTemp="$outputIncludesDirectory/$cbi_parameter_1/$cbi_parameter_1-$cbi_parameter_7.md"


    {
        printf "\n%s%s%s%s\n" "${htmlCommentArray[0]}" "$cbi_parameter_8" "${htmlCommentArray[2]}" "${htmlCommentArray[1]}"
        printf "\n%s%s\n" "${headingArray[3]}" "$cbi_parameter_2"
        printf "\n%s\n" "$cbi_parameter_4"
        printf "\n**%s**: %s\n" "Potential benefits" "$cbi_parameter_5"
        printf "\n**%s**: %s\n" "Impact" "$cbi_parameter_3"
        printf "\n%s [%s](%s).\n" "$learnLinkNote" "$cbi_learnMoreLinkTempTitleTemp" "$cbi_parameter_9"
        printf "\n%s: %s\n" "ResourceType" "$cbi_parameter_6"
        printf "\n%s: %s\n" "Recommendation ID" "$cbi_parameter_8"
        printf "\n%s: %s\n" "Subcategory" "$cbi_parameter_7"
        printf "\n%s%s%s%s\n" "${htmlCommentArray[0]}" "$cbi_parameter_8" "${htmlCommentArray[3]}" "${htmlCommentArray[1]}"
    } >> "$cbi_outputFileTemp"
}

createBody() {
    # string category cb_parameter_1
    # string subcategory cb_parameter_2

    outputToLogFile "\`createBody() \"$1\" \"$2\" \`"

    cb_parameter_1="$1"
    cb_parameter_2="$2"

    for cbi_fileTemp in "${recommendationFileList[@]}/"*; do
        printf "%s" "."
            
        cb_recommendationCategoryTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[5]}")
        cb_recommendationMetadataStateTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[7]}")
        cb_recommendationResourceTypeTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[8]}")
        
        if [[ "$cb_parameter_1" == "${categoryArray[0]}" ]]; then
            cb_recommendationSubCategoryTemp="$(getSubCategoryForCostByResourceType "$cb_recommendationResourceTypeTemp")"
        else
            cb_recommendationSubCategoryTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[9]}")
        fi  

        if [[ "$cb_recommendationCategoryTemp" == "$cb_parameter_1" ]] && [[ "$cb_recommendationSubCategoryTemp" == "${subCategoryArray[13]}" ]] && [[ "$cb_recommendationMetadataStateTemp" == "${stateArray[0]}" ]]; then
            cb_descriptionTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[0]}")
            cb_learnMoreLinkTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[2]}")
            cb_longDescriptionTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[3]}")
            cb_potentialBenefitsTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[4]}")
            cb_recommendationImpactTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[6]}")
            cb_recommendationTypeIdTemp=$(getMetadataValueInFile "$cbi_fileTemp" "${metadataArray[10]}")

            createBodyItem "$cb_recommendationCategoryTemp" "$cb_descriptionTemp" "$cb_recommendationImpactTemp" "$cb_longDescriptionTemp" "$cb_potentialBenefitsTemp" "$cb_recommendationResourceTypeTemp" "$cb_recommendationSubCategoryTemp" "$cb_recommendationTypeIdTemp" "$cb_learnMoreLinkTemp"
        fi
    done
}

createFooter(){
    # string category cf_parameter_1
    # string subcategory cf_parameter_2

    outputToLogFile "\`createFooter() \"$1\" \"$2\"\`"

    cf_parameter_1="$1"
    cf_parameter_2="$2"

    cf_outputFileTemp="$outputIncludesDirectory/$cf_parameter_1/$cf_parameter_1-$cf_parameter_2.md"

    printf "\n%s%s%s\n" "${htmlCommentArray[0]}" "articleBody" "${htmlCommentArray[1]}" >> "$cf_outputFileTemp"
}

createIncludeFile() {
    # string category cif_parameter_1
    # string subcategory cif_parameter_2

    outputToLogFile "\`createIncludeFile() \"$1\" \"$2\"\`"

    local cif_parameter_1="$1"
    local cif_parameter_2="$2"

    createHeader "$cif_parameter_1" "$cif_parameter_2"

    createBody "$cif_parameter_1" "$cif_parameter_2"

    createFooter "$cif_parameter_1" "$cif_parameter_2"
        
}

outputIncludeFilesByCategorySubCategory() {
    # ----

    outputToLogFile "\`outputIncludeFilesByCategorySubCategory()\`"

    for oifbcsc_categoryTemp in "${categoryArray[@]}"; do
        printf "%s" "."

        checkCreateDirectory "$outputIncludesDirectory/$oifbcsc_categoryTemp"

        if [[ "$oifbcsc_categoryTemp" == "${categoryArray[0]}" ]]; then
            createIncludeFile "$oifbcsc_categoryTemp" "${subCategoryArray[9]}"
        else
            for oifbcsc_subcategoryTemp in "${subCategoryArray[@]}"; do
                printf "%s" "."

                createIncludeFile "$oifbcsc_categoryTemp" "$oifbcsc_subcategoryTemp"
            done
        fi
    done
}

main() {
    local durationEpochTime
    local endEpochTime
    local endTime
    local startEpochTime
    local startTime

    startEpochTime="$(date +%s)"
    startTime="$(date +%Y%b%d-%H%M)"

    checkCreateDirectory "$inputDirectory"
    checkCreateDirectory "$outputDirectory"
    checkCreateDirectory "$temporaryDirectory"

    captureContentMatrixFromFiles

    #outputIncludeFilesByCategorySubCategory

    endEpochTime="$(date +%s)"
    endTime="$(date +%Y%b%d-%H%M)"

    ((durationEpochTime=endEpochTime-startEpochTime))

    outputToLogFile "Completed \`$startTime\` to \`$endTime\` = \`$durationEpochTime\` seconds"

    printf "\n%s\n" "Completed \`$startTime\` to \`$endTime\` = \`$durationEpochTime\` seconds"
}

time main
