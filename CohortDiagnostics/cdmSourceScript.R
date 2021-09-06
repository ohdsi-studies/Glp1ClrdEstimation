library(magrittr)
ROhdsiWebApi::authorizeWebApi("https://epi.jnj.com:8443/WebAPI", "windows") # Windows authentication

cdmSources <- ROhdsiWebApi::getCdmSources(baseUrl = "https://epi.jnj.com:8443/WebAPI") %>%
  dplyr::mutate(baseUrl = "https://epi.jnj.com:8443/WebAPI",
                dbms = 'redshift',
                sourceDialect = 'redshift',
                port = 5439,
                version = .data$sourceKey %>% substr(., nchar(.) - 3, nchar(.)) %>% as.integer(),
                database = .data$sourceKey %>% substr(., 5, nchar(.) - 6)) %>%
  dplyr::group_by(.data$database) %>%
  dplyr::arrange(dplyr::desc(.data$version)) %>%
  dplyr::mutate(sequence = dplyr::row_number()) %>%
  dplyr::ungroup() %>%
  dplyr::arrange(.data$database, .data$sequence) %>%
  dplyr::mutate(server = tolower(paste0(Sys.getenv("serverRoot"),"/", .data$database)))

