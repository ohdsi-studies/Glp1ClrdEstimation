remotes::install_github("OHDSI/Hydra@develop")

library(Hydra)

specs <- Hydra::loadSpecifications("C:/Users/admin_mconove1/Documents/GLP1Repro/GLP1CLRDEstimation/HERMESp3Hydra/specs.json")
hydrate(specifications=specs,
        outputFolder = "C:/Users/admin_mconove1/Documents/GLP1Repro/GLP1CLRDEstimation/HERMESp3Hydra/HydratedPackage",
        packageName = "HERMESp3Hydra")
