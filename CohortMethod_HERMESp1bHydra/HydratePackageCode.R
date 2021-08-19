remotes::install_github("OHDSI/Hydra@develop")

library(Hydra)

specs <- Hydra::loadSpecifications("C:/Users/admin_mconove1/Documents/GLP1Repro/CohortMethod_HERMESp1bHydra/specs.json")
Hydra::hydrate(specifications=specs,
               outputFolder = "C:/Users/admin_mconove1/Documents/GLP1Repro/CohortMethod_HERMESp1bHydra/HydratedPackage",
               packageName = "HERMESp1bHydra")

