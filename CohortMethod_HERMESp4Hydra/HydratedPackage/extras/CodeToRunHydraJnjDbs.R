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
        server = "ohda-prod-1.cldcoxyrkflo.us-east-1.redshift.amazonaws.com/iqvia_pharmetrics_plus", # change DB extension to refer to the DB you want to analyze
        extraSettings = "ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory"
)

# STEP 5d: The name of the database schema where the CDM data can be found:
#cdmDatabaseSchema <- "cdm_truven_ccae_v1676"
#cdmDatabaseSchema <- "cdm_optum_extended_dod_v1679"
#cdmDatabaseSchema <- "cdm_truven_mdcd_v1561"
#cdmDatabaseSchema <- "cdm_optum_ehr_v1562"
cdmDatabaseSchema <- "cdm_iqvia_pharmetrics_plus_v1500"
#cdmDatabaseSchema <- "cdm_truven_mdcr_v1692"
#cdmDatabaseSchema <- "cdm_jmdc_v1678"

# STEP 5e: The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "scratch_mconove1" # change to your scratch space
#cohortTable <- "HERMES_p4_TruvenCCAE" #Revise cohortTable name to refer to the specific DB being run
#cohortTable <- "HERMES_p4_OptumDOD" #Revise cohortTable name to refer to the specific DB being run
#cohortTable <- "HERMES_p4_TruvenMDCD" #Revise cohortTable name to refer to the specific DB being run
#cohortTable <- "HERMES_p4_OptumEHR" #Revise cohortTable name to refer to the specific DB being run
cohortTable <- "HERMES_p4_PharmetricsPlus" #Revise cohortTable name to refer to the specific DB being run
#cohortTable <- "HERMES_p4_TruvenMDCR" #Revise cohortTable name to refer to the specific DB being run
#cohortTable <- "HERMES_p4_JMDC" #Revise cohortTable name to refer to the specific DB being run


# STEP 5f: Some DB-specific meta-information that will be used by the export function:
# databaseId <- "TruvenCCAE"
# databaseName <- "IBM Commercial Claims and Encounters (CCAE) v1676)"
# databaseDescription <- "IBM Commercial Claims and Encounters (CCAE) v1676"
# databaseId <- "OptumDOD"
# databaseName <- "Optum Clinformatics Extended Data Mart - Date of Death (DOD) v1679"
# databaseDescription <- "Optum Clinformatics Extended Data Mart - Date of Death (DOD) v1679"
# databaseId <- "TruvenMDCD"
# databaseName <- "IBM MarketScan Multi-State Medicaid (MDCD) v1561"
# databaseDescription <- "IBM MarketScan Multi-State Medicaid (MDCD) v1561"
# databaseId <- "OptumEHR"
# databaseName <- "Optum Pan-Therapeutic Electronic Health Records (OptumEHR) v1562"
# databaseDescription <- "Optum Pan-Therapeutic Electronic Health Records (OptumEHR) v1562"
databaseId <- "PharmetricsPlus"
databaseName <- "IQVIA Adjudicated Health Plan Claims (PharmetricsPlus) v1670"
databaseDescription <- "IQVIA Adjudicated Health Plan Claims (PharmetricsPlus) v1670"
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

resultsZipFileOptumDod <- file.path("D:/StudyResults/GLP1Repro/CohortMethod/HERMESp4Hydra/OptumDOD/export", paste0("Results_", "OptumDOD", ".zip"))
resultsZipFileCcae <- file.path("D:/StudyResults/GLP1Repro/CohortMethod/HERMESp4Hydra/TruvenCCAE/export", paste0("Results_", "TruvenCCAE", ".zip"))
resultsZipFileOptumEhr <- file.path("D:/StudyResults/GLP1Repro/CohortMethod/HERMESp4Hydra/OptumEHR/export", paste0("Results_", "OptumEHR", ".zip"))
#resultsZipFilePharmetricsPlus <- file.path("D:/StudyResults/GLP1Repro/CohortMethod/HERMESp4Hydra/PharmetricsPlust/export", paste0("Results_", "PharmetricsPlus", ".zip"))
resultsZipFileTruvenMdcd <- file.path("D:/StudyResults/GLP1Repro/CohortMethod/HERMESp4Hydra/TruvenMDCD/export", paste0("Results_", "TruvenMDCD", ".zip"))
resultsZipFileTruvenMdcr <- file.path("D:/StudyResults/GLP1Repro/CohortMethod/HERMESp4Hydra/TruvenMDCR/export", paste0("Results_", "TruvenMDCR", ".zip"))

dataFolder <- file.path("D:/StudyResults/GLP1Repro/CohortMethod/HERMESp4Hydra/shinyData")

# You can inspect the results if you want:
prepareForEvidenceExplorer(resultsZipFile = resultsZipFileOptumDod, dataFolder = dataFolder)
prepareForEvidenceExplorer(resultsZipFile = resultsZipFileCcae, dataFolder = dataFolder)
prepareForEvidenceExplorer(resultsZipFile = resultsZipFileOptumEhr, dataFolder = dataFolder)
#prepareForEvidenceExplorer(resultsZipFile = resultsZipFilePharmetricsPlus, dataFolder = dataFolder)
prepareForEvidenceExplorer(resultsZipFile = resultsZipFileTruvenMdcd, dataFolder = dataFolder)
prepareForEvidenceExplorer(resultsZipFile = resultsZipFileTruvenMdcr, dataFolder = dataFolder)


preMergeShinyData <- function(shinyDataFolder) { # shinyDataFolder <- "D:/StudyResults/GLP1Repro/CohortMethod/HERMESp4Hydra/shinyData"
        shinySettings <- list(dataFolder = shinyDataFolder, blind = TRUE)
        dataFolder <- shinySettings$dataFolder
        blind <- shinySettings$blind
        connection <- NULL
        positiveControlOutcome <- NULL
        splittableTables <- c("covariate_balance", "preference_score_dist", "kaplan_meier_dist", "likelihood_profile")
        files <- list.files(dataFolder, pattern = ".rds")
        files <- files[!grepl("_tNA", files)]
        databaseFileName <- files[grepl("^database", files)]
        removeParts <- paste0(gsub("database", "", databaseFileName), "$")
        
        for (removePart in removeParts) {  # removePart <- removeParts[2]
                tableNames <- gsub("_t[0-9]+_c[0-9]+$", "", gsub(removePart, "", files[grepl(removePart, files)]))
                tableNames <- tableNames[!grepl("_tNA", tableNames)]
                camelCaseNames <- SqlRender::snakeCaseToCamelCase(tableNames)
                camelCaseNames <- unique(camelCaseNames)
                camelCaseNames <- camelCaseNames[!(camelCaseNames %in% SqlRender::snakeCaseToCamelCase(splittableTables))]
                suppressWarnings(
                        rm(list = camelCaseNames)
                )
        }
        loadFile <- function(file, removePart) { # file <- dbFiles[1]
                tableName <- gsub("_t[0-9]+_c[0-9]+$", "", gsub(removePart, "", file))
                camelCaseName <- SqlRender::snakeCaseToCamelCase(tableName)
                if (!(tableName %in% splittableTables)) {
                        newData <- readRDS(file.path(dataFolder, file))
                        colnames(newData) <- SqlRender::snakeCaseToCamelCase(colnames(newData))
                        if (exists(camelCaseName, envir = .GlobalEnv)) {
                                existingData <- get(camelCaseName, envir = .GlobalEnv)
                                newData$tau <- NULL
                                newData$traditionalLogRr <- NULL
                                newData$traditionalSeLogRr <- NULL
                                if (!all(colnames(newData) %in% colnames(existingData))) {
                                        stop(sprintf("Columns names do not match in %s. \nObserved:\n %s, \nExpecting:\n %s", 
                                                     file,
                                                     paste(colnames(newData), collapse = ", "),
                                                     paste(colnames(existingData), collapse = ", ")))
                                }
                                newData <- rbind(existingData, newData)
                                newData <- unique(newData)
                        }
                        assign(camelCaseName, 
                               newData, 
                               envir = .GlobalEnv)
                }
                invisible(NULL)
        }
        
        for (removePart in removeParts) { # removePart <- removeParts[1]
                dbFiles <- files[grepl(removePart, files)]
                invisible(lapply(dbFiles, loadFile, removePart))
        }
        
        dfs <- Filter(function(x) is.data.frame(get(x)) , ls())
        save(list = dfs, 
             file = file.path(dataFolder, "PreMergedShinyData.RData"),
             compress = TRUE,
             compression_level = 2)
}

preMergeShinyData(dataFolder)

# copy the premerge file, covariatebalance files, kaplanmeier files, and preferencescore files to a new shiny folder


# to test that the renvironment file is correct run this and check that the data-frames load to the local r environment:
# load(file.path(dataFolder, "preMergedShinyData.RData"))

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
