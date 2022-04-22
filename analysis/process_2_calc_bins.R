args = commandArgs(trailingOnly=TRUE)

# dataDir = "results_fitting/sim_output_agg/model_0/2020_01_27_merged/survey_data_C/"
# dataDir = "results_fitting/sim_output_agg/model_2/2020_01_27_merged/survey_data_C/survey_data_C/"
# dataDir = "results_validation/sim_output_agg/model_2/2020_06_28_batch_0/survey_data_C/survey_data_C/"
# dataDir = "results_scenario_0/sim_output_agg/model_2/2020_07_25_batch_0/survey_data_C/survey_data_C/"
# dataDir = "results_fitting/sim_output_agg/model_1/2020_09_13_merged/survey_data_C/survey_data_C/"
# dataDir = "results_fitting/sim_output_agg/model_2/2020_12_28_sample/survey_data_C/survey_data_C"
# dataDir = "results_fitting/sim_output_agg/model_2/2021_12_01_merged/survey_data_C/survey_data_C/"
# dataDir = "results_fitting/sim_output_agg/model_0/2022_01_20_merged/survey_data_C/survey_data_C/"
# dataDir = "results_fitting/sim_output_agg/model_2/2022_01_19_sample/survey_data_C/survey_data_C"

dataDir = args[[1]]

paramDataPath = file.path(dataDir, "results_summary_fixed_TARGET_MINIMAL.rds")
breaksDataPath = "templates/breaks.json"

paramBinDataOutPath = file.path(dataDir, "results_summary_fixed_TARGET_MINIMAL_BINS.rds")
freqDfOutPath = file.path(dataDir, "binFreq.rds")

paramDataRaw = readRDS(paramDataPath)
breaksData = rjson::fromJSON(file=breaksDataPath)

# ---------------------------------------------

Rate_0_Sporulation_log = log(paramDataRaw$Rate_0_Sporulation)
paramData = cbind(paramDataRaw, Rate_0_Sporulation_log)


genBreaks = function(paramBreaks){
  x = seq(from=paramBreaks$breaksFrom, to=paramBreaks$breaksTo, by=paramBreaks$breaksBy)  
  return(x)
}

genMinBin = function(thisParamVal, thisParamBreaks){
  minBin = max(thisParamBreaks[thisParamVal > thisParamBreaks])
  return(minBin)
}

paramWrapper = function(paramName){
  thisParamBreaks = genBreaks(breaksData[[paramName]])
  paramVals = paramData[[paramName]]
  
  paramMinBreaks = sapply(paramVals, genMinBin, thisParamBreaks)
  
  return(paramMinBreaks)
}


Kernel_0_Parameter_minBin = paramWrapper('Kernel_0_Parameter')
Kernel_0_Parameter_maxBin = Kernel_0_Parameter_minBin + breaksData$Kernel_0_Parameter$breaksBy

Kernel_0_WithinCellProportion_minBin = paramWrapper('Kernel_0_WithinCellProportion')
Kernel_0_WithinCellProportion_maxBin = Kernel_0_WithinCellProportion_minBin + breaksData$Kernel_0_WithinCellProportion$breaksBy

Rate_0_Sporulation_log_minBin = paramWrapper('Rate_0_Sporulation_log')
Rate_0_Sporulation_log_maxBin = Rate_0_Sporulation_log_minBin + breaksData$Rate_0_Sporulation_log$breaksBy

Rate_0_Sporulation_minBin = exp(Rate_0_Sporulation_log_minBin)
Rate_0_Sporulation_maxBin = exp(Rate_0_Sporulation_log_maxBin)

binStr = paste(
  Kernel_0_Parameter_minBin, 
  Kernel_0_WithinCellProportion_minBin, 
  Rate_0_Sporulation_log_minBin,
  sep="_"
)

paramBinDf = cbind(
  paramData,
  Kernel_0_Parameter_minBin,
  Kernel_0_Parameter_maxBin,
  Kernel_0_WithinCellProportion_minBin,
  Kernel_0_WithinCellProportion_maxBin,
  Rate_0_Sporulation_log_minBin,
  Rate_0_Sporulation_log_maxBin,
  Rate_0_Sporulation_minBin,
  Rate_0_Sporulation_maxBin,
  binStr
)

freqDf = as.data.frame(table(binStr))

# --------------------
saveRDS(paramBinDf, paramBinDataOutPath)
saveRDS(freqDf, freqDfOutPath)
