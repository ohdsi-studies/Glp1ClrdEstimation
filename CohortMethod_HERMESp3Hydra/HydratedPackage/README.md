HERMESp3Hydra
==============================


Requirements
============

- A database in [Common Data Model version 5](https://github.com/OHDSI/CommonDataModel) in one of these platforms: SQL Server, Oracle, PostgreSQL, IBM Netezza, Apache Impala, Amazon RedShift, Google BigQuery, or Microsoft APS.
- R version 3.6.0 or newer
- On Windows: [RTools](http://cran.r-project.org/bin/windows/Rtools/)
- [Java](http://java.com)
- 25 GB of free disk space

How to run
==========
1. Follow [these instructions](https://ohdsi.github.io/Hades/rSetup.html) for seting up your R environment, including RTools and Java. 

2. Open your study package in RStudio. Use the following code to install all the dependencies:

	```r
	renv::restore()
	```

3. In RStudio, select 'Build' then 'Install and Restart' to build the package.

3. Once installed, you can execute the study by modifying and using the code below. For your convenience, this code is also provided under `extras/CodeToRunHydra.R`:

	```r
# STEP 0: (If necessary) In the top-right panel in RStudio, select the "Environment" tab and then click the broom icon to clear the environment

# STEP 1: Run the renv command below to install the correct versions of all necessary package dependencies
# renv::restore()

# STEP 2: If necessary, install the keyring package so you can call your username and password when creating the connectionDetails object
#install.packages("keyring")

# STEP 3: In the top-right panel in RStudio, select the "Build" tab and then click "Install and Restart". Confirm the build executes without error.
# will repeat step 3 for each database execution

# STEP 4: Load the relevant libraries 
library(keyring)
library(HERMESp3Hydra)

# STEP 5: revise the settings below to correspond to your local environment (notes provided below)

# STEP 5a: specify where the temporary files (used by the Andromeda package) will be created:
options(andromedaTempFolder = "D:/andromedaTemp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()

# STEP 5b: The folder where the study intermediate and result files will be written:
outputFolder <- "D:/StudyResults/GLP1Repro/CohortMethod/HERMESp3Hydra"

# STEP 5c: Set details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(
        dbms = "redshift",
        user = keyring::key_get("redShiftUserName"),
        password = keyring::key_get("redShiftPassword"),
        port = 5439,
        server = "ohda-prod-1.cldcoxyrkflo.us-east-1.redshift.amazonaws.com/optum_ehr", # change DB extension to refer to the DB you want to analyze
        extraSettings = "ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory"
)

# STEP 5d: The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- "cdm_optum_ehr_v1562"


# STEP 5e: The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "scratch_mconove1" # change to your scratch space
cohortTable <- "HERMES_p3_OptumEHR" #Revise cohortTable name to include a specific reference to the DB being run


# STEP 5f: Some DB-specific meta-information that will be used by the export function:
databaseId <- "OptumEHR"
databaseName <- "Optum Pan-Therapeutic Electronic Health Records (OptumEHR) v1562"
databaseDescription <- "Optum Pan-Therapeutic Electronic Health Records (OptumEHR) v1562"

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
	```

4. Upload the file ```export/Results_<DatabaseId>.zip``` in the output folder to the study coordinator:

	```r
	uploadResults(outputFolder, privateKeyFileName = "<file>", userName = "<name>")
	```
	
	Where ```<file>``` and ```<name<``` are the credentials provided to you personally by the study coordinator.
		
5. To view the results, use the Shiny app:

	```r
	prepareForEvidenceExplorer("Result_<databaseId>.zip", "/shinyData")
	launchEvidenceExplorer("/shinyData", blind = TRUE)
	```
  
  Note that you can save plots from within the Shiny app. It is possible to view results from more than one database by applying `prepareForEvidenceExplorer` to the Results file from each database, and using the same data folder. Set `blind = FALSE` if you wish to be unblinded to the final results.

License
=======
The HERMESp3Hydra package is licensed under Apache License 2.0

Development
===========
HERMESp3Hydra was developed in ATLAS and R Studio.

### Development status

Unknown
