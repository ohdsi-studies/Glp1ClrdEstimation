#remotes::install_github("OHDSI/EmpiricalCalibration", dependencies=TRUE)

library(ggplot2)
outputFolder <- "C:/Users/admin_mconove1/Documents/GLP1Repro/GLP1CLRDEstimation/plotForest/figures"

forestPlotRow <- function(packageName, exposureId, comparatorId, outcomeId, modelType, adjustment, calibration, label, databaseId="TruvenCCAE") {
  shinyDataFolder <- outcomes <- exposures <- analyses <- results <- NULL
  shinyDataFolder <- file.path("D:/StudyResults/GLP1Repro/CohortMethod/",packageName,"shinyData/")
  outcomes <- readRDS(file.path(shinyDataFolder,paste0("outcome_of_interest_",databaseId,".rds")))
  exposures <- readRDS(file.path(shinyDataFolder,paste0("exposure_of_interest_",databaseId,".rds")))
  analyses <- readRDS(file.path(shinyDataFolder,paste0("cohort_method_analysis_",databaseId,".rds")))
  results <- readRDS(file.path(shinyDataFolder,paste0("cohort_method_result_",databaseId,".rds")))
  
  analyses$modelType <- ifelse(grepl("Cox", analyses$description, fixed = TRUE), "Cox","Poisson")
  analyses$adjustment <- ifelse(grepl("Crude", analyses$description, fixed = TRUE), "Crude",
                                ifelse(grepl("matching 1:2", analyses$description, fixed = TRUE), "1:2 PS-Matching",
                                       ifelse(grepl("matching 1:100", analyses$description, fixed = TRUE), "1:100 PS-Matching",
                                              ifelse(grepl("stratification", analyses$description, fixed = TRUE), "PS-Stratification","ERROR"))))
  

  if (calibration=="FALSE") {
    resultColumns <- c("target_id","comparator_id","outcome_id","analysis_id","database_id","log_rr","se_log_rr")
  } else {
    resultColumns <- c("target_id","comparator_id","outcome_id","analysis_id","database_id","calibrated_log_rr","calibrated_se_log_rr")
  }
  resultRow <- results[which(results$target_id==exposureId & results$comparator_id==comparatorId & results$outcome_id==outcomeId),
                       resultColumns]
  if (calibration=="TRUE") {
    names(resultRow)[names(resultRow) == "calibrated_log_rr"] <- "log_rr"
    names(resultRow)[names(resultRow) == "calibrated_se_log_rr"] <- "se_log_rr"
  }
  
  analysisRow <- analyses[which(analyses$modelType==modelType & analyses$adjustment==adjustment),
                          c("analysis_id","description","modelType","adjustment")]
  mergeRow <- merge(x=resultRow,y=analysisRow,by="analysis_id")
  mergeRow$label <- label
  #mergeRow$source <- "OHDSI"
  mergeRow$source<- ifelse(mergeRow$target_id==2334,"Source","non-Source")
  return(mergeRow)
}

# 2334 GLP1 new users via source codes 2006-2017
# 2336 GLP1 new users via standard concepts 2006-2017
# 2335 DPP4 new users via source codes 2006-2017
# 2337 DPP4 new users via standard concepts 2006-2017

albogamiResultsHosp <- data.frame("analysis_id"=c(0,0),"target_id"=c(0,0),"comparator_id"=c(0,0),"outcome_id"=c(0,0),"database_id"=c("TruvenCCAE","TruvenCCAE"),
                                 "log_rr"= c(log(0.52),log(0.52)),
                                 "se_log_rr"=c((log(0.34) - log(0.52))/qnorm(0.025),
                                               (log(0.32) - log(0.52))/qnorm(0.025)),
                                 "description"=c("Albogami - Unadjusted","Albogami - Adjusted"),
                                 "modelType"=c("Cox","Cox"),
                                 "adjustment"=c("Crude","sIPTW"),
                                 "label"=c("Albogami - Unadjusted","Albogami - Adjusted"),
                                 "source"="Albogami")

albogamiResultsExac <- data.frame("analysis_id"=c(0,0),"target_id"=c(0,0),"comparator_id"=c(0,0),"outcome_id"=c(0,0),"database_id"=c("TruvenCCAE","TruvenCCAE"),
                                  "log_rr"= c(log(0.81),log(0.70)),
                                  "se_log_rr"=c((log(0.66) - log(0.81))/qnorm(0.025),
                                                (log(0.57) - log(0.70))/qnorm(0.025)),
                                  "description"=c("Albogami - Unadjusted","Albogami - Adjusted"),
                                  "modelType"=c("Poisson","Poisson"),
                                  "adjustment"=c("Crude","sIPTW"),
                                  "label"=c("Albogami - Unadjusted","Albogami - Adjusted"),
                                  "source"=rep("Albogami",2))

headerHosp <- data.frame("analysis_id"=NA,"target_id"=NA,"comparator_id"=NA,"outcome_id"=NA,"database_id"="",
                         "log_rr"= NA,
                         "se_log_rr"=NA,
                         "description"="",
                         "modelType"="",
                         "adjustment"="",
                         "label"="Hospitalization Outcome",
                         "source"="")

headerExac <- data.frame("analysis_id"=NA,"target_id"=NA,"comparator_id"=NA,"outcome_id"=NA,"database_id"="",
                         "log_rr"= NA,
                         "se_log_rr"=NA,
                         "description"="",
                         "modelType"="",
                         "adjustment"="",
                         "label"="Exacerbation Outcome",
                         "source"="")

blankRowHosp1 <- data.frame("analysis_id"=NA,"target_id"=NA,"comparator_id"=NA,"outcome_id"=NA,"database_id"="",
                         "log_rr"= NA,
                         "se_log_rr"=NA,
                         "description"="",
                         "modelType"="",
                         "adjustment"="",
                         "label"="",
                         "source"="")

blankRowHosp6 <- blankRowHosp5 <- blankRowHosp4 <- blankRowHosp3 <- blankRowHosp2 <- blankRowHosp1
blankRowHosp2$label=paste0(blankRowHosp1$label," ")
blankRowHosp3$label=paste0(blankRowHosp1$label,"  ")
blankRowHosp4$label=paste0(blankRowHosp1$label,"   ")
blankRowHosp5$label=paste0(blankRowHosp1$label,"                          ")
blankRowHosp6$label=paste0(blankRowHosp1$label,"     ")
blankRowHosp2$source=paste0(blankRowHosp1$source," ")
blankRowHosp3$source=paste0(blankRowHosp1$source,"  ")
blankRowHosp4$source=paste0(blankRowHosp1$source,"   ")
blankRowHosp5$source=paste0(blankRowHosp1$source,"    ")
blankRowHosp6$source=paste0(blankRowHosp1$source,"    ")

blankRowExac1 <- data.frame("analysis_id"=NA,"target_id"=NA,"comparator_id"=NA,"outcome_id"=NA,"database_id"="",
                       "log_rr"= NA,
                       "se_log_rr"=NA,
                       "description"="",
                       "modelType"="",
                       "adjustment"="",
                       "label"=" ",
                       "source"="")

blankRowExac6 <- blankRowExac5 <- blankRowExac4 <- blankRowExac3 <- blankRowExac2 <- blankRowExac1
blankRowExac2$label=paste0(blankRowExac1$label," ")
blankRowExac3$label=paste0(blankRowExac1$label,"  ")
blankRowExac4$label=paste0(blankRowExac1$label,"   ")
blankRowExac5$label=paste0(blankRowExac1$label,"                          ")
blankRowExac6$label=paste0(blankRowExac1$label,"     ")
blankRowExac2$source=paste0(blankRowExac1$source," ")
blankRowExac3$source=paste0(blankRowExac1$source,"  ")
blankRowExac4$source=paste0(blankRowExac1$source,"   ")
blankRowExac5$source=paste0(blankRowExac1$source,"    ")
blankRowExac6$source=paste0(blankRowExac1$source,"     ")



plotForest2 <- function (logRr, seLogRr, names, xLabel = "Hazard Ratio", title, fileName = NULL, breaks) {
  #breaks <- c(0.25, 0.5, 1, 2, 4)
  theme <- ggplot2::element_text(colour = "#000000", 
                                 size = 6)
  themeRA <- ggplot2::element_text(colour = "#000000", 
                                   size = 5, hjust = 1)
  col <- c(rgb(0, 0, 0.8, alpha = 1), rgb(0.8, 0.4, 0, alpha = 1))
  colFill <- c(rgb(0, 0, 1, alpha = 0.5), rgb(1, 0.4, 0, alpha = 0.5))
  data <- data.frame(DRUG_NAME = as.factor(names), logRr = logRr, 
                     logLb95Rr = logRr + qnorm(0.025) * seLogRr, logUb95Rr = logRr + 
                       qnorm(0.975) * seLogRr)
  data$significant <- data$logLb95Rr > 0 | data$logUb95Rr < 
    0
  data$DRUG_NAME <- factor(data$DRUG_NAME, levels = rev(levels(data$DRUG_NAME)))
  plot <- ggplot2::ggplot(data, ggplot2::aes(x = .data$DRUG_NAME, 
                                             y = exp(.data$logRr), ymin = exp(.data$logLb95Rr), ymax = exp(.data$logUb95Rr), 
                                             colour = .data$significant, fill = .data$significant)) + 
    ggplot2::geom_hline(yintercept = breaks, colour = "#AAAAAA", 
                        lty = 1, size = 0.2) + ggplot2::geom_hline(yintercept = 1, 
                                                                   size = 0.5) + ggplot2::geom_pointrange(shape = 23) + 
    ggplot2::scale_colour_manual(values = col) + ggplot2::scale_fill_manual(values = colFill) + 
    ggplot2::coord_flip(ylim = c(0.25, 10)) + ggplot2::scale_y_continuous(xLabel, 
                                                                          trans = "log10", breaks = breaks, labels = breaks) + 
    ggplot2::theme(panel.grid.minor = ggplot2::element_blank(), 
                   panel.background = ggplot2::element_rect(fill = "#FAFAFA", 
                                                            colour = NA), panel.grid.major = ggplot2::element_line(colour = "#EEEEEE"), 
                   axis.ticks = ggplot2::element_blank(), axis.title.y = ggplot2::element_blank(), 
                   axis.title.x = ggplot2::element_blank(), axis.text.y = themeRA, 
                   axis.text.x = theme, plot.title = ggplot2::element_text(hjust = 0.5), 
                   legend.key = ggplot2::element_blank(), strip.text.x = theme, 
                   strip.background = ggplot2::element_blank(), legend.position = "none")
  if (!missing(title)) {
    plot <- plot + ggplot2::ggtitle(title)
  }
  if (!is.null(fileName)) 
    ggplot2::ggsave(fileName, plot, width = 5, height = 2.5 + 
                      length(logRr) * 0.8, dpi = 400)
  return(plot)
}

plotForestWrapper <- function(fData,plotTitle,breaks = c(0.25, 0.5, 1, 2, 4),limits=c(0.25,4), colorKey="master") { 
  # fData <- forestDataHospBlanks3
  # plotTitle <- "Hospitalization Outcome"
  # color <- "master"
  # breaks <- c(0.25, 0.5, 1, 2, 4)
  # limits <- c(0.25,4)
  # colorKey = "master"
  

  fData$order <- seq_len(nrow(fData))
  fData$label <- factor(fData$label, levels = fData$label[order(fData$order)])
  fData$source <- factor(fData$source, levels = unique(fData$source[order(fData$order)]))
  fData$database_id <- factor(fData$database_id, levels = unique(fData$database_id[order(fData$order)]))
  
  
  if (colorKey=="master") {
    fData$color <- ifelse(grepl("Albogami",fData$label),"#940E02",
                          ifelse(grepl("CCAE",fData$database_id) & fData$source != "Source","#0033CC",
                                 ifelse(fData$source == "Source","#35baf6",
                                      ifelse(grepl("Meta",fData$database_id),"#000000","#ff9500"))))
    fData$color <- factor(fData$color, levels = unique(fData$color[order(fData$order)]))
    #aesColors <- factor(aesColors, levels = unique(aesColors[order(fData$order)]))
    #aesColors <- fData$color
    cols <- c("#940E02"="#940E02", "#0033CC"="#0033CC", "#35baf6"="#35baf6","#000000"="#000000","#ff9500"="#ff9500")
    
  }
  
  if (colorKey=="masterManuscript") {
    fData$color <- ifelse(grepl("Albogami",fData$label),"#000000",
                          ifelse(grepl("CCAE",fData$database_id) & fData$source != "Source","#000000",
                                 ifelse(fData$source == "Source","#000000",
                                        ifelse(grepl("Meta",fData$database_id),"#000000","#000000"))))
    fData$color <- factor(fData$color, levels = unique(fData$color[order(fData$order)]))
    #aesColors <- factor(aesColors, levels = unique(aesColors[order(fData$order)]))
    #aesColors <- fData$color
    cols <- c("#000000"="#000000", "#000000"="#000000", "#000000"="#000000","#000000"="#000000","#000000"="#000000")
    
  }
  
  fPlot <- plotForest2(logRr=fData$log_rr,
                                            seLogRr=fData$se_log_rr,
                                            names=fData$label,
                                            title = plotTitle,
                                            #xLabel = "Hazard Ratio (HR)",
                                            fileName="plottest.png",
                                            breaks=breaks)
  
  if (colorKey=="label") {
    fData$color <- ifelse(grepl("Albogami",fData$label),"#940E02",
                          ifelse(grepl("OHDSI",fData$label),"#548235",
                                 "#0033CC"))
    aesColors <- fData$source
  }
  if (colorKey=="database_id") {
    fData$color <- ifelse(grepl("CCAE",fData$database_id),"#0033CC","#548235")
     aesColors <- fData$database_id
  }
  #color <- fData$color
  #sources <- fData$source
  #breaks <- c(0.25, 0.5, 1, 2)
 #limits <- c(0.25,4)
  #limits <- c(min(breaks),max(breaks))
  
  fPlot <- fPlot + 
    aes(colour = fData$color, fill=fData$color) +
    #aes(colour = factor(aesColors), fill=factor(aesColors)) +
    scale_colour_manual(values = cols) + 
    scale_fill_manual(values = cols) + 
    coord_flip(ylim = limits) +
    scale_y_continuous(name="Hazard Ratio (HR)", trans = "log10", breaks = breaks, labels = breaks) +
    theme(axis.text.x = element_text(size=10), 
          axis.text.y = element_text(size=10)) +
    geom_hline(yintercept = breaks, colour = "#AAAAAA", lty = 1, size = 0.2) + 
    geom_hline(yintercept = 1, size = 0.5)
  
  if (colorKey=="masterManuscript") {
    fPlot <- fPlot + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                           panel.background = element_blank())
  }

  return(fPlot)
}

# Creating Forest Plot Showing Main Results for Hospitalization Outcome
forestDataHospBlanks1 <- 
  rbind(albogamiResultsHosp[which(albogamiResultsHosp$description == "Albogami - Unadjusted"),],
        blankRowHosp1,
        blankRowHosp2,
        blankRowHosp3,
        albogamiResultsHosp[which(albogamiResultsHosp$description == "Albogami - Adjusted"),],
        blankRowHosp4,
        blankRowHosp5
        )
forestDataHospBlanks2 <- 
        rbind(albogamiResultsHosp[which(albogamiResultsHosp$description == "Albogami - Unadjusted"),],
              forestPlotRow("HERMESp1Hydra",2334,2335,2338,modelType="Cox",adjustment="Crude",calibration=FALSE, label="OHDSI - Unadjusted"),
              blankRowHosp1,
              blankRowHosp2,
              albogamiResultsHosp[which(albogamiResultsHosp$description == "Albogami - Adjusted"),],
              forestPlotRow("HERMESp1Hydra",2334,2335,2338,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="OHDSI - Adjusted"),
              blankRowHosp3
              )
forestDataHospBlanks3 <- 
  rbind(albogamiResultsHosp[which(albogamiResultsHosp$description == "Albogami - Unadjusted"),],
        forestPlotRow("HERMESp1Hydra",2334,2335,2338,modelType="Cox",adjustment="Crude",calibration=FALSE, label="OHDSI - Unadjusted"),
        forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="Crude",calibration=FALSE, label="OHDSI Standard - Unadjusted"),
        blankRowHosp1,
        albogamiResultsHosp[which(albogamiResultsHosp$description == "Albogami - Adjusted"),],
        forestPlotRow("HERMESp1Hydra",2334,2335,2338,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="OHDSI - Adjusted"),
        forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="OHDSI Standard - Adjusted")
        )


hospSlide1 <- plotForestWrapper(forestDataHospBlanks1, "Hospitalization Outcome")
hospSlide2 <- plotForestWrapper(forestDataHospBlanks2, "Hospitalization Outcome")
hospSlide3 <- plotForestWrapper(forestDataHospBlanks3, "Hospitalization Outcome")

hospSlide1
hospSlide2
hospSlide3

ggsave(filename = file.path(outputFolder,"hospSlide1.png"), plot=hospSlide1, width = 6.65, height = 3.76, units = "in")
ggsave(filename = file.path(outputFolder,"hospSlide2.png"), plot=hospSlide2, width = 6.65, height = 3.76, units = "in")
ggsave(filename = file.path(outputFolder,"hospSlide3.png"), plot=hospSlide3, width = 6.65, height = 3.76, units = "in")

# Figure 1 Panel 1 in the manuscript
hospFigure1Manuscript <- plotForestWrapper(forestDataHospBlanks3, "Hospitalization Outcome",colorKey="masterManuscript")
hospFigure1Manuscript
ggsave(filename = file.path(outputFolder,"hospFigure1Manuscript.png"), plot=hospFigure1Manuscript, width = 6.8, height = 3.76, units = "in")

# Creating Forest Plot Showing Main Results for Exacerbation Outcome

forestDataExacBlanks1 <- 
  rbind(albogamiResultsExac[which(albogamiResultsExac$description == "Albogami - Unadjusted"),],
        blankRowExac1,
        blankRowExac2,
        blankRowExac3,
        albogamiResultsExac[which(albogamiResultsExac$description == "Albogami - Adjusted"),],
        blankRowExac4,
        blankRowExac5
  )
forestDataExacBlanks2 <- 
  rbind(albogamiResultsExac[which(albogamiResultsExac$description == "Albogami - Unadjusted"),],
        forestPlotRow("HERMESp2Hydra",2334,2335,2343,modelType="Poisson",adjustment="Crude",calibration=FALSE, label="OHDSI - Unadjusted"),
        blankRowExac1,
        blankRowExac2,
        albogamiResultsExac[which(albogamiResultsExac$description == "Albogami - Adjusted"),],
        forestPlotRow("HERMESp2Hydra",2334,2335,2343,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label="OHDSI - Adjusted"),
        blankRowExac3
  )
forestDataExacBlanks3 <- 
  rbind(albogamiResultsExac[which(albogamiResultsExac$description == "Albogami - Unadjusted"),],
        forestPlotRow("HERMESp2Hydra",2334,2335,2343,modelType="Poisson",adjustment="Crude",calibration=FALSE, label="OHDSI - Unadjusted"),
        forestPlotRow("HERMESp2Hydra",2336,2337,2342,modelType="Poisson",adjustment="Crude",calibration=FALSE, label="OHDSI - Standard Unadjusted"),
        blankRowExac1,
        albogamiResultsExac[which(albogamiResultsHosp$description == "Albogami - Adjusted"),],
        forestPlotRow("HERMESp2Hydra",2334,2335,2343,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label="OHDSI - Adjusted"),
        forestPlotRow("HERMESp2Hydra",2336,2337,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label="OHDSI - Standard Adjusted")
  )

exacSlide1 <- plotForestWrapper(forestDataExacBlanks1, "Exacerbation Outcome")
exacSlide2 <- plotForestWrapper(forestDataExacBlanks2, "Exacerbation Outcome")
exacSlide3 <- plotForestWrapper(forestDataExacBlanks3, "Exacerbation Outcome")

exacSlide1
exacSlide2
exacSlide3

ggsave(filename = file.path(outputFolder,"exacSlide1.png"), plot=exacSlide1, width = 6.65, height = 3.76, units = "in")
ggsave(filename = file.path(outputFolder,"exacSlide2.png"), plot=exacSlide2, width = 6.65, height = 3.76, units = "in")
ggsave(filename = file.path(outputFolder,"exacSlide3.png"), plot=exacSlide3, width = 6.65, height = 3.76, units = "in")


# Figure 1 Panel 2 in the manuscript
exacFigure1Manuscript <- plotForestWrapper(forestDataExacBlanks3, "Exacerbation Outcome", colorKey="masterManuscript")
exacFigure1Manuscript
ggsave(filename = file.path(outputFolder,"exacFigure1Manuscript.png"), plot=exacFigure1Manuscript, width = 6.8, height = 3.76, units = "in")


# Creating Forest Plot Showing Sn analysis Results to Compare to Albogami et al

headerMainAnalysis <- headerStratAnalysis <- headerSnAnalyses <- headerHosp
headerMainAnalysis$label <- "Main analysis"
headerMainAnalysis$source <- "     "
headerStratAnalysis$label <- "Stratified analysis"
headerStratAnalysis$source <- "      "
headerSnAnalyses$label <- "Sensitivity analyses"
headerSnAnalyses$source <- "       "

forestDataSnNoCal <- 
  rbind(headerMainAnalysis,
        forestPlotRow("HERMESp1Hydra",2334,2335,2338,modelType="Cox",adjustment="Crude",calibration=FALSE, label="Unadjusted"),
        forestPlotRow("HERMESp1Hydra",2334,2335,2338,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="Adjusted"),
        headerStratAnalysis,
        forestPlotRow("HERMESp1Hydra",2369,2370,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="COPD"),
        forestPlotRow("HERMESp1Hydra",2367,2368,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="Asthma"),
        headerSnAnalyses,
        forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="Crude",calibration=FALSE, label="Standard - unadjusted"),
        forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="Standard - adjusted"),
        forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="1:2 PS-Matching",calibration=FALSE, label="PS-Matching (1:2)/cond Cox"),
        forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="1:100 PS-Matching",calibration=FALSE, label="PS-Matching (1:100)/cond Cox"),
        forestPlotRow("HERMESp1bHydra",2392,2360,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="Sulfonylurea comparator"),
        forestPlotRow("HERMESp1Hydra",2336,2337,2359,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="Restricted outcome"),
        forestPlotRow("HERMESp1Hydra",2361,2362,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="Prior or concurrent T2DM drug")
  )
forestDataSnCal <- 
  rbind(headerMainAnalysis,
        forestPlotRow("HERMESp1Hydra",2334,2335,2338,modelType="Cox",adjustment="Crude",calibration=TRUE, label="Unadjusted"),
        forestPlotRow("HERMESp1Hydra",2334,2335,2338,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Adjusted"),
        headerStratAnalysis,
        forestPlotRow("HERMESp1Hydra",2369,2370,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="COPD"),
        forestPlotRow("HERMESp1Hydra",2367,2368,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Asthma"),
        headerSnAnalyses,
        forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="Crude",calibration=FALSE, label="Standard - unadjusted"),
        forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Standard - adjusted"),
        forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="1:2 PS-Matching",calibration=TRUE, label="PS-Matching (1:2)/cond Cox"),
        forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="1:100 PS-Matching",calibration=TRUE, label="PS-Matching (1:100)/cond Cox"),
        forestPlotRow("HERMESp1bHydra",2392,2360,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Sulfonylurea comparator"),
        forestPlotRow("HERMESp1Hydra",2336,2337,2359,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Restricted outcome"),
        forestPlotRow("HERMESp1Hydra",2361,2362,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Prior or concurrent T2DM drug")
  )

snSlideNoCal <- plotForestWrapper(forestDataSnNoCal, "Hospitalization Outcome",breaks=c(.3, 0.6, 1, 1.3, 1.6), limits=c(.23,2))
snSlideCal <- plotForestWrapper(forestDataSnCal, "Hospitalization Outcome",breaks=c(.3, 0.6, 1, 1.3, 1.6), limits=c(0.23,2))

snSlideNoCal
snSlideCal

ggsave(filename = file.path(outputFolder,"snSlideNoCal.png"), plot=snSlideNoCal, width = 6.65, height = 3.76, units = "in")
ggsave(filename = file.path(outputFolder,"snSlideCal.png"), plot=snSlideCal, width = 6.65, height = 3.76, units = "in")


# Creating Forest Plot Showing Sn Analyses for Time Trends - Hospitalization

forestDataCumTimeTrendsNoCal <- 
  rbind(forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="2006-2017"),
        forestPlotRow("HERMESp1Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="2006-2020")
  )
forestDataDisjTimeTrendsNoCal <- 
  rbind(forestPlotRow("HERMESp1Hydra",2354,2355,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="Pre-2014"),
        forestPlotRow("HERMESp1Hydra",2357,2358,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="Post-2015")
  )
forestDataCumTimeTrendsCal <- 
  rbind(forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="2006-2017"),
        forestPlotRow("HERMESp1Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="2006-2020")
  )
forestDataDisjTimeTrendsCal <- 
  rbind(forestPlotRow("HERMESp1Hydra",2354,2355,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Pre-2014"),
        forestPlotRow("HERMESp1Hydra",2357,2358,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Post-2015")
  )
cumTimeTrendsSlideNoCal <- plotForestWrapper(forestDataCumTimeTrendsNoCal, "Hospitalization Outcome",limits=c(0.18,4))
cumTimeTrendsSlideCal <- plotForestWrapper(forestDataCumTimeTrendsCal, "Hospitalization Outcome",limits=c(0.18,4))
disjTimeTrendsSlideNoCal <- plotForestWrapper(forestDataDisjTimeTrendsNoCal, "Hospitalization Outcome",limits=c(0.18,4))
disjTimeTrendsSlideCal <- plotForestWrapper(forestDataDisjTimeTrendsCal, "Hospitalization Outcome",limits=c(0.18,4))

cumTimeTrendsSlideNoCal
cumTimeTrendsSlideCal
disjTimeTrendsSlideNoCal
disjTimeTrendsSlideCal

ggsave(filename = file.path(outputFolder,"cumTimeTrendsSlideNoCal.png"), plot=cumTimeTrendsSlideNoCal, width = 6.65, height = 3.76, units = "in")
ggsave(filename = file.path(outputFolder,"cumTimeTrendsSlideCal.png"), plot=cumTimeTrendsSlideCal, width = 6.65, height = 3.76, units = "in")
ggsave(filename = file.path(outputFolder,"disjTimeTrendsSlideNoCal.png"), plot=disjTimeTrendsSlideNoCal, width = 6.65, height = 3.76, units = "in")
ggsave(filename = file.path(outputFolder,"disjTimeTrendsSlideCal.png"), plot=disjTimeTrendsSlideCal, width = 6.65, height = 3.76, units = "in")

# Creating Forest Plot Showing Sn Analyses for Time Trends - Exacerbation

forestDataCumTimeTrendsNoCalExac <- 
  rbind(forestPlotRow("HERMESp2Hydra",2336,2337,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label="2006-2017"),
        forestPlotRow("HERMESp2Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label="2006-2020")
  )
forestDataDisjTimeTrendsNoCalExac <- 
  rbind(forestPlotRow("HERMESp2Hydra",2354,2355,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label="Pre-2014"),
        forestPlotRow("HERMESp2Hydra",2357,2358,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label="Post-2015")
  )
forestDataCumTimeTrendsCalExac <- 
  rbind(forestPlotRow("HERMESp2Hydra",2336,2337,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="2006-2017"),
        forestPlotRow("HERMESp2Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="2006-2020")
  )
forestDataDisjTimeTrendsCalExac <- 
  rbind(forestPlotRow("HERMESp2Hydra",2354,2355,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Pre-2014"),
        forestPlotRow("HERMESp2Hydra",2357,2358,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Post-2015")
  )
cumTimeTrendsSlideNoCalExac <- plotForestWrapper(forestDataCumTimeTrendsNoCalExac, "Exacerbation Outcome",limits=c(0.18,4))
cumTimeTrendsSlideCalExac <- plotForestWrapper(forestDataCumTimeTrendsCalExac, "Exacerbation Outcome",limits=c(0.18,4))
disjTimeTrendsSlideNoCalExac <- plotForestWrapper(forestDataDisjTimeTrendsNoCalExac, "Exacerbation Outcome",limits=c(0.18,4))
disjTimeTrendsSlideCalExac <- plotForestWrapper(forestDataDisjTimeTrendsCalExac, "Exacerbation Outcome",limits=c(0.18,4))

cumTimeTrendsSlideNoCalExac
cumTimeTrendsSlideCalExac
disjTimeTrendsSlideNoCalExac
disjTimeTrendsSlideCalExac

ggsave(filename = file.path(outputFolder,"cumTimeTrendsSlideNoCalExac.png"), plot=cumTimeTrendsSlideNoCalExac, width = 6.65, height = 3.76, units = "in")
ggsave(filename = file.path(outputFolder,"cumTimeTrendsSlideCalExac.png"), plot=cumTimeTrendsSlideCalExac, width = 6.65, height = 3.76, units = "in")
ggsave(filename = file.path(outputFolder,"disjTimeTrendsSlideNoCalExac.png"), plot=disjTimeTrendsSlideNoCalExac, width = 6.65, height = 3.76, units = "in")
ggsave(filename = file.path(outputFolder,"disjTimeTrendsSlideCalExac.png"), plot=disjTimeTrendsSlideCalExac, width = 6.65, height = 3.76, units = "in")



# Creating Forest Plot Showing Ingredient Break-Out WITHIN CCAE DATABASE FOR STANDARD 2020 COHORTS

forestIngredientTrendsHospCal <- 
  rbind(forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="GLP1 Class"),
        forestPlotRow("HERMESp4Hydra",2413,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Liraglutide"),
        forestPlotRow("HERMESp4Hydra",2416,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Semaglutide"),
        forestPlotRow("HERMESp4Hydra",2415,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Dulaglutide"),
        forestPlotRow("HERMESp4Hydra",2414,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Exenatide")
  )
forestIngredientTrendsExacCal <- 
  rbind(forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="GLP1 Class"),
        forestPlotRow("HERMESp4Hydra",2413,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" Liraglutide"),
        forestPlotRow("HERMESp4Hydra",2416,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" Semaglutide"),
        forestPlotRow("HERMESp4Hydra",2415,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" Dulaglutide"),
        forestPlotRow("HERMESp4Hydra",2414,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" Exenatide")
  )

ingredientSlideHospCal <- plotForestWrapper(forestIngredientTrendsHospCal, "IBM CCAE, 2006-2020, Hospitalizations", limits=c(0.15,5))
ingredientSlideExacCal <- plotForestWrapper(forestIngredientTrendsExacCal, "IBM CCAE, 2006-2020, Exacerbations", limits=c(0.15,5))

ingredientSlideHospCal
ingredientSlideExacCal

ggsave(filename = file.path(outputFolder,"ingredientSlideHospCal.png"), plot=ingredientSlideHospCal, width = 6.65, height = 3.76, units = "in")
ggsave(filename = file.path(outputFolder,"ingredientSlideExacCal.png"), plot=ingredientSlideExacCal, width = 6.65, height = 3.76, units = "in")





# Creating Forest Plot Showing Network Results

forestNetworkNoCal <- 
  rbind(headerHosp,
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="Optum ClinFormatics", databaseId="OptumDOD"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="IBM MDCD", databaseId="TruvenMDCD"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="IBM MDCR", databaseId="TruvenMDCR"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="Optum EHR", databaseId="OptumEHR"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="IQVIA PharMetrics Plus", databaseId="PharmetricsPlus"),
        blankRowHosp1,
        headerExac,
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label=" IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label=" Optum ClinFormatics", databaseId="OptumDOD"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label=" IBM MDCD", databaseId="TruvenMDCD"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label=" IBM MDCR", databaseId="TruvenMDCR"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label=" Optum EHR", databaseId="OptumEHR"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label=" IQVIA PharMetrics Plus", databaseId="PharmetricsPlus")
        )

forestNetworkCal <- 
  rbind(headerHosp,
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Optum ClinFormatics", databaseId="OptumDOD"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM MDCD", databaseId="TruvenMDCD"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM MDCR", databaseId="TruvenMDCR"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Optum EHR", databaseId="OptumEHR"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IQVIA PharMetrics Plus", databaseId="PharmetricsPlus"),
        blankRowHosp1,
        headerExac,
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" Optum ClinFormatics", databaseId="OptumDOD"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IBM MDCD", databaseId="TruvenMDCD"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IBM MDCR", databaseId="TruvenMDCR"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" Optum EHR", databaseId="OptumEHR"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IQVIA PharMetrics Plus", databaseId="PharmetricsPlus")
  )

networkSlideNoCal <- plotForestWrapper(forestNetworkNoCal, "OHDSI Network Effects Summary")
networkSlideCal <- plotForestWrapper(forestNetworkCal, "OHDSI Network Effects Summary")

networkSlideNoCal
networkSlideCal

ggsave(filename = file.path(outputFolder,"networkSlideNoCal.png"), plot=networkSlideNoCal, width = 6.65, height = 3.76, units = "in")
ggsave(filename = file.path(outputFolder,"networkSlideCal.png"), plot=networkSlideCal, width = 6.65, height = 3.76, units = "in")





# Creating Forest Plot Showing The impact of Calibration - CCAE Hospitalizations - ADJUSTED

forestCalibrationHospStz <-
  rbind(forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="Uncalibrated"),
        forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Calibrated")
  )

calibrationSlideHospStz <- plotForestWrapper(forestCalibrationHospStz, "Adjusted, Hospitalizations")
calibrationSlideHospStz
ggsave(filename = file.path(outputFolder,"calibrationSlideHospStz.png"), plot=calibrationSlideHospStz, width = 6.65, height = 3.76, units = "in")

forestCalibrationHospSource <-
  rbind(forestPlotRow("HERMESp1Hydra",2334,2335,2338,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="Uncalibrated"),
        forestPlotRow("HERMESp1Hydra",2334,2335,2338,modelType="Cox",adjustment="PS-Stratification",calibration=FALSE, label="Calibrated")
  )

calibrationSlideHospSource <- plotForestWrapper(forestCalibrationHospSource, "Adjusted, Hospitalizations")
calibrationSlideHospSource
ggsave(filename = file.path(outputFolder,"calibrationSlideHospSource.png"), plot=calibrationSlideHospSource, width = 6.65, height = 3.76, units = "in")




# Creating Forest Plot Showing The Affect of Calibration - CCAE Exacerbations - ADJUSTED

forestCalibrationExacStz <-
  rbind(forestPlotRow("HERMESp2Hydra",2336,2337,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label="Uncalibrated"),
        forestPlotRow("HERMESp2Hydra",2336,2337,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Calibrated")
  )

calibrationSlideExacStz <- plotForestWrapper(forestCalibrationExacStz, "Adjusted, Exacerbations")
calibrationSlideExacStz
ggsave(filename = file.path(outputFolder,"calibrationSlideExacStz.png"), plot=calibrationSlideExacStz, width = 6.65, height = 3.76, units = "in")

forestCalibrationExacSource <-
  rbind(forestPlotRow("HERMESp2Hydra",2334,2335,2343,modelType="Poisson",adjustment="PS-Stratification",calibration=FALSE, label="Uncalibrated"),
        forestPlotRow("HERMESp2Hydra",2334,2335,2343,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Calibrated")
  )

calibrationSlideExacSource <- plotForestWrapper(forestCalibrationExacSource, "Adjusted, Exacerbations")
calibrationSlideExacSource
ggsave(filename = file.path(outputFolder,"calibrationSlideExacSource.png"), plot=calibrationSlideExacSource, width = 6.65, height = 3.76, units = "in")





# Creating Forest Plot Showing The impact of Calibration - CCAE Hospitalizations - Crude

forestCalibrationHospStzCrude <-
  rbind(forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="Crude",calibration=FALSE, label="Uncalibrated"),
        forestPlotRow("HERMESp1Hydra",2336,2337,2339,modelType="Cox",adjustment="Crude",calibration=TRUE, label="Calibrated")
  )

calibrationSlideHospStzCrude <- plotForestWrapper(forestCalibrationHospStzCrude, "Unadjusted, Hospitalizations")
calibrationSlideHospStzCrude
ggsave(filename = file.path(outputFolder,"calibrationSlideHospStzCrude.png"), plot=calibrationSlideHospStzCrude, width = 6.65, height = 3.76, units = "in")

forestCalibrationHospSourceCrude <-
  rbind(forestPlotRow("HERMESp1Hydra",2334,2335,2338,modelType="Cox",adjustment="Crude",calibration=FALSE, label="Uncalibrated"),
        forestPlotRow("HERMESp1Hydra",2334,2335,2338,modelType="Cox",adjustment="Crude",calibration=FALSE, label="Calibrated")
  )

calibrationSlideHospSourceCrude <- plotForestWrapper(forestCalibrationHospSourceCrude, "Unadjusted, Hospitalizations")
calibrationSlideHospSourceCrude
ggsave(filename = file.path(outputFolder,"calibrationSlideHospSourceCrude.png"), plot=calibrationSlideHospSourceCrude, width = 6.65, height = 3.76, units = "in")




# Creating Forest Plot Showing The Affect of Calibration - CCAE Exacerbations - Crude

forestCalibrationExacStzCrude <-
  rbind(forestPlotRow("HERMESp2Hydra",2336,2337,2342,modelType="Poisson",adjustment="Crude",calibration=FALSE, label="Uncalibrated"),
        forestPlotRow("HERMESp2Hydra",2336,2337,2342,modelType="Poisson",adjustment="Crude",calibration=TRUE, label="Calibrated")
  )

calibrationSlideExacStzCrude <- plotForestWrapper(forestCalibrationExacStzCrude, "Unadjusted, Exacerbations")
calibrationSlideExacStzCrude
ggsave(filename = file.path(outputFolder,"calibrationSlideExacStzCrude.png"), plot=calibrationSlideExacStzCrude, width = 6.65, height = 3.76, units = "in")

forestCalibrationExacSourceCrude <-
  rbind(forestPlotRow("HERMESp2Hydra",2334,2335,2343,modelType="Poisson",adjustment="Crude",calibration=FALSE, label="Uncalibrated"),
        forestPlotRow("HERMESp2Hydra",2334,2335,2343,modelType="Poisson",adjustment="Crude",calibration=TRUE, label="Calibrated")
  )

calibrationSlideExacSourceCrude <- plotForestWrapper(forestCalibrationExacSourceCrude, "Unadjusted, Exacerbations")
calibrationSlideExacSourceCrude
ggsave(filename = file.path(outputFolder,"calibrationSlideExacSourceCrude.png"), plot=calibrationSlideExacSourceCrude, width = 6.65, height = 3.76, units = "in")



# Creating Forest Plot Showing Network Results - DOD Hospitalizations

forestNetworkHospCalDOD <- 
  rbind(forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Optum ClinFormatics", databaseId="OptumDOD")
  )

networkHospSlideCalDOD <- plotForestWrapper(forestNetworkHospCalDOD, "Network: Optum ClinFormatics, Hospitalizations",colorKey="master")
networkHospSlideCalDOD
ggsave(filename = file.path(outputFolder,"networkHospSlideCalDOD.png"), plot=networkHospSlideCalDOD, width = 6.65, height = 3.76, units = "in")


# Creating Forest Plot Showing Network Results - DOD Exacerbations

forestNetworkExacCalDOD <- 
  rbind(forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" Optum ClinFormatics", databaseId="OptumDOD")
  )

networkExacSlideCalDOD <- plotForestWrapper(forestNetworkExacCalDOD, "Network: Optum ClinFormatics, Exacerbations",colorKey="master")
networkExacSlideCalDOD
ggsave(filename = file.path(outputFolder,"networkExacSlideCalDOD.png"), plot=networkExacSlideCalDOD, width = 6.65, height = 3.76, units = "in")


# Creating Forest Plot Showing Network Results - MDCD Hospitalizations

forestNetworkHospCalMDCD <- 
  rbind(forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM MDCD", databaseId="TruvenMDCD")
  )

networkHospSlideCalMDCD <- plotForestWrapper(forestNetworkHospCalMDCD, "Network: IBM MDCD, Hospitalizations",colorKey="master")
networkHospSlideCalMDCD
ggsave(filename = file.path(outputFolder,"networkHospSlideCalMDCD.png"), plot=networkHospSlideCalMDCD, width = 6.65, height = 3.76, units = "in")


# Creating Forest Plot Showing Network Results - MDCD Exacerbations

forestNetworkExacCalMDCD <- 
  rbind(forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IBM MDCD", databaseId="TruvenMDCD")
  )

networkExacSlideCalMDCD <- plotForestWrapper(forestNetworkExacCalMDCD, "Network: IBM MDCD, Exacerbations",colorKey="master")
networkExacSlideCalMDCD
ggsave(filename = file.path(outputFolder,"networkExacSlideCalMDCD.png"), plot=networkExacSlideCalMDCD, width = 6.65, height = 3.76, units = "in")

# Creating Forest Plot Showing Network Results - MDCR Hospitalizations

forestNetworkHospCalMDCR <- 
  rbind(forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM MDCR", databaseId="TruvenMDCR")
  )

networkHospSlideCalMDCR <- plotForestWrapper(forestNetworkHospCalMDCR, "Network: IBM MDCR, Hospitalizations",colorKey="master")
networkHospSlideCalMDCR
ggsave(filename = file.path(outputFolder,"networkHospSlideCalMDCR.png"), plot=networkHospSlideCalMDCR, width = 6.65, height = 3.76, units = "in")


# Creating Forest Plot Showing Network Results - MDCR Exacerbations

forestNetworkExacCalMDCR <- 
  rbind(forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IBM MDCR", databaseId="TruvenMDCR")
  )

networkExacSlideCalMDCR <- plotForestWrapper(forestNetworkExacCalMDCR, "Network: IBM MDCR, Exacerbations",colorKey="master")
networkExacSlideCalMDCR
ggsave(filename = file.path(outputFolder,"networkExacSlideCalMDCR.png"), plot=networkExacSlideCalMDCR, width = 6.65, height = 3.76, units = "in")

# Creating Forest Plot Showing Network Results - OptumEHR Hospitalizations

forestNetworkHospCalOptumEHR <- 
  rbind(forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Optum EHR", databaseId="OptumEHR")
  )

networkHospSlideCalOptumEHR <- plotForestWrapper(forestNetworkHospCalOptumEHR, "Network: Optum EHR, Hospitalizations",colorKey="master")
networkHospSlideCalOptumEHR
ggsave(filename = file.path(outputFolder,"networkHospSlideCalOptumEHR.png"), plot=networkHospSlideCalOptumEHR, width = 6.65, height = 3.76, units = "in")


# Creating Forest Plot Showing Network Results - OptumEHR Exacerbations

forestNetworkExacCalOptumEHR <- 
  rbind(forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" Optum EHR", databaseId="OptumEHR")
  )

networkExacSlideCalOptumEHR <- plotForestWrapper(forestNetworkExacCalOptumEHR, "Network: Optum EHR, Exacerbations",colorKey="master")
networkExacSlideCalOptumEHR
ggsave(filename = file.path(outputFolder,"networkExacSlideCalOptumEHR.png"), plot=networkExacSlideCalOptumEHR, width = 6.65, height = 3.76, units = "in")


# Creating Forest Plot Showing Network Results - PharmetricsPlus Hospitalizations

forestNetworkHospCalPharmetricsPlus <- 
  rbind(forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IQVIA PharMetrics Plus", databaseId="PharmetricsPlus")
  )

networkHospSlideCalPharmetricsPlus <- plotForestWrapper(forestNetworkHospCalPharmetricsPlus, "Network: IQVIA PharMetrics Plus, Hospitalizations",colorKey="master")
networkHospSlideCalPharmetricsPlus
ggsave(filename = file.path(outputFolder,"networkHospSlideCalPharmetricsPlus.png"), plot=networkHospSlideCalPharmetricsPlus, width = 6.65, height = 3.76, units = "in")


# Creating Forest Plot Showing Network Results - PharmetricsPlus Exacerbations

forestNetworkExacCalPharmetricsPlus <- 
  rbind(forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IQVIA PharMetrics Plus", databaseId="PharmetricsPlus")
  )

networkExacSlideCalPharmetricsPlus <- plotForestWrapper(forestNetworkExacCalPharmetricsPlus, "Network: IQVIA PharMetrics Plus, Exacerbations",colorKey="master")
networkExacSlideCalPharmetricsPlus
ggsave(filename = file.path(outputFolder,"networkExacSlideCalPharmetricsPlus.png"), plot=networkExacSlideCalPharmetricsPlus, width = 6.65, height = 3.76, units = "in")




# Creating Forest Plot Showing Ingredient Break-Out
# 
# forestIngredientHospCalOptumDOD <- 
#   rbind(forestPlotRow("HERMESp4Hydra",2414,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Exenatide (IBM CCAE)", databaseId="TruvenCCAE"),
#         forestPlotRow("HERMESp4Hydra",2414,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Exenatide (Optum Clinformatics)", databaseId="OptumDOD"),
#         forestPlotRow("HERMESp4Hydra",2413,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Liraglutide (IBM CCAE)", databaseId="TruvenCCAE"),
#         forestPlotRow("HERMESp4Hydra",2413,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Liraglutide (Optum Clinformatics)", databaseId="OptumDOD"),
#         forestPlotRow("HERMESp4Hydra",2415,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Dulaglutide (IBM CCAE)", databaseId="TruvenCCAE"),
#         forestPlotRow("HERMESp4Hydra",2415,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Dulaglutide (Optum Clinformatics)", databaseId="OptumDOD"),
#         forestPlotRow("HERMESp4Hydra",2416,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Semaglutide (IBM CCAE)", databaseId="TruvenCCAE"),
#         forestPlotRow("HERMESp4Hydra",2416,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Semaglutide (Optum Clinformatics)", databaseId="OptumDOD")
#   )
# forestIngredientExacCalOptumDOD <- 
#   rbind(forestPlotRow("HERMESp4Hydra",2414,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Exenatide (IBM CCAE)", databaseId="TruvenCCAE"),
#         forestPlotRow("HERMESp4Hydra",2414,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Exenatide (Optum Clinformatics)", databaseId="OptumDOD"),
#         forestPlotRow("HERMESp4Hydra",2413,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Liraglutide (IBM CCAE)", databaseId="TruvenCCAE"),
#         forestPlotRow("HERMESp4Hydra",2413,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Liraglutide (Optum Clinformatics)", databaseId="OptumDOD"),
#         forestPlotRow("HERMESp4Hydra",2415,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Dulaglutide (IBM CCAE)", databaseId="TruvenCCAE"),
#         forestPlotRow("HERMESp4Hydra",2415,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Dulaglutide (Optum Clinformatics)", databaseId="OptumDOD"),
#         forestPlotRow("HERMESp4Hydra",2416,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Semaglutide (IBM CCAE)", databaseId="TruvenCCAE"),
#         forestPlotRow("HERMESp4Hydra",2416,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Semaglutide (Optum Clinformatics)", databaseId="OptumDOD")
#   )
# 
# ingredientSlideHospCalOptumDOD <- plotForestWrapper(forestIngredientHospCalOptumDOD, "By Ingredient: Optum Clinformatics, Hospitalization", color="database_id")
# ingredientSlideExacCalOptumDOD <- plotForestWrapper(forestIngredientExacCalOptumDOD, "By Ingredient: Optum Clinformatics, Exacerbation", color="database_id")
# 
# ingredientSlideHospCalOptumDOD
# ingredientSlideExacCalOptumDOD
# 
# ggsave(filename = file.path(outputFolder,"ingredientSlideHospCalOptumDOD.png"), plot=ingredientSlideHospCalOptumDOD, width = 6.65, height = 3.76, units = "in")
# ggsave(filename = file.path(outputFolder,"ingredientSlideExacCalOptumDOD.png"), plot=ingredientSlideExacCalOptumDOD, width = 6.65, height = 3.76, units = "in")
# 



networkIngredients <- function(databaseId,databaseLabel){
  
  assign(paste0("forestIngredientHospCal",databaseId),
         rbind(forestPlotRow("HERMESp4Hydra",2414,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Exenatide", databaseId="TruvenCCAE"),
               forestPlotRow("HERMESp4Hydra",2414,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label=" ", databaseId=databaseId),
               forestPlotRow("HERMESp4Hydra",2413,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Liraglutide", databaseId="TruvenCCAE"),
               forestPlotRow("HERMESp4Hydra",2413,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="  ", databaseId=databaseId),
               forestPlotRow("HERMESp4Hydra",2415,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Dulaglutide", databaseId="TruvenCCAE"),
               forestPlotRow("HERMESp4Hydra",2415,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="   ", databaseId=databaseId),
               forestPlotRow("HERMESp4Hydra",2416,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Semaglutide", databaseId="TruvenCCAE"),
               forestPlotRow("HERMESp4Hydra",2416,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="    ", databaseId=databaseId)
         )
  )
  
  assign(paste0("forestIngredientExacCal",databaseId),
         rbind(forestPlotRow("HERMESp4Hydra",2414,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Exenatide", databaseId="TruvenCCAE"),
               forestPlotRow("HERMESp4Hydra",2414,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="", databaseId=databaseId),
               forestPlotRow("HERMESp4Hydra",2413,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Liraglutide", databaseId="TruvenCCAE"),
               forestPlotRow("HERMESp4Hydra",2413,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" ", databaseId=databaseId),
               forestPlotRow("HERMESp4Hydra",2415,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Dulaglutide", databaseId="TruvenCCAE"),
               forestPlotRow("HERMESp4Hydra",2415,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="  ", databaseId=databaseId),
               forestPlotRow("HERMESp4Hydra",2416,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Semaglutide", databaseId="TruvenCCAE"),
               forestPlotRow("HERMESp4Hydra",2416,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="   ", databaseId=databaseId)
         )
  )
  
  assign(paste0("ingredientSlideHospCal",databaseId),plotForestWrapper(get(paste0("forestIngredientHospCal",databaseId)), 
                                                                       paste0("By Ingredient: ",databaseLabel,", Hospitalization"), colorKey="master"))
  assign(paste0('ingredientSlideExacCal',databaseId),plotForestWrapper(get(paste0("forestIngredientExacCal",databaseId)), 
                                                                       paste0("By Ingredient: ",databaseLabel,", Exacerbation"), colorKey="master"))
  
 # get(paste0("ingredientSlideHospCal",databaseId))
 # get(paste0('ingredientSlideExacCal',databaseId))
  
  ggsave(filename = file.path(outputFolder,paste0("ingredientSlideHospCal",databaseId,".png")), plot=get(paste0("ingredientSlideHospCal",databaseId)), width = 6.65, height = 3.76, units = "in")
  ggsave(filename = file.path(outputFolder,paste0("ingredientSlideExacCal",databaseId,".png")), plot=get(paste0('ingredientSlideExacCal',databaseId)), width = 6.65, height = 3.76, units = "in")
  
}

networkIngredients("OptumDOD","Optum ClinFormatics")
networkIngredients("TruvenMDCD","IBM MDCD")
networkIngredients("TruvenMDCR","IBM MDCR")
networkIngredients("OptumEHR","Optum EHR")
networkIngredients("PharmetricsPlus","IQVIA PharMetrics Plus")


# Ingredient level forest-plots displaying multiple databases
networkIngredients2 <- function(ingredientCohortId,ingredientLabel,outcome="Hospitalization"){
  
  if (outcome=="Hospitalization") {
    
    assign(paste0("forestIngredientHospCal",ingredientLabel),
           rbind(forestPlotRow("HERMESp4Hydra",ingredientCohortId,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM CCAE", databaseId="TruvenCCAE"),
                 forestPlotRow("HERMESp4Hydra",ingredientCohortId,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Optum ClinFormatics", databaseId="OptumDOD"),
                 forestPlotRow("HERMESp4Hydra",ingredientCohortId,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM MDCD", databaseId="TruvenMDCD"),
                 forestPlotRow("HERMESp4Hydra",ingredientCohortId,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM MDCR", databaseId="TruvenMDCR"), 
                 forestPlotRow("HERMESp4Hydra",ingredientCohortId,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Optum EHR", databaseId="OptumEHR"),
                 forestPlotRow("HERMESp4Hydra",ingredientCohortId,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IQVIA PharMetrics Plus", databaseId="PharmetricsPlus")
           )
    )
    
    assign(paste0("ingredientSlideHospCal",ingredientLabel),plotForestWrapper(get(paste0("forestIngredientHospCal",ingredientLabel)), 
                                                                              paste0("By Database: ",ingredientLabel,", Hospitalization")))
    
    # get(paste0("ingredientSlideHospCal",ingredientLabel))
    
    ggsave(filename = file.path(outputFolder,paste0("ingredientSlideHospCal",ingredientLabel,".png")), plot=get(paste0("ingredientSlideHospCal",ingredientLabel)), width = 6.65, height = 3.76, units = "in")
    
    return(get(paste0("forestIngredientHospCal",ingredientLabel)))
  } else {
    
    assign(paste0("forestIngredientExacCal",ingredientLabel),
           rbind(forestPlotRow("HERMESp4Hydra",ingredientCohortId,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="IBM CCAE", databaseId="TruvenCCAE"),
                 forestPlotRow("HERMESp4Hydra",ingredientCohortId,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Optum ClinFormatics", databaseId="OptumDOD"),
                 forestPlotRow("HERMESp4Hydra",ingredientCohortId,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="IBM MDCD", databaseId="TruvenMDCD"),
                 forestPlotRow("HERMESp4Hydra",ingredientCohortId,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="IBM MDCR", databaseId="TruvenMDCR"), 
                 forestPlotRow("HERMESp4Hydra",ingredientCohortId,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="Optum EHR", databaseId="OptumEHR"),
                 forestPlotRow("HERMESp4Hydra",ingredientCohortId,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label="IQVIA PharMetrics Plus", databaseId="PharmetricsPlus")
           )
    )
    assign(paste0('ingredientSlideExacCal',ingredientLabel),plotForestWrapper(get(paste0("forestIngredientExacCal",ingredientLabel)), 
                                                                              paste0("By Database: ",ingredientLabel,", Exacerbation")))
    
    # get(paste0("ingredientSlideExacpCal",ingredientLabel))
    
    ggsave(filename = file.path(outputFolder,paste0("ingredientSlideExacCal",ingredientLabel,".png")), plot=get(paste0('ingredientSlideExacCal',ingredientLabel)), width = 6.65, height = 3.76, units = "in")
    
    return(get(paste0("forestIngredientExacCal",ingredientLabel)))
  }
}

#The calls below save a forestplot fo the folder and also assign the corresponding data to an R object for meta-analysis

ExenatideHospMeta <- networkIngredients2(2414, "Exenatide", outcome="Hospitalization")
LiraglutideHospMeta <- networkIngredients2(2413, "Liraglutide", outcome="Hospitalization")
DulaglutideHospMeta <- networkIngredients2(2415, "Dulaglutide", outcome="Hospitalization")
SemaglutideHospMeta <- networkIngredients2(2416, "Semaglutide", outcome="Hospitalization")
ExenatideExacMeta <- networkIngredients2(2414, "Exenatide", outcome="Exacerbation")
LiraglutideExacMeta <- networkIngredients2(2413, "Liraglutide", outcome="Exacerbation")
DulaglutideExacMeta <- networkIngredients2(2415, "Dulaglutide", outcome="Exacerbation")
SemaglutideExacMeta <- networkIngredients2(2416, "Semaglutide", outcome="Exacerbation")

# columnBreaker <- function(input) {
#   output <- input
#   output$ingredient <- gsub("([A-Za-z]+).*", "\\1", input$label)
#   return(output)
# }
# columnBreaker(ExenatideHospMeta)
# columnBreaker(LiraglutideHospMeta)
# columnBreaker(DulaglutideHospMeta)
# columnBreaker(SemaglutideHospMeta)
# columnBreaker(ExenatideExacMeta)
# columnBreaker(LiraglutideExacMeta)
# columnBreaker(DulaglutideExacMeta)
# columnBreaker(SemaglutideExacMeta)

ingredientMetaRowsHosp <- rbind(ExenatideHospMeta,LiraglutideHospMeta,DulaglutideHospMeta,SemaglutideHospMeta)
ingredientMetaRowsHosp$ingredient <- gsub("([A-Za-z]+).*", "\\1", ingredientMetaRowsHosp$label)
ingredientMetaRowsExac <- rbind(ExenatideExacMeta,LiraglutideExacMeta,DulaglutideExacMeta,SemaglutideExacMeta)
ingredientMetaRowsExac$ingredient <- gsub("([A-Za-z]+).*", "\\1", ingredientMetaRowsExac$label)

primaryMetaRowsHosp <-  
  rbind(forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Optum ClinFormatics", databaseId="OptumDOD"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM MDCD", databaseId="TruvenMDCD"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IBM MDCR", databaseId="TruvenMDCR"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="Optum EHR", databaseId="OptumEHR"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2339,modelType="Cox",adjustment="PS-Stratification",calibration=TRUE, label="IQVIA PharMetrics Plus", databaseId="PharmetricsPlus")
  )
primaryMetaRowsExac <-
  rbind(forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IBM CCAE", databaseId="TruvenCCAE"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" Optum ClinFormatics", databaseId="OptumDOD"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IBM MDCD", databaseId="TruvenMDCD"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IBM MDCR", databaseId="TruvenMDCR"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" Optum EHR", databaseId="OptumEHR"),
        forestPlotRow("HERMESp4Hydra",2344,2345,2342,modelType="Poisson",adjustment="PS-Stratification",calibration=TRUE, label=" IQVIA PharMetrics Plus", databaseId="PharmetricsPlus")
  )
primaryMetaRowsHosp
primaryMetaRowsExac

#Condcuting Meta-Analyses using the meta::metagen function
# Main Effects Meta-Analysis
metaResultsHosp <- meta::metagen(TE = primaryMetaRowsHosp$log_rr,
                          seTE = primaryMetaRowsHosp$se_log_rr, 
                          sm = "RR", 
                          hakn = FALSE)

metaResultsExac <- meta::metagen(TE = primaryMetaRowsExac$log_rr,
                          seTE = primaryMetaRowsExac$se_log_rr, 
                          sm = "RR", 
                          hakn = FALSE)


# Ingredient-Level Effects Meta-Analysis

metaResultsExenatideHosp <- meta::metagen(TE = ExenatideHospMeta$log_rr,
                                          seTE = ExenatideHospMeta$se_log_rr, 
                                          sm = "RR", 
                                          hakn = FALSE)
metaResultsLiraglutideHosp <- meta::metagen(TE = LiraglutideHospMeta$log_rr,
                                            seTE = LiraglutideHospMeta$se_log_rr, 
                                            sm = "RR", 
                                            hakn = FALSE)
metaResultsDulaglutideHosp <- meta::metagen(TE = DulaglutideHospMeta$log_rr,
                                            seTE = DulaglutideHospMeta$se_log_rr, 
                                            sm = "RR", 
                                            hakn = FALSE)
metaResultsSemaglutideHosp <- meta::metagen(TE = SemaglutideHospMeta$log_rr,
                                            seTE = SemaglutideHospMeta$se_log_rr, 
                                            sm = "RR", 
                                            hakn = FALSE)

metaResultsExenatideExac <- meta::metagen(TE = ExenatideExacMeta$log_rr,
                                          seTE = ExenatideExacMeta$se_log_rr, 
                                          sm = "RR", 
                                          hakn = FALSE)
metaResultsLiraglutideExac <- meta::metagen(TE = LiraglutideExacMeta$log_rr,
                                            seTE = LiraglutideExacMeta$se_log_rr, 
                                            sm = "RR", 
                                            hakn = FALSE)
metaResultsDulaglutideExac <- meta::metagen(TE = DulaglutideExacMeta$log_rr,
                                            seTE = DulaglutideExacMeta$se_log_rr, 
                                            sm = "RR", 
                                            hakn = FALSE)
metaResultsSemaglutideExac <- meta::metagen(TE = SemaglutideExacMeta$log_rr,
                                            seTE = SemaglutideExacMeta$se_log_rr, 
                                            sm = "RR", 
                                            hakn = FALSE)

metaDigester <- function(data,description){
  output <-
    data.frame(
      "Description"=description,
      "HR"=paste0(round(exp(data$TE.random),2)," (",
                  round(exp(data$lower.random),2),", ",
                  round(exp(data$upper.random),2),")"),
      "I^2"=data$I2
    )
  return(output)
}


metaResultsDulaglutideExac$seTE.random

masterMetaResultsTable <-
  rbind(metaDigester(metaResultsHosp,"Main Effects: Hospitalizations"),
        metaDigester(metaResultsExac,"Main Effects: Exacerbations"),
        metaDigester(metaResultsExenatideHosp,"Ingredient: Exenatide Hospitalizations"),
        metaDigester(metaResultsLiraglutideHosp,"Ingredient: Liraglutide Hospitalizations"),
        metaDigester(metaResultsDulaglutideHosp,"Ingredient: Dulaglutide Hospitalizations"),
        metaDigester(metaResultsSemaglutideHosp,"Ingredient: Semaglutide Hospitalizations"),
        metaDigester(metaResultsExenatideExac,"Ingredient: Exenatide Exacerbations"),
        metaDigester(metaResultsLiraglutideExac,"Ingredient: Liraglutide Exacerbations"),
        metaDigester(metaResultsDulaglutideExac,"Ingredient: Dulaglutide Exacerbations"),
        metaDigester(metaResultsSemaglutideExac,"Ingredient: Semaglutide Exacerbations")
  )
masterMetaResultsTable

metaDigester2 <- function(data,description,label){
  output <-
    data.frame("analysis_id"=99,"target_id"=NA,"comparator_id"=NA,"outcome_id"=NA,"database_id"="MetaAnalysis",
               "log_rr"= data$TE.random,
               "se_log_rr"=data$seTE.random,
               "description"=description,
               "modelType"="Random Effects",
               "adjustment"="",
               "label"=label,
               "source"="Meta-Analysis")
  return(output)
}

masterMetaResultsForestInputs <-
  rbind(metaDigester2(metaResultsHosp,"GLP1 Class","Hospitalizations"),
        metaDigester2(metaResultsExac,"GLP1 Class","Exacerbations"),
        metaDigester2(metaResultsExenatideHosp,"Exenatide","Hospitalizations"),
        metaDigester2(metaResultsLiraglutideHosp,"Liraglutide","Hospitalizations"),
        metaDigester2(metaResultsDulaglutideHosp,"Dulaglutide","Hospitalizations"),
        metaDigester2(metaResultsSemaglutideHosp,"Semaglutide","Hospitalizations"),
        metaDigester2(metaResultsExenatideExac,"Exenatide","Exacerbations"),
        metaDigester2(metaResultsLiraglutideExac,"Liraglutide","Exacerbations"),
        metaDigester2(metaResultsDulaglutideExac,"Dulaglutide","Exacerbations"),
        metaDigester2(metaResultsSemaglutideExac,"Semaglutide","Exacerbations")
  )
masterMetaResultsForestInputs

# Generating Cross-Network ForestPlot with Meta Analysis Estimates
forestNetworkHospCalMeta <- 
  rbind(primaryMetaRowsHosp,
        blankRowHosp1,
        masterMetaResultsForestInputs[which(masterMetaResultsForestInputs$description=="GLP1 Class" &
                                              masterMetaResultsForestInputs$label=="Hospitalizations"),])

forestNetworkHospCalMeta$label <-
  ifelse(forestNetworkHospCalMeta$label == "Hospitalizations","Meta-Analysis",forestNetworkHospCalMeta$label)

networkHospSlideCalMeta <- plotForestWrapper(forestNetworkHospCalMeta, "OHDSI Network: Hospitalization",colorKey="master")
networkHospSlideCalMeta
ggsave(filename = file.path(outputFolder,"networkHospSlideCalMeta.png"), plot=networkHospSlideCalMeta, width = 6.65, height = 3.76, units = "in")

# Figure 2 Left Panel for manuscript
networkHospFigureCalMeta <- plotForestWrapper(forestNetworkHospCalMeta, "OHDSI Network: Hospitalization",colorKey="masterManuscript")
networkHospFigureCalMeta
ggsave(filename = file.path(outputFolder,"networkHospFigureCalMeta.png"), plot=networkHospFigureCalMeta, width = 6.8, height = 3.76, units = "in")


forestNetworkExacCalMeta <- 
  rbind(primaryMetaRowsExac,
        blankRowExac1,
        masterMetaResultsForestInputs[which(masterMetaResultsForestInputs$description=="GLP1 Class" &
                                              masterMetaResultsForestInputs$label=="Exacerbations"),])

forestNetworkExacCalMeta$label <-
  ifelse(forestNetworkExacCalMeta$label == "Exacerbations","Meta-Analysis",forestNetworkExacCalMeta$label)


networkExacSlideCalMeta <- plotForestWrapper(forestNetworkExacCalMeta, "OHDSI Network: Exacerbations",colorKey="master")
networkExacSlideCalMeta
ggsave(filename = file.path(outputFolder,"networkExacSlideCalMeta.png"), plot=networkExacSlideCalMeta, width = 6.65, height = 3.76, units = "in")

# Figure 2 Right Panel for manuscript
networkExacFigureCalMeta <- plotForestWrapper(forestNetworkExacCalMeta, "OHDSI Network: Exacerbations",colorKey="masterManuscript")
networkExacFigureCalMeta
ggsave(filename = file.path(outputFolder,"networkExacFigureCalMeta.png"), plot=networkExacFigureCalMeta, width = 6.65, height = 3.76, units = "in")

# Generating Cross-Network Ingredient-specific forestPlots with Meta Analysis Estimates

ingredientMetaForest <- function(ingredient,colorScheme="master") { # ingredient <- "Exenatide"
  
  forestDataHosp <- 
    rbind(get(paste0(ingredient,"HospMeta")),
          blankRowHosp1,
          masterMetaResultsForestInputs[which(masterMetaResultsForestInputs$description==ingredient &
                                                masterMetaResultsForestInputs$label=="Hospitalizations"),]
          )
  
  forestDataHosp$label <-
    ifelse(forestDataHosp$label == "Hospitalizations","Meta-Analysis",forestDataHosp$label)
  
  forestPlotHosp <- plotForestWrapper(forestDataHosp, paste0("OHDSI Network: ",ingredient," Hospitalizations"),colorKey=colorScheme)
  #forestPlotHosp
  ggsave(filename = file.path(outputFolder,paste0("networkHospSlideCalMeta",ingredient,".png")), 
         plot=forestPlotHosp, width = 6.65, height = 3.76, units = "in")
  
  forestDataExac <- 
    rbind(get(paste0(ingredient,"ExacMeta")),
          blankRowExac1,
          masterMetaResultsForestInputs[which(masterMetaResultsForestInputs$description==ingredient &
                                                masterMetaResultsForestInputs$label=="Exacerbations"),]
    )
  
  forestDataExac$label <-
    ifelse(forestDataExac$label == "Exacerbations","Meta-Analysis",forestDataExac$label)
  
  forestPlotExac <- plotForestWrapper(forestDataExac, paste0("OHDSI Network: ",ingredient," Exacerbations"),colorKey=colorScheme)
  #forestPlotExac
  ggsave(filename = file.path(outputFolder,paste0("networkExacSlideCalMeta",ingredient,".png")), 
         plot=forestPlotExac, width = 6.65, height = 3.76, units = "in")
  
}
# Figures for slides
ingredientMetaForest("Exenatide")
ingredientMetaForest("Liraglutide")
ingredientMetaForest("Dulaglutide")
ingredientMetaForest("Semaglutide")

# Figure 3 panels
ingredientMetaForest("Exenatide", colorScheme="masterManuscript")
ingredientMetaForest("Liraglutide", colorScheme="masterManuscript")
ingredientMetaForest("Dulaglutide", colorScheme="masterManuscript")
ingredientMetaForest("Semaglutide", colorScheme="masterManuscript")

# generating forest plot containing only meta-analysis estimates (ingredients and main)

masterMetaResultsForestInputsHosp <- masterMetaResultsForestInputs[which(masterMetaResultsForestInputs$label=="Hospitalizations"),]
masterMetaResultsForestInputsExac <- masterMetaResultsForestInputs[which(masterMetaResultsForestInputs$label=="Exacerbations"),]
masterMetaResultsForestInputsHosp$label <- masterMetaResultsForestInputsHosp$description
masterMetaResultsForestInputsExac$label <- masterMetaResultsForestInputsExac$description
allHospMetaResultsPlot <- plotForestWrapper(masterMetaResultsForestInputsHosp, "Network Meta-Analyses, Hospitalizations",colorKey="master")
allHospMetaResultsPlot
ggsave(filename = file.path(outputFolder,"allHospMetaResultsPlot.png"), plot=allHospMetaResultsPlot, width = 6.65, height = 3.76, units = "in")

allExacMetaResultsPlot <- plotForestWrapper(masterMetaResultsForestInputsExac, "Network Meta-Analyses, Exacerbations",colorKey="master")
allExacMetaResultsPlot
ggsave(filename = file.path(outputFolder,"allExacMetaResultsPlot.png"), plot=allExacMetaResultsPlot, width = 6.65, height = 3.76, units = "in")



# Code to count how many covariates that were considered by the large-scale regression algorithm
nrow(readRDS("D:/StudyResults/GLP1Repro/CohortMethod/HERMESp1Hydra/shinyData/covariate_balance_t2334_c2335_TruvenCCAE.rds"))



# 2413,Liraglutide new users 2006-2020,2413,Liraglutide_new_users_20062020
# 2416,Semaglutide new users 2006-2020,2416,Semaglutide_new_users_20062020
# 2415,Dulaglutide new users 2006-2020,2415,Dulaglutide_new_users_20062020
# 2414,Exenatide new users 2006-2020,2414,Exenatide_new_users_20062020
# 2345,DPP4 new users 2006-2020,2345,DPP4_new_users_20062020

# 2334 GLP1 new users via source codes 2006-2017
# 2336 GLP1 new users via standard concepts 2006-2017
# 2335 DPP4 new users via source codes 2006-2017
# 2337 DPP4 new users via standard concepts 2006-2017

# 2338 CLRD hospitalizations via source codes
# 2339 CLRD hospitalizations via standard concepts
# 2343 CLRD exacerbations via source codes
# 2342 CLRD exacerbations via standard concepts

# 2367,GLP1 new users with asthma 2006-2017,2367,GLP1_new_users_with_asthma_20062017
# 2368,DPP4 new users with asthma 2006-2017,2368,DPP4_new_users_with_asthma_20062017
# 2369,GLP1 new users with COPD 2006-2017,2369,GLP1_new_users_with_COPD_20062017
# 2370,DPP4 new users with COPD 2006-2017,2370,DPP4_new_users_with_COPD_20062017

# 2392,GLP1 new users via standard no prior sulf 2006-2017,2392,GLP1_new_users_via_standard_no_prior_sulf_20062017
# 2360,Sulfonylureas new users 2006-2017,2360,Sulfonylureas_new_users_20062017

# 2359,CLRD hospitalizations primary only,2359,CLRD_hospitalizations_primary_only


# 2363,GLP1 new users 2006-2018,2363,GLP1_new_users_20062018
# 2364,DPP4 new users 2006-2018,2364,DPP4_new_users_20062018
# 2365,GLP1 new users 2006-2019,2365,GLP1_new_users_20062019
# 2366,DPP4 new users 2006-2019,2366,DPP4_new_users_20062019
# 2344,GLP1 new users 2006-2020,2344,GLP1_new_users_20062020
# 2345,DPP4 new users 2006-2020,2345,DPP4_new_users_20062020
# 2361,GLP1 new users with prior or concurrent T2DM drug 2006-2017,2361,GLP1_new_users_with_prior_or_concurrent_T2DM_drug_20062017
# 2362,DPP4 new users with prior or concurrent T2DM drug 2006-2017,2362,DPP4_new_users_with_prior_or_concurrent_T2DM_drug_20062017

# 2354,GLP1 new users 2006-1Oct2014 with ICD9CM,2354,GLP1_new_users_20061Oct2014_with_ICD9CM
# 2355,DPP4 new users 2006-1Oct2014 with ICD9CM,2355,DPP4_new_users_20061Oct2014_with_ICD9CM
# 2357,GLP1 new users 1Nov2015-2020 with ICD10CM,2357,GLP1_new_users_1Nov20152020_with_ICD10CM
# 2358,DPP4 new users 1Nov2015-2020 with ICD10CM,2358,DPP4_new_users_1Nov20152020_with_ICD10CM




