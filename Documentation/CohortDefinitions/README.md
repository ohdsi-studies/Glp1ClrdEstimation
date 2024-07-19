Cohort and concept set documentation

=============



This folder contains documentation of key cohorts used to define study exposures, and outcomes.  Each sub-directory corresponds to a specific study cohort (i.e. exposure or outcome) and contains documentation of the cohort logic and concept sets (i.e. code lists) used to define them. Note that the mappedConcepts.csv file contains the full list of source codes (e.g. ICD-9-CM or ICD-10-CM) that would be included by each concept set referred to in the Cohort Logic documentation.



An alternative approach to understanding the cohorts and concept sets used to define key study variables is to load the JSON code for a given cohort definition within an instance of OHDSI's web-based application Atlas. Details on where to find a publicly-accessible version of Atlas can be found here: https://www.ohdsi.org/software-tools/  For example, currently a public demo version of Atlas can be found here: https://atlas-demo.ohdsi.org/



To load a JSON file into Atlas to view cohort logic, simply navigate to any JSON file in the repository (e.g. https://github.com/ohdsi-studies/Glp1ClrdEstimation/blob/master/GLP1ReproExac/HydratedPackage/inst/cohorts/CLRD_exacerbations_via_standard_concepts.json), copy the JSON code to your clipboard.  Next navigate to Atlas and follow the steps below to load the JSON into a cohort definition.



(1) Click "Cohort Definitions" from the menu on the left margin of the screen.

(2) Click the "New Cohort" button

(3) Click the "Export" tab

(4) Click the "JSON" tab

(5) Replace the contents of the text box with the JSON code copied from the repository.

(6) Click "Reload"

(7) Click the "Definition" tab to view the now-loaded cohort definition.
