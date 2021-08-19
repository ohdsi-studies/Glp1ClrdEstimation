# STEP 0: (If necessary) In the top-right panel in RStudio, select the "Environment" tab and then click the broom icon to clear the environment

# STEP 1: Run the renv command below to install the correct versions of all necessary package dependencies
# renv::restore()

# STEP 2: If necessary, install the keyring package so you can call your username and password when creating the connectionDetails object
#install.packages("keyring")

# STEP 3: In the top-right panel in RStudio, select the "Build" tab and then click "Install and Restart". Confirm the build executes without error.
# will repeat step 3 for each database execution

# STEP 4: Load the relevant libraries 
library(keyring)
library(HERMESp1Hydra)

# STEP 5: revise the settings below to correspond to your local environment (notes provided below)

# STEP 5a: specify where the temporary files (used by the Andromeda package) will be created:
options(andromedaTempFolder = "D:/andromedaTemp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()

# STEP 5b: The folder where the study intermediate and result files will be written:
outputFolder <- "D:/StudyResults/GLP1Repro/CohortMethod/HERMESp1Hydra"

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

# STEP 5e: The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "scratch_mconove1" # change to your scratch space
cohortTable <- "HERMESp1Hydra_v1_TruvenCCAE" #Revise cohortTable name to refer to the specific DB being run

# STEP 5f: Some DB-specific meta-information that will be used by the export function:
databaseId <- "TruvenCCAE"
databaseName <- "IBM Commercial Claims and Encounters (CCAE) v1676)"
databaseDescription <- "IBM Commercial Claims and Encounters (CCAE) v1676"

# For some database platforms (e.g. Oracle): define a schema that can be used to emulate temp tables:
options(sqlRenderTempEmulationSchema = NULL)
oracleTempSchema <- NULL

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        oracleTempSchema = oracleTempSchema,
        outputFolder = outputFolder,
        databaseId = databaseId,
        databaseName = databaseName,
        databaseDescription = databaseDescription,
        verifyDependencies = TRUE,
        createCohorts = TRUE,
        synthesizePositiveControls = FALSE,
        runAnalyses = FALSE,
        packageResults = FALSE,
        maxCores = maxCores)


#Revise TAR in cohorts so that we censor when TAR > 365
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

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = paste0(cohortTable,"_TAR365"),
        oracleTempSchema = oracleTempSchema,
        outputFolder = outputFolder,
        databaseId = databaseId,
        databaseName = databaseName,
        databaseDescription = databaseDescription,
        verifyDependencies = TRUE,
        createCohorts = FALSE,
        synthesizePositiveControls = FALSE,
        runAnalyses = TRUE,
        packageResults = TRUE,
        maxCores = maxCores)


# resultsZipFile <- file.path(outputFolder, "export", paste0("Results_", databaseId, ".zip"))
# dataFolder <- file.path(outputFolder, "shinyData")
# 
# # You can inspect the results if you want:
# prepareForEvidenceExplorer(resultsZipFile = resultsZipFile, dataFolder = dataFolder)
#launchEvidenceExplorer(dataFolder = dataFolder, blind = TRUE, launch.browser = FALSE)

# Upload the results to the OHDSI SFTP server:
# privateKeyFileName <- ""
# userName <- ""
# uploadResults(outputFolder, privateKeyFileName, userName)
