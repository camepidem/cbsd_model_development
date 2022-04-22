box::use(./utils/utils_grid)
# box::reload(utils_grid)
args = commandArgs(trailingOnly=TRUE)

configJsonPath = args[[1]]
# configJsonPath = "./process_config/model_0_validation/config_model_0.json"
print(configJsonPath)

configJson = rjson::fromJSON(file=configJsonPath)

# -----------------------------

aggregateResults = configJson[["aggregateResults"]]
extractStats = configJson[["extractStats"]]
dropIncomplete = configJson[["dropIncomplete"]]
appendTargetData = configJson[["appendTargetData"]]
genGridRejection = configJson[["genGridRejection"]]
genGridYearly = configJson[["genGridYearly"]]
genMinimalDfs = configJson[["genMinimalDfs"]]

model = configJson[["model"]]

datasetSurveyLocs = configJson[["datasetSurveyLocs"]]
datasetTargetInf = configJson[["datasetTargetInf"]]

batch = configJson[["batch"]]
simType = configJson[["simType"]]

maxFittingSurveyDataYear = 2010

if(simType=="fitting"){
    maxSurveyDataYear = maxFittingSurveyDataYear
}else if(simType=="validation"){
    maxSurveyDataYear = 2014 # NB: Functionally 2017 - just single point error so hack to avoid crashing
}else{
    stop("Incorrect simType")
}

print(simType)
print(maxSurveyDataYear)

# --------------------------------------------------------

source("utils/FUNC_aggregate_management_results.R")
source("utils/FUNC_extract_poly_stats.R")
source("utils/FUNC_drop_incomplete_sims.R")
source("utils/FUNC_append_target_data.R")
source("utils/FUNC_minimalDfs.R")

topSimDir = file.path("../simulations", simType, "sim_output/", model)

simDir = file.path(topSimDir, batch)

resDir = file.path(paste0("results_", simType), "sim_output_agg", model, batch)
resDirSurveyLevel = file.path(resDir, datasetSurveyLocs)
resDirTargetLevel = file.path(resDir, datasetSurveyLocs, datasetTargetInf)

dir.create(resDir, showWarnings = F, recursive = T)
dir.create(resDirSurveyLevel, showWarnings = F, recursive = T)
dir.create(resDirTargetLevel, showWarnings = F, recursive = T)

# -----------------------
# *Merge the management tables across all jobs*
# Management tables contain data on XY cell index, num host, num surveys, num positive.
# Appends param data for every job

stackedOutPath = file.path(resDir, "management_stacked.rds")

if(aggregateResults){
  
  aggregateManagementResults(
    simDir=simDir,
    stackedOutPath=stackedOutPath
  )  
  
}

# ----------------------------------------------------------
# *Summarise survey stats within each mask*
# For each mask (polygon), for every sim year, add up the number of
# surveys within the polygon and how many positives were detected

surveyMappingPath = file.path("../simulations/fitting/inputs/agg_inputs/surveyTiming.json")
indexDir = file.path("../simulations/fitting/inputs", datasetSurveyLocs, "index")

summaryOutPath = file.path(resDirSurveyLevel, "results_summary.rds")

if(extractStats){
  
  extractPolygonStats(
    stackedDfPath=stackedOutPath,
    surveyMappingPath=surveyMappingPath,
    indexDir=indexDir,
    summaryOutPath=summaryOutPath
  )  
  
}

# ----------------------------------------------------------
# *Drop sims where incomplete output*
# Might have failed on cluster or not written out all files
# The sim year min/max is just the range that it ensure is present (doesn't exclude)
# So fine to specify 2005

fixedOutPath = file.path(resDirSurveyLevel, "results_summary_fixed.rds")
statisticDir = file.path("../summary_stats/mask_stats/", datasetTargetInf)
statsMergedDfPath = file.path(statisticDir, "merged/mask_stats_merged.csv")

completeStatsDfPath = file.path(resDirSurveyLevel, "complete_sim_stats.csv")

if(dropIncomplete){
  
  dropIncompleteSims(
    resPath=summaryOutPath,
    resFixedOutPath=fixedOutPath,
    maxSurveyDataYear=maxSurveyDataYear,
    statsMergedDfPath=statsMergedDfPath,
    completeStatsDfPath=completeStatsDfPath
  )
  
}

# ----------------------------------------------------------
# *Append mask target data for each mask/year*
# For every mask/year in the df, append the target data i.e. real world infProp value


resultsDfTargetPath = file.path(resDirTargetLevel, "results_summary_fixed_TARGET.rds")

if(appendTargetData){

  appendTargetDataFunc(
    surveyDfPath=fixedOutPath,
    statisticDir=statisticDir, 
    outPath=resultsDfTargetPath
  )

}

# ----------------------------------------------------------
# *For every grid in each sim, calculate whether it passes or fails each of the 4 statistic criteria*
surveyStatsDfPath = file.path(statisticDir, "grid_arrival_year.csv")
gridDfPath = file.path(resDirTargetLevel, "grid_full_pass_criteria.rds")

if(genGridRejection){

    utils_grid$calcGridPassCriteriaWrapper(
        resultsDfTargetPath=resultsDfTargetPath,
        surveyStatsDfPath=surveyStatsDfPath,
        maxFittingSurveyDataYear=maxFittingSurveyDataYear,
        gridDfOutPath=gridDfPath
    )
}

# ----------------------------------------------------------
# *Calc the per sim pass rate for each grid criteria*

gridSimDfOutPath = file.path(resDirTargetLevel, "grid_sim_pass_criteria.rds")

if(genGridYearly){

    utils_grid$calcPerSimGridResults(
        gridDfPath=gridDfPath,
        gridSimDfOutPath=gridSimDfOutPath
    )

}

if(genMinimalDfs){

  minimalDfs(
    targetDfPath=resultsDfTargetPath
  )

}
