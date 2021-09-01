remotes::install_github("OHDSI/Hydra@develop")

library(Hydra)

specs <- Hydra::loadSpecifications("C:/Users/admin_mconove1/Documents/GLP1Repro/GLP1CLRDEstimation/HERMESp2Hydra/specs.json")
hydrate(specifications=specs,
        outputFolder = "C:/Users/admin_mconove1/Documents/GLP1Repro/GLP1CLRDEstimation/HERMESp2Hydra/HydratedPackage",
        packageName = "HERMESp2Hydra")
