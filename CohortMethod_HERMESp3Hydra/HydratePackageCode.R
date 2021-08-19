remotes::install_github("OHDSI/Hydra@develop")

library(Hydra)

specs <- Hydra::loadSpecifications("C:/Users/admin_mconove1/Documents/GLP1Repro/CohortMethod_HERMESp3Hydra/glp1_repro/specs.json")
hydrate(specifications=specs,
        outputFolder = "C:/Users/admin_mconove1/Documents/GLP1Repro/CohortMethod_HERMESp3Hydra/glp1_repro/HydratedPackage",
        packageName = "HERMESp3Hydra")

