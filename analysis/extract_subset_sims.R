
numSims = 25000

topDir = "results_fitting/sim_output_agg/model_2/2021_12_01_merged/survey_data_C/survey_data_C/"
outDir = "results_fitting/sim_output_agg/model_2/2022_01_19_sample/survey_data_C/survey_data_C/"

# --------------------------------

dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

resultsBigDfName = "results_summary_fixed_TARGET_SHRINK.rds"
resultsMinimalDfName = "results_summary_fixed_TARGET_MINIMAL.rds"
resultsGridDfName = "grid_sim_pass_criteria.rds"

resultsBigDf = readRDS(file.path(topDir, resultsBigDfName))
resultsMinimalDf = readRDS(file.path(topDir, resultsMinimalDfName))
resultsGridDf = readRDS(file.path(topDir, resultsGridDfName))

sampleBigDfOutPath = file.path(outDir, resultsBigDfName)
sampleMinimalDfOutPath = file.path(outDir, resultsMinimalDfName)
sampleGridDfOutPath = file.path(outDir, resultsGridDfName)

# -----------------------------------------

allSims = unique(resultsBigDf$simKey)

sampleSims = sample(x = allSims, size = numSims, replace = FALSE)

# ----------------------------------------------------------

sampleBigDf = resultsBigDf[resultsBigDf$simKey %in% sampleSims,]
sampleMinimalDf = resultsMinimalDf[resultsMinimalDf$simKey %in% sampleSims,]
sampleGridDf = resultsGridDf[resultsGridDf$simKey %in% sampleSims,]

# ------------------------------------------------

saveRDS(sampleBigDf, sampleBigDfOutPath)
saveRDS(sampleMinimalDf, sampleMinimalDfOutPath)
saveRDS(sampleGridDf, sampleGridDfOutPath)
