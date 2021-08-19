remotes::install_github("OHDSI/CohortDiagnostics")
Sys.setenv(TZ="America/New_York")


packageName <- "EPI882"
library(CohortDiagnostics)
connectionSpecifications <- cdmSources %>%
  dplyr::filter(sequence == 1) %>%
  dplyr::filter(database == 'truven_ccae')

dbms <- connectionSpecifications$dbms # example: 'redshift'
port <- connectionSpecifications$port # example: 2234
server <-
  connectionSpecifications$server # example: 'fdsfd.yourdatabase.yourserver.com"
cdmDatabaseSchema <-
  connectionSpecifications$cdmDatabaseSchema # example: "cdm"
vocabDatabaseSchema <-
  connectionSpecifications$vocabDatabaseSchema # example: "vocabulary"
databaseId <-
  connectionSpecifications$database # example: "truven_ccae"
userNameService = "redShiftUserName" # example: "this is key ring service that securely stores credentials"
passwordService = "redShiftPassword" # example: "this is key ring service that securely stores credentials"

cohortDatabaseSchema = paste0('scratch_', keyring::key_get(service = userNameService))
# scratch - usually something like 'scratch_grao'

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = dbms,
  user = keyring::key_get(service = userNameService),
  password = keyring::key_get(service = passwordService),
  port = port,
  server = server
)

cohortTable <- # example: 'cohort'
  paste0("s", connectionSpecifications$sourceId, "_", packageName)
temporaryLocation <- file.path("D:/StudyResults/2021/Phenotyping/glp1", "outputFolder", databaseId)
outputFolder <-
  file.path("D:/StudyResults/2021/Phenotyping/EPI882", "outputFolder", databaseId)
# Please delete previous content if needed
# unlink(x = outputFolder,
#        recursive = TRUE,
#        force = TRUE)
dir.create(path = outputFolder,
           showWarnings = FALSE,
           recursive = TRUE)

library(magrittr)
# Set up
baseUrl <- 'https://epi.jnj.com:8443/WebAPI'
# list of cohort ids
cohortIds <- c(2334, 2335, 2336, 2337, 2338, 2339, 2342, 2343, 2344, 2345, 2354, 2355, 2357, 
               2358, 2359, 2360, 2361, 2362, 2363, 2364, 2365, 2366, 2367, 2368, 2369, 2370, 2392)

# get specifications for the cohortIds above
webApiCohorts <-
  ROhdsiWebApi::getCohortDefinitionsMetaData(baseUrl = baseUrl) %>%
  dplyr::filter(.data$id %in% cohortIds)

cohortsToCreate <- list()
for (i in (1:nrow(webApiCohorts))) {
  cohortId <- webApiCohorts$id[[i]]
  cohortDefinition <-
    ROhdsiWebApi::getCohortDefinition(cohortId = cohortId, 
                                      baseUrl = baseUrl)
  cohortsToCreate[[i]] <- tidyr::tibble(
    atlasId = webApiCohorts$id[[i]],
    atlasName = stringr::str_trim(string = stringr::str_squish(cohortDefinition$name)),
    cohortId = webApiCohorts$id[[i]],
    name = stringr::str_trim(stringr::str_squish(cohortDefinition$name))
  )
}
cohortsToCreate <- dplyr::bind_rows(cohortsToCreate)

readr::write_excel_csv(x = cohortsToCreate, na = "", 
                       file = file.path("D:/StudyResults/2021/Phenotyping/EPI882", "outputFolder", databaseId, "CohortsToCreate.csv"), 
                       append = FALSE)


cohortSetReference <- readr::read_csv(file = file.path("D:/StudyResults/2021/Phenotyping/EPI882", "outputFolder", databaseId, "CohortsToCreate.csv"), 
                                      col_types = readr::cols())

CohortDiagnostics::instantiateCohortSet(connectionDetails = connectionDetails,
                                        cdmDatabaseSchema = cdmDatabaseSchema,
                                        cohortDatabaseSchema = cohortDatabaseSchema,
                                        cohortTable = cohortTable,
                                        baseUrl = baseUrl,
                                        cohortSetReference = cohortSetReference,
                                        generateInclusionStats = TRUE,
                                        inclusionStatisticsFolder = file.path(outputFolder, 
                                                                              'inclusionStatisticsFolder'))

 CohortDiagnostics::runCohortDiagnostics(baseUrl = baseUrl,
                                        cohortSetReference = cohortSetReference,
                                        connectionDetails = connectionDetails,
                                        cdmDatabaseSchema = cdmDatabaseSchema,
                                        cohortDatabaseSchema = cohortDatabaseSchema,
                                        cohortTable = cohortTable,
                                        inclusionStatisticsFolder = file.path(outputFolder, 
                                                                              'inclusionStatisticsFolder'),
                                        exportFolder = file.path(outputFolder, 
                                                                 'exportFolder'),
                                        databaseId = databaseId,
                                        runInclusionStatistics = TRUE,
                                        runIncludedSourceConcepts = TRUE,
                                        runOrphanConcepts = TRUE,
                                        runTimeDistributions = TRUE,
                                        runBreakdownIndexEvents = TRUE,
                                        runIncidenceRate = TRUE,
                                        runCohortOverlap = TRUE,
                                        runCohortCharacterization = TRUE,
                                        minCellCount = 5)

#Uncomment at the end, I moved all the zip files into a new folder called results_file and then created premerge
dataFolder <- "D:/StudyResults/2021/Phenotyping/glp1/zipFiles"
CohortDiagnostics::preMergeDiagnosticsFiles(dataFolder = dataFolder)

CohortDiagnostics::launchDiagnosticsExplorer(dataFolder = dataFolder)
