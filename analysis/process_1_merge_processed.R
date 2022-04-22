args = commandArgs(trailingOnly=TRUE)

topDir = args[[1]]
datasetSurveyLocs = args[[2]]
datasetTargetInf = args[[3]]
mergedStr = args[[4]]
batchPaths = NULL

# topDir = "results_fitting/sim_output_agg/model_2/"
# datasetSurveyLocs = "survey_data_C"
# datasetTargetInf = "survey_data_C"
# mergedStr = "2020_12_01_merged"

# topDir = "results_fitting/sim_output_agg/model_2/"
# datasetSurveyLocs = "survey_data_C"
# datasetTargetInf = "params_0_job4_artificial_survey"
# mergedStr = "2020_01_27_merged"

# topDir = "results_fitting/sim_output_agg/model_0/"
# datasetSurveyLocs = "survey_data_C"
# datasetTargetInf = "survey_data_C"
# mergedStr = "2020_09_19_merged"

# topDir = "results_fitting/sim_output_agg/model_1/"
# datasetSurveyLocs = "survey_data_C"
# datasetTargetInf = "survey_data_C"
# mergedStr = "2022_01_20_merged"

# topDir = "results_fitting/sim_output_agg/model_0B/"
# datasetSurveyLocs = "survey_data_C"
# datasetTargetInf = "survey_data_C"
# mergedStr = "2022_02_03_merged"

# topDir = "results_validation/sim_output_agg/model_3/"
# datasetSurveyLocs = "survey_data_C"
# datasetTargetInf = "survey_data_C"
# mergedStr = "2022_02_28_merged"
# batchPaths = c(
#     "./results_validation/sim_output_agg/model_3/2022_02_23_batch_0/",
#     "./results_validation/sim_output_agg/model_3/2022_02_25_batch_0/"
# )

# ------------------------

outDir = file.path(topDir, mergedStr, datasetSurveyLocs, datasetTargetInf)
dir.create(outDir, recursive = T, showWarnings = F)

# If subset of batches not explicitly defined, use all batches in topDir
if(is.null(batchPaths)){
    batchPaths = list.files(topDir, pattern="_batch_", full.names = T)
}

# -----------------------

dfNameVec = c(
    # "results_summary_fixed_TARGET.rds",
    "results_summary_fixed_TARGET_SHRINK.rds",
    "results_summary_fixed_TARGET_MINIMAL.rds",
    "grid_sim_pass_criteria.rds"
)

for(thisDfName in dfNameVec){
  
  print(thisDfName)

  outPath = file.path(outDir, thisDfName)
  
  dfList = list()
  for(thisBatchPath in batchPaths){
    
    print(thisBatchPath)
      
    thisDfPath = file.path(thisBatchPath, datasetSurveyLocs, datasetTargetInf, thisDfName)
    dfList[[thisDfPath]] = readRDS(thisDfPath)
        
  }
  
  outDf = dplyr::bind_rows(dfList)
  
  saveRDS(outDf, outPath)
  
}

# Write out batchlist
logOutPath = file.path(outDir, "batchlist.txt")
fileConn=file(logOutPath)
writeLines(batchPaths, fileConn)
close(fileConn)
