library(dplyr)
library(ggplot2)
library(ggfan)
library(tictoc)
source("utils/FUNC_fitting.R")
source("utils/FUNC_plot_posterior.R")
args = commandArgs(trailingOnly=TRUE)

# Inputs
topDataDir = args[[1]]
configDir = args[[2]]
cullBool = as.logical(as.numeric(args[[3]]))

paramsPath = NULL
if(length(args) == 4){
  paramsPath = args[[4]]
}

# --------------------------------------------------------------------------
# --------------------------------------------------------------------------

configMasksDfAllPath = file.path(configDir, "config_mask.csv")
configGridDfPath = file.path(configDir, "config_grid.csv")

configKey = basename(configDir)

# -----------------------
unqKey = paste0(format(Sys.time(), "%Y_%m_%d_%H%M%S"), "_", configKey)


# Shrink results file = All key sim / result data except the param values
resultsDfPath = file.path(topDataDir, "results_summary_fixed_TARGET_SHRINK.rds")

# Minimal results file = Just the sim keys and the corresponding params
paramsDfPath = file.path(topDataDir, "results_summary_fixed_TARGET_MINIMAL.rds")

gridDfPath = file.path(topDataDir, "grid_sim_pass_criteria.rds")

# --------------------------

configMaskDfAll = read.csv(configMasksDfAllPath)
configMaskDfList = split(configMaskDfAll, configMaskDfAll$fit)

configGridDf = read.csv(configGridDfPath)

# Read big file
tic()
resultsDf = readRDS(resultsDfPath) 
toc()

# Break if any NAs in df
stopifnot(!any(is.na(resultsDf)))

paramsDf = readRDS(paramsDfPath)
gridDf = readRDS(gridDfPath)

# --------------------

runFit = function(
    paramsPath,
    topOutDir,
    configMaskDfList,
    configGridDf,
    resultsDf
){
    
    # Calc all grid first
    gridPassList = passGridFun(
        gridDf=gridDf, 
        configGridDf=configGridDf
    )
    
    # Inf prop etc.
    numJobs = length(names(configMaskDfList)) * length(names(gridPassList))
    
    count = 0
    for(maskKey in names(configMaskDfList)){
        
        configMaskDf = configMaskDfList[[maskKey]]
        
        yearResultsList = calcInfPropFun(resultsDf, configMaskDf)
        
        for(gridKey in names(gridPassList)){
            
            thisFitKey = paste0(gridKey, "_", maskKey)
            outDir = file.path(topOutDir, thisFitKey)
            dir.create(outDir, showWarnings = F, recursive = T)
            
            # print(thisFitKey)
            print(paste0("prog: ", round(count/numJobs, 3) * 100, "%"))
            
            # ------------
            
            thisFitResultsList = calcYearlyStats(
                configMaskDf=configMaskDf, 
                yearResultsList=yearResultsList, 
                maskKey=maskKey, 
                gridKey=gridKey, 
                gridPassList=gridPassList
            )
            
            yearSummaryDf = thisFitResultsList[["yearSummaryDf"]]
            passKeysAll = thisFitResultsList[["passKeysAll"]]
            
            # Write out summary
            yearSummaryDfOutPath = file.path(outDir, "year_summary_df.csv")
            write.csv(yearSummaryDf, yearSummaryDfOutPath, row.names = F)
            
            if(length(passKeysAll) > 0){
                
                # Plot pass rate
                passRatePlotOutPath = file.path(outDir, "pass_rate.png")
                plotPassRate(yearSummaryDf, passRatePlotOutPath)
                
                # Write out passKeys
                passKeysAllDf = data.frame(passKeys=passKeysAll)
                passKeysAllDfOutPath = file.path(outDir, "passKeys.csv")
                write.csv(passKeysAllDf, passKeysAllDfOutPath, row.names = F)
                
                # Plot posterior
                plotPosterior(
                    bigMinimalDfRaw=paramsDf,
                    passKeysDf=passKeysAllDf,
                    plotDir=outDir,
                    plotTitle=thisFitKey,
                    paramsPath=paramsPath
                )
                
                # Plot infProp graphs
                plotInfPropAllPoly(resultsDf, configMaskDf, passKeysAll, thisFitKey, outDir)
                
            }
            
            count = count + 1
            
        }
        
    }
    
    # Aggregate
    aggCmd = paste0("python utils/fit_1_agg_results.py ", topOutDir)
    system(aggCmd)
    
}

# --------------------

# Loop over each cull param if these are sims with control (i.e. model_3)
if(cullBool){

    # Extract subset with given cullParam
    cullDfPath = file.path(topDataDir, "ControlCullEffectiveness.csv")
    cullDf = read.csv(cullDfPath)

    cullParamVec = sort(unique(cullDf$ControlCullEffectiveness))
    for(thisCullParam in cullParamVec){

        thisCullParamStr = format(round(thisCullParam, 2), nsmall = 2)

        topOutDir = file.path(gsub("sim_output_agg", "fitting_output", topDataDir), paste0(unqKey, "_cull_", thisCullParamStr))

        print("OUTPATH:")
        print(topOutDir)

        cullDfSubset = cullDf |>
            dplyr::filter(ControlCullEffectiveness==thisCullParam)

        resultsDfSubset = resultsDf |>
            dplyr::filter(simKey %in% cullDfSubset$simKey)

        runFit(
            paramsPath=paramsPath,
            topOutDir=topOutDir,
            configMaskDfList=configMaskDfList,
            configGridDf=configGridDf,
            resultsDf=resultsDfSubset # Use subset of sims that used a given cullParam
        )

    }

}else{

    # For models_0 to 2 (i.e. no control)
    topOutDir = file.path(gsub("sim_output_agg", "fitting_output", topDataDir), unqKey)

    runFit(
        paramsPath=paramsPath,
        topOutDir=topOutDir,
        configMaskDfList=configMaskDfList,
        configGridDf=configGridDf,
        resultsDf=resultsDf # Use full resultsDf
    )

}
