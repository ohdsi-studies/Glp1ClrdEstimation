# please ensure you have the latest version of Hydra. As of 08/13/2021 - CohortDiagnostics support for Hydra is still in develop branch.
# please check hydra release notes and update hydra
#remotes::install_github("OHDSI/Hydra", ref = "develop")
outputFolder <- "C:/Users/admin_mconove1/Documents/Glp1ClrdEstimation/CohortDiagnostics_HERMES/HydratedPackage"  # location where you study package will be created


########## Please populate the information below #####################
version <- "v0.1.0"
name <- "HERMES T-C-O cohorts, an OHDSI network study"
packageName <- "HERMESCD"
skeletonVersion <- "v0.0.1"
createdBy <- "mconove1@its.jnj.com"
createdDate <- Sys.Date() # default
modifiedBy <- "mconove1@its.jnj.com"
modifiedDate <- Sys.Date()
skeletonType <- "CohortDiagnosticsStudy"
organizationName <- "OHDSI"
description <- "Cohort diagnostics on HERMES T-C-O cohorts."


library(magrittr)
# Set up
#baseUrl <- Sys.getenv("baseUrl")
baseUrl <- "https://epi.jnj.com:8443/WebAPI"
ROhdsiWebApi::authorizeWebApi(baseUrl,authMethod = "windows")

# if you have security enabled, please authorize the use - example below
# ROhdsiWebApi::authorizeWebApi(baseUrl, 'windows')
cohortIds <- c(2334, 2335, 2336, 2337, 2338, 2339, 2342, 2343, 2344, 2345, 2354, 2355, 2357, 
               2358, 2359, 2360, 2361, 2362, 2363, 2364, 2365, 2366, 2367, 2368, 2369, 2370, 
               2392, 2416, 2413, 2415, 2414)


################# end of user input ##############
webApiCohorts <- ROhdsiWebApi::getCohortDefinitionsMetaData(baseUrl = baseUrl)
studyCohorts <-  webApiCohorts %>%
  dplyr::filter(.data$id %in% cohortIds)

# compile them into a data table
cohortDefinitionsArray <- list()
for (i in (1:nrow(studyCohorts))) {
  cohortDefinition <-
    ROhdsiWebApi::getCohortDefinition(cohortId = studyCohorts$id[[i]],
                                      baseUrl = baseUrl)
  cohortDefinitionsArray[[i]] <- list(
    id = studyCohorts$id[[i]],
    createdDate = studyCohorts$createdDate[[i]],
    modifiedDate = studyCohorts$createdDate[[i]],
    logicDescription = studyCohorts$description[[i]],
    name = stringr::str_trim(stringr::str_squish(cohortDefinition$name)),
    expression = cohortDefinition$expression
  )
}

tempFolder <- tempdir()
unlink(x = tempFolder, recursive = TRUE, force = TRUE)
dir.create(path = tempFolder, showWarnings = FALSE, recursive = TRUE)

specifications <- list(id = 1,
                       version = version,
                       name = name,
                       packageName = packageName,
                       skeletonVersion = skeletonVersion,
                       createdBy = createdBy,
                       createdDate = createdDate,
                       modifiedBy = modifiedBy,
                       modifiedDate = modifiedDate,
                       skeletonType = skeletonType,
                       organizationName = organizationName,
                       description = description,
                       cohortDefinitions = cohortDefinitionsArray)

jsonFileName <- paste0(file.path(tempFolder, "CohortDiagnosticsSpecs.json"))
write(x = specifications %>% RJSONIO::toJSON(pretty = TRUE), file = jsonFileName)


##############################################################
##############################################################
#######       Get skeleton from github            ############
#######       Uncomment if you want to use latest ############
#######       skeleton only - for advanced user   ############
##############################################################
##############################################################
##############################################################
#### get the skeleton from github
# download.file(url = "https://github.com/OHDSI/SkeletonCohortDiagnosticsStudy/archive/refs/heads/main.zip",
#                          destfile = file.path(tempFolder, 'skeleton.zip'))
# unzip(zipfile =  file.path(tempFolder, 'skeleton.zip'), 
#       overwrite = TRUE,
#       exdir = file.path(tempFolder, "skeleton")
#         )
# fileList <- list.files(path = file.path(tempFolder, "skeleton"), full.names = TRUE, recursive = TRUE, all.files = TRUE)
# DatabaseConnector::createZipFile(zipFile = file.path(tempFolder, 'skeleton.zip'), 
#                                  files = fileList, 
#                                  rootFolder = list.dirs(file.path(tempFolder, 'skeleton'), recursive = FALSE))

##############################################################
##############################################################
#######               Build package              #############
##############################################################
##############################################################
##############################################################


#### Code that uses the ExampleCohortDiagnosticsSpecs in Hydra to build package
hydraSpecificationFromFile <- Hydra::loadSpecifications(fileName = jsonFileName)
unlink(x = outputFolder, recursive = TRUE)
dir.create(path = outputFolder, showWarnings = FALSE, recursive = TRUE)
Hydra::hydrate(specifications = hydraSpecificationFromFile,
               outputFolder = outputFolder
)

# for advanced user using skeletons outside of Hydra
# Hydra::hydrate(specifications = hydraSpecificationFromFile,
#                outputFolder = outputFolder, 
#                skeletonFileName = file.path(tempFolder, 'skeleton.zip')
# )


unlink(x = tempFolder, recursive = TRUE, force = TRUE)


##############################################################
##############################################################
######       Build, install and execute package           #############
##############################################################
##############################################################
##############################################################