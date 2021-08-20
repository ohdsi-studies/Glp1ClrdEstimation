# STEP 0: (If necessary) In the top-right panel in RStudio, select the "Environment" tab and then click the broom icon to clear the environment

# STEP 1: Run the renv command below to install the correct versions of all necessary package dependencies
# renv::restore()

# STEP 2: If necessary, install the keyring package so you can call your username and password when creating the connectionDetails object
#install.packages("keyring")

# STEP 3: In the top-right panel in RStudio, select the "Build" tab and then click "Install and Restart". Confirm the build executes without error.
# will repeat step 3 for each database execution

# STEP 4: Load the relevant libraries 
library(keyring)
library(HERMESp4Hydra)

# STEP 5: revise the settings below to correspond to your local environment (notes provided below)

# STEP 5a: specify where the temporary files (used by the Andromeda package) will be created:
options(andromedaTempFolder = "D:/andromedaTemp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()

# STEP 5b: The folder where the study intermediate and result files will be written:
outputFolder <- "D:/StudyResults/GLP1Repro/CohortMethod/HERMESp4Hydra"

# STEP 5c: Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(
        dbms = "redshift",
        user = keyring::key_get("redShiftUserName"),
        password = keyring::key_get("redShiftPassword"),
        port = 5439,
        server = "ohda-prod-1.cldcoxyrkflo.us-east-1.redshift.amazonaws.com/truven_ccae", # change DB extension to refer to the DB you want to analyze
        extraSettings = "ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory"
)

# STEP 5d: The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- "cdm_truven_ccae_v1676"
#cdmDatabaseSchema <- "cdm_optum_extended_dod_v1679"
#cdmDatabaseSchema <- "cdm_truven_mdcd_v1561"
#cdmDatabaseSchema <- "cdm_optum_ehr_v1562"
#cdmDatabaseSchema <- "cdm_iqvia_pharmetrics_plus_v1670"
#cdmDatabaseSchema <- "cdm_truven_mdcr_v1692"
#cdmDatabaseSchema <- "cdm_jmdc_v1678"

# STEP 5e: The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "scratch_mconove1" # change to your scratch space
cohortTable <- "HERMES_p4_TruvenCCAE" #Revise cohortTable name to refer to the specific DB being run
#cohortTable <- "HERMES_p4_OptumDOD" #Revise cohortTable name to refer to the specific DB being run
#cohortTable <- "HERMES_p4_TruvenMDCD" #Revise cohortTable name to refer to the specific DB being run
#cohortTable <- "HERMES_p4_OptumEHR" #Revise cohortTable name to refer to the specific DB being run
#cohortTable <- "HERMES_p4_PharmetricsPlus" #Revise cohortTable name to refer to the specific DB being run
#cohortTable <- "HERMES_p4_TruvenMDCR" #Revise cohortTable name to refer to the specific DB being run
#cohortTable <- "HERMES_p4_JMDC" #Revise cohortTable name to refer to the specific DB being run


# STEP 5f: Some DB-specific meta-information that will be used by the export function:
databaseId <- "TruvenCCAE"
databaseName <- "IBM Commercial Claims and Encounters (CCAE) v1676)"
databaseDescription <- "IBM Commercial Claims and Encounters (CCAE) v1676"
# databaseId <- "OptumDOD"
# databaseName <- "Optum Clinformatics Extended Data Mart - Date of Death (DOD) v1679"
# databaseDescription <- "Optum Clinformatics Extended Data Mart - Date of Death (DOD) v1679"
# databaseId <- "TruvenMDCD"
# databaseName <- "IBM MarketScan Multi-State Medicaid (MDCD) v1561"
# databaseDescription <- "IBM MarketScan Multi-State Medicaid (MDCD) v1561"
# databaseId <- "OptumEHR"
# databaseName <- "Optum Pan-Therapeutic Electronic Health Records (OptumEHR) v1562"
# databaseDescription <- "Optum Pan-Therapeutic Electronic Health Records (OptumEHR) v1562"
# databaseId <- "PharmetricsPlus"
# databaseName <- "IQVIA Adjudicated Health Plan Claims (PharmetricsPlus) v1670"
# databaseDescription <- "IQVIA Adjudicated Health Plan Claims (PharmetricsPlus) v1670"
# databaseId <- "TruvenMDCR"
# databaseName <- "IBM MarketScan Medicare Supplemental (v1692)"
# databaseDescription <- "IBM MarketScan Medicare Supplemental (v1692)"
# databaseId <- "JMDC"
# databaseName <- "Japan Medical Data Center (JMDC)"
# databaseDescription <- "Japan Medical Data Center (JMDC)"

# For some database platforms (e.g. Oracle): define a schema that can be used to emulate temp tables:
options(sqlRenderTempEmulationSchema = NULL)
oracleTempSchema <- NULL

# Create subdirectory for the results specific to this database
dbOutputFolder <- file.path(outputFolder,databaseId)
if (!file.exists(dbOutputFolder)) {
        dir.create(dbOutputFolder, recursive = TRUE)
}

# Build cohorts
execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        oracleTempSchema = oracleTempSchema,
        outputFolder = dbOutputFolder,
        databaseId = databaseId,
        databaseName = databaseName,
        databaseDescription = databaseDescription,
        verifyDependencies = TRUE,
        createCohorts = TRUE,
        synthesizePositiveControls = FALSE,
        runAnalyses = FALSE,
        packageResults = FALSE,
        maxCores = maxCores)


#Revise the cohortTable in order to censor when TAR > 365
targCompList <- read.csv(file.path(getwd(),"inst/settings/TcosOfInterest.csv"))
targCompList <- c(unique(targCompList$targetId),unique(targCompList$comparatorId))

sql <- "select cohort_definition_id, subject_id, cohort_start_date,
               case when cohort_definition_id in @targCompList and datediff(days,cohort_start_date,cohort_end_date) > 365
                    then to_date(cast(dateadd(days,365,cohort_start_date) as TEXT),'YYYY-MM-DD')
                    else cohort_end_date end as cohort_end_date
               into @cohortDatabaseSchema.@cohortTable_TAR365
               from @cohortDatabaseSchema.@cohortTable;"

DatabaseConnector::renderTranslateExecuteSql(DatabaseConnector::connect(connectionDetails),
                                             sql,
                                             targCompList = paste0("(",paste0(targCompList,collapse=","),")"),
                                             cohortDatabaseSchema = cohortDatabaseSchema,
                                             cohortTable = cohortTable)
targCompList <- NULL

#Execute analyses

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = paste0(cohortTable,"_TAR365"),
        oracleTempSchema = oracleTempSchema,
        outputFolder = dbOutputFolder,
        databaseId = databaseId,
        databaseName = databaseName,
        databaseDescription = databaseDescription,
        verifyDependencies = TRUE,
        createCohorts = FALSE,
        synthesizePositiveControls = FALSE,
        runAnalyses = TRUE,
        packageResults = TRUE,
        maxCores = maxCores)


# resultsZipFile <- file.path(dbOutputFolder, "export", paste0("Results_", databaseId, ".zip"))
# dataFolder <- file.path(outputFolder, "shinyData")
# 
# # You can inspect the results if you want:
# prepareForEvidenceExplorer(resultsZipFile = resultsZipFile, dataFolder = dataFolder)
#launchEvidenceExplorer(dataFolder = dataFolder, blind = TRUE, launch.browser = FALSE)

# Upload the results to the OHDSI SFTP server:
# privateKeyFileName <- ""
# userName <- ""
# uploadResults(outputFolder, privateKeyFileName, userName)
