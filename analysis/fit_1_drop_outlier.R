source("utils/FUNC_plot_posterior.R")

fitDir = file.path("./results_fitting/fitting_output/model_2/2021_12_01_merged/survey_data_C/survey_data_C/2022_02_03_175717_2022_02_03_single/grid-tol_applied_only_where_both_bool-0.48_mask_6/")
dataDir = "./results_fitting/sim_output_agg/model_2/2021_12_01_merged/survey_data_C/survey_data_C/"
outDir = file.path(dirname(fitDir), "grid-tol_applied_only_where_both_bool-0.48_mask_6_DROP")
dropKeysVec = c("2019_03_19_batch_0_job5601_0", "2019_03_19_batch_0_job5795_0", "2019_03_25_batch_0_job366_0", "2019_03_25_batch_0_job5006_0", "2019_03_25_batch_0_job2757_0")

# ------------------------------------------------

dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

# Read in pass keys from fitting dir
passKeysAllDfPath = file.path(fitDir, "passKeys.csv")
passKeysAllDf = read.csv(passKeysAllDfPath)

# Use params df to find the simKeys that I want to drop based on param values
paramsDfPath = file.path(dataDir, "results_summary_fixed_TARGET_MINIMAL.rds")
paramsDf = readRDS(paramsDfPath)

paramsDfPass = paramsDf[paramsDf$simKey %in% passKeysAllDf$passKeys,] |>
    dplyr::mutate(Rate_0_Sporulation_ln = log(Rate_0_Sporulation))


# Drop outlier sim
passKeysDropDf = passKeysAllDf |> 
    dplyr::filter(!(passKeys %in% dropKeysVec))

write.csv(passKeysDropDf, file.path(outDir, "passKeys.csv"), row.names=FALSE)

# -------------------
dropSimsDf = passKeysAllDf |> 
    dplyr::filter(passKeys %in% dropKeysVec)

# Plot posterior drop
plotPosterior(
    bigMinimalDfRaw=paramsDf,
    passKeysDf=passKeysDropDf,
    plotDir=outDir,
    plotTitle="DROP",
    paramsPath=NULL,
    dropSimsDf=dropSimsDf
)
