# PRELIM 0
# dataDir = "results_fitting/sim_output_agg/model_0/2022_01_20_merged/survey_data_C/survey_data_C"
# fitDir = "results_fitting/fitting_output/model_0/2022_01_20_merged/survey_data_C/survey_data_C/2022_01_20_170738_2022_01_20_fitting_prelim/grid-tol_applied_only_where_both_bool-0.53_mask_0"	
# posteriorOutPath = "../simulations/gen_prior/model_0/validation/grid-tol_applied_only_where_both_bool-0.53_mask_0.txt"

# dataDir = "results_fitting/sim_output_agg/model_1/2022_01_20_merged/survey_data_C/survey_data_C"
# fitDir = "results_fitting/fitting_output/model_1/2022_01_20_merged/survey_data_C/survey_data_C/2022_01_20_170829_2022_01_20_fitting_prelim/grid-tol_applied_only_where_both_bool-0.53_mask_0/"	
# posteriorOutPath = "../simulations/gen_prior/model_1/validation/grid-tol_applied_only_where_both_bool-0.53_mask_0.txt"

# dataDir = "results_fitting/sim_output_agg/model_2/2022_01_19_sample/survey_data_C/survey_data_C/"
# fitDir = "results_fitting/fitting_output/model_2/2022_01_19_sample/survey_data_C/survey_data_C/2022_01_20_171103_2022_01_20_fitting_prelim/grid-tol_applied_only_where_both_bool-0.53_mask_0/"	
# posteriorOutPath = "../simulations/gen_prior/model_2/validation_prelim/grid-tol_applied_only_where_both_bool-0.53_mask_0.txt"


# ---------------------------------------------------
# PRELIM 1
# dataDir = "results_fitting/sim_output_agg/model_0/2022_01_20_merged/survey_data_C/survey_data_C"
# fitDir = "results_fitting/fitting_output/model_0/2022_01_20_merged/survey_data_C/survey_data_C/2022_01_31_231106_2022_01_31_fitting_prelim_025/grid-tol_applied_only_where_both_bool-0.58_mask_0/"	
# posteriorOutPath = "../simulations/gen_prior/model_0/validation/grid-tol_applied_only_where_both_bool-0.53_mask_0_025.txt"

# dataDir = "results_fitting/sim_output_agg/model_1/2022_01_20_merged/survey_data_C/survey_data_C"
# fitDir = "results_fitting/fitting_output/model_1/2022_01_20_merged/survey_data_C/survey_data_C/2022_01_31_231116_2022_01_31_fitting_prelim_025/grid-tol_applied_only_where_both_bool-0.58_mask_0/"	
# posteriorOutPath = "../simulations/gen_prior/model_1/validation/grid-tol_applied_only_where_both_bool-0.53_mask_0_025.txt"

# dataDir = "results_fitting/sim_output_agg/model_2/2022_01_19_sample/survey_data_C/survey_data_C/"
# fitDir = "results_fitting/fitting_output/model_2/2022_01_19_sample/survey_data_C/survey_data_C/2022_01_31_231138_2022_01_31_fitting_prelim_025/grid-tol_applied_only_where_both_bool-0.58_mask_0/"
# posteriorOutPath = "../simulations/gen_prior/model_2/validation_prelim/grid-tol_applied_only_where_both_bool-0.53_mask_0_025.txt"

# FINAL REAL
dataDir = "results_fitting/sim_output_agg/model_2/2021_12_01_merged/survey_data_C/survey_data_C/"
fitDir = "results_fitting/fitting_output/model_2/2021_12_01_merged/survey_data_C/survey_data_C/2022_02_03_175717_2022_02_03_single/grid-tol_applied_only_where_both_bool-0.48_mask_6_DROP"	
posteriorOutPath = "../simulations/gen_prior/model_2/validation/2022_02_04_model_2_posterior.txt"

# ---------------------------------------------------	

passKeysDfPath = file.path(fitDir, "passKeys.csv")
passKeysDf = read.csv(passKeysDfPath)

binFreqDfPath = file.path(dataDir, "binFreq.rds")
binFreqDf = readRDS(binFreqDfPath)	

paramBinDfPath = file.path(dataDir, "results_summary_fixed_TARGET_MINIMAL_BINS.rds")
paramBinDf = readRDS(paramBinDfPath)

# ---------------------	
# Extract binKey for each passSim	
paramBinPassDf = paramBinDf[paramBinDf$simKey%in%passKeysDf$passKeys,]

# Map passes to bins	
passBinFreq = as.data.frame(table(paramBinPassDf$binStr))
colnames(passBinFreq) = c("binStr", "passFreq")	

# Extract sample freq for corresponding pass bins	
samplePassDf = binFreqDf[binFreqDf$binStr%in%passBinFreq$binStr,]	
colnames(samplePassDf) = c("binStr", "sampleFreq")	

# Merge pass freq and sample freq dfs and calc density
passSampleFreqDf = dplyr::left_join(passBinFreq, samplePassDf, by=c("binStr")) |>
    dplyr::mutate(density=passFreq/sampleFreq) |>
    dplyr::mutate(binStr=as.character(binStr))

# Build posterior	
## For each bin - build posterior row
posteriorList = list()	
for(iRow in seq_len(nrow(passSampleFreqDf))){	

  thisBinStrRow = passSampleFreqDf[iRow,]	

  paramDetailsRow = paramBinDf[paramBinDf$binStr==thisBinStrRow$binStr,][1,]	

  thisPosteriorRow = data.frame(	
    Density=thisBinStrRow$density,	
    Kernel_0_Parameter_min=paramDetailsRow$Kernel_0_Parameter_minBin,	
    Kernel_0_Parameter_max=paramDetailsRow$Kernel_0_Parameter_maxBin,	
    Rate_0_Sporulation_min=paramDetailsRow$Rate_0_Sporulation_minBin,	
    Rate_0_Sporulation_max=paramDetailsRow$Rate_0_Sporulation_maxBin,	
    Kernel_0_WithinCellProportion_min=paramDetailsRow$Kernel_0_WithinCellProportion_minBin,	
    Kernel_0_WithinCellProportion_max=paramDetailsRow$Kernel_0_WithinCellProportion_maxBin	
  )	

  posteriorList[[thisBinStrRow$binStr]] = thisPosteriorRow	

}	

posteriorDf = dplyr::bind_rows(posteriorList)

# Write out posterior	
row_0 = "nParameters 3"	
row_1 = paste0("nEntries ", nrow(posteriorDf))	
row_2 = "Parameter_1_SampleLogSpace 1"	
row_3 = "Density Kernel_0_Parameter Rate_0_Sporulation Kernel_0_WithinCellProportion"	
header = c(row_0, row_1, row_2, row_3)	

dir.create(dirname(posteriorOutPath), showWarnings = F, recursive = T)

fileConn = file(posteriorOutPath)
writeLines(header, fileConn)
close(fileConn)

write.table(posteriorDf, posteriorOutPath, append = TRUE, row.names = FALSE, col.names = FALSE)
