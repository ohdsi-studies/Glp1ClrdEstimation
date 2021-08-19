remotes::install_github("OHDSI/Hydra@develop")

library(Hydra)

specs <- Hydra::loadSpecifications("C:/Users/admin_mconove1/Documents/GLP1Repro/CohortMethod_HERMESp1Hydra/specs.json")
hydrate(specifications=specs,
        outputFolder = "C:/Users/admin_mconove1/Documents/GLP1Repro/CohortMethod_HERMESp1Hydra/HydratedPackage",
        packageName = "HERMESp1Hydra")

