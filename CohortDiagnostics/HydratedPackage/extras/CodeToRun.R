#In order to run the hotfix code I ran:

# renv::restore()
# install.packages("keyring")
# The renv file has Rcpp lockfile version = 1.0.6 but I updated it to 1.0.7 in order to resolve an error 
# Error in verifyDependencies() : 
#         Mismatch between required and installed package versions. Did you forget to run renv::restore()?
#         - Package Rcpp version 1.0.7 should be 1.0.6
# remove.packages("Rcpp") # Remove the current version of Rcpp package
# install.packages("Rcpp") # Update to latest version of Rcpp
# renv::status() # check status of packages
# renv::snapshot() # commit to lockfile


library(HERMESCD)

# Optional: specify where the temporary files (used by the Andromeda package) will be created:
options(andromedaTempFolder = "D:/andromedaTemp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()

# The folder where the study intermediate and result files will be written:
outputFolder <- "D:/StudyResults/GLP1Repro/CohortDiagnostics/HERMESCD"


# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(
        dbms = "redshift",
        user = keyring::key_get("redShiftUserName"),
        password = keyring::key_get("redShiftPassword"),
        port = 5439,
        server = "ohda-prod-1.cldcoxyrkflo.us-east-1.redshift.amazonaws.com/jmdc", # change DB extension to refer to the DB you want to analyze
        extraSettings = "ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory"
)

# The name of the database schema where the CDM data can be found:
#cdmDatabaseSchema <- "cdm_truven_ccae_v1676"
#cdmDatabaseSchema <- "cdm_optum_extended_dod_v1679"
#cdmDatabaseSchema <- "cdm_truven_mdcd_v1561"
#cdmDatabaseSchema <- "cdm_optum_ehr_v1562"
#cdmDatabaseSchema <- "cdm_iqvia_pharmetrics_plus_v1500"
#cdmDatabaseSchema <- "cdm_truven_mdcr_v1692"
cdmDatabaseSchema <- "cdm_jmdc_v1678"

# The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "scratch_mconove1"
#cohortTable <- "HERMESCD_v1_truvenCCAE"
#cohortTable <- "HERMESCD_v1_optumDod"
#cohortTable <- "HERMESCD_v1_truvenMDCD"
#cohortTable <- "HERMESCD_v1_optumEhr"
#cohortTable <- "HERMESCD_v1_PharmetricsPlus"
#cohortTable <- "HERMESCD_v1_truvenMDCR"
cohortTable <- "HERMESCD_v1_JMDC"


# Some meta-information that will be used by the export function:
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
# databaseId <- "PharmetricsPlus"
# databaseName <- "IQVIA Adjudicated Health Plan Claims (PharmetricsPlus) v1500"
# databaseDescription <- "IQVIA Adjudicated Health Plan Claims (PharmetricsPlus) v1500"
# databaseId <- "TruvenMDCR"
# databaseName <- "IBM MarketScan Medicare Supplemental (v1692)"
# databaseDescription <- "IBM MarketScan Medicare Supplemental (v1692)"
databaseId <- "JMDC"
databaseName <- "Japan Medical Data Center (JMDC)"
databaseDescription <- "Japan Medical Data Center (JMDC)"
# For some database platforms (e.g. Oracle): define a schema that can be used to emulate temp tables:
options(sqlRenderTempEmulationSchema = NULL)

# Create subdirectory for the results specific to this database
dbOutputFolder <- file.path(outputFolder,databaseId)
if (!file.exists(dbOutputFolder)) {
        dir.create(dbOutputFolder, recursive = TRUE)
}

HERMESCD::execute(
        connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        verifyDependencies = TRUE,
        outputFolder = dbOutputFolder,
        databaseId = databaseId,
        databaseName = databaseName,
        databaseDescription = databaseDescription
)


#dataFolder <- "D:/StudyResults/GLP1Repro/CohortDiagnostics/allZipFiles/"
CohortDiagnostics::preMergeDiagnosticsFiles(dataFolder = file.path(outputFolder,"allZipFiles"))

CohortDiagnostics::launchDiagnosticsExplorer(dataFolder = dbOutputFolder)


# Upload the results to the OHDSI SFTP server:
privateKeyFileName <- ""
userName <- ""
HERMESCD::uploadResults(outputFolder, privateKeyFileName, userName)
