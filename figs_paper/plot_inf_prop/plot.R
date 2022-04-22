library(dplyr)
library(ggplot2)
library(ggfan)


plotInfPropSinglePoly = function(bigDf, configMaskDf, passKeysAll, polyStr, plotTicksBool, plotRectBool, resultsDir){
    
    plotList = list()

    polyDf = bigDf[bigDf$polySuffix == polyStr,]
    polyPassDf = polyDf[polyDf$simKey %in% passKeysAll,]

    targetDfRaw = polyPassDf[polyPassDf$simKey==passKeysAll[1],]

    configPolyDf = configMaskDf[configMaskDf$mask==polyStr,]

    targetDfList = list()
    for(iRow in seq_len(nrow(configPolyDf))){

        configRow = configPolyDf[iRow,]

        surveyDataYear = configRow$surveyDataYear
        targetRow = targetDfRaw[targetDfRaw$surveyDataYear==surveyDataYear,]

        if(nrow(targetRow)>1){
            stop("targetRowEmpty")
        }
        else if(nrow(targetRow)==1){

            targetVal = targetRow$targetVal

            tolMin = targetVal - configRow$tol
            if(tolMin<0){
                tolMin = 0
            }

            tolMax = targetVal + configRow$tol
            if(tolMax>1){
                tolMax=1
            }

            outRow = data.frame(
                surveyDataYear=surveyDataYear,
                targetVal=targetVal,
                tolMin=tolMin,
                tolMax=tolMax
            )

            targetDfList[[as.character(iRow)]] = outRow

        }
    
    }

    targetDf = bind_rows(targetDfList)


    if(plotRectBool==TRUE & polyStr=="mask_uga_kam"){
        plotRectBool = TRUE
    }else{
        plotRectBool = FALSE
    }

    allOutPath = file.path(resultsDir, paste0(polyStr, "_all.png"))
    p = genInfPropGraph(
        bigDfSubset = polyDf,
        targetDf = targetDf,
        plotTicksBool = FALSE, # Hardcode switch off ticks for 'all' i.e. constraints not applied
        plotRectBool=plotRectBool,
        outPath = allOutPath
    )

    plotList[[allOutPath]] = p

    dropOutPath = file.path(resultsDir, paste0(polyStr, "_drop.png"))
    q = genInfPropGraph(
        bigDfSubset = polyPassDf,
        targetDf = targetDf,
        plotTicksBool = plotTicksBool,
        plotRectBool=plotRectBool,
        outPath = dropOutPath
    )

    plotList[[dropOutPath]] = q

    return(plotList)

}


# Plot infProp graph
genInfPropGraph = function(bigDfSubset, targetDf, plotTicksBool, plotRectBool, outPath){

    bigDfSubset$surveyDataYear = as.numeric(bigDfSubset$surveyDataYear)
    bigDfSubset$infProp = as.numeric(bigDfSubset$infProp)

    p = ggplot(data=bigDfSubset, aes(x=surveyDataYear, y=infProp)) +
        geom_fan(intervals = seq(0,1,0.2)) +
        scale_fill_gradient(low="#5D5DF8", high="#C1C1EF") +
        ylim(0,1)+
        geom_line(data=targetDf, aes(x=surveyDataYear, y=targetVal), color="red") +
        geom_point(data=targetDf, aes(x=surveyDataYear, y=targetVal), color="red", fill="red") +

        xlab("Year") + 
        ylab("Proportion of survey sites infected") +
        theme(
            legend.position = "none",
            axis.text=element_text(size=12),
            axis.title=element_text(size=12)
        ) + 
        geom_vline(xintercept = 2010, linetype="dashed")


    if(plotTicksBool){

        p = p +
            geom_point(data=targetDf, aes(x=surveyDataYear, y=tolMax), color="green", shape=25, fill="green") +
            geom_point(data=targetDf, aes(x=surveyDataYear, y=tolMin), color="green", shape=24, fill="green")

    }

    if(plotRectBool){

        p = p +
            annotate("rect", xmin = 2012, xmax = 2015, ymin = -Inf, ymax = Inf, alpha = 0.2)

    }
    
    
    cowplot::save_plot(outPath, plot=p, base_asp = 1)
    
    return(p)

}

plotInfPropAllPoly = function(
    bigDf, 
    configMaskDf, 
    passKeysAll, 
    plotTicksBool,
    plotRectBool,
    resultsDir
    ){

    if(length(passKeysAll)==0){
        return()
    }

    dir.create(resultsDir, recursive = TRUE, showWarnings = FALSE)
    
    allPolyStr = unique(configMaskDf$mask)

    plotListAll = list()
    
    for(polyStr in allPolyStr){
        
        plotList = plotInfPropSinglePoly(bigDf, configMaskDf, passKeysAll, polyStr, plotTicksBool, plotRectBool, resultsDir)

        plotListAll = c(plotListAll, plotList)
        
    }
    
    return(plotListAll)
}


# ------------------------------------
# Model 2: Validation

# topDataDir = "../../analysis/results_validation/sim_output_agg/model_2/2021_12_06_batch_0/survey_data_C/survey_data_C"
# configDir = "../../analysis/results_validation/fitting_config/2022_01_13_s_inf/"
# passKeysDir = "../../analysis/results_validation/fitting_output/model_2/2021_12_06_batch_0/survey_data_C/survey_data_C/2022_01_14_110332_2022_01_13_s_inf/grid-tol_applied_only_where_both_bool-0.48_mask_6/"
# outDir = "./plots/validaton_model_2"
# plotTicksBool = TRUE
# cullParam = NULL
# plotRectBool = FALSE

# ------------------------------------
# Model 0: Prelim validation

# topDataDir = "../../analysis/results_validation/sim_output_agg/model_0/2022_01_31_batch_1_03/survey_data_C/survey_data_C/"
# configDir = "../../analysis/results_validation/fitting_config/2022_02_01_validation_prelim_03"
# passKeysDir = "../../analysis/results_validation/fitting_output/model_0/2022_01_31_batch_1_03/survey_data_C/survey_data_C/2022_02_01_104057_2022_02_01_validation_prelim_03/grid-tol_applied_only_where_both_bool-0.58_mask_0/"
# outDir = "./plots/validaton_prelim_model_0"
# plotTicksBool = FALSE
# cullParam = NULL
# plotRectBool = FALSE

# ------------------------------------
# Model 1: Prelim validation

# topDataDir = "../../analysis/results_validation/sim_output_agg/model_1/2022_01_31_batch_1_03/survey_data_C/survey_data_C/"
# configDir = "../../analysis/results_validation/fitting_config/2022_02_01_validation_prelim_03/"
# passKeysDir = "../../analysis/results_validation/fitting_output/model_1/2022_01_31_batch_1_03/survey_data_C/survey_data_C/2022_02_01_104107_2022_02_01_validation_prelim_03/grid-tol_applied_only_where_both_bool-0.58_mask_0/"
# outDir = "./plots/validaton_prelim_model_1"
# plotTicksBool = FALSE
# cullParam = NULL
# plotRectBool = FALSE

# ------------------------------------
# Model 2: Prelim validation

# topDataDir = "../../analysis/results_validation/sim_output_agg/model_2/2022_01_31_prelim_validation_03/survey_data_C/survey_data_C/"
# configDir = "../../analysis/results_validation/fitting_config/2022_02_01_validation_prelim_03/"
# passKeysDir = "../../analysis/results_validation/fitting_output/model_2/2022_01_31_prelim_validation_03/survey_data_C/survey_data_C/2022_02_01_104116_2022_02_01_validation_prelim_03/grid-tol_applied_only_where_both_bool-0.58_mask_0/"
# outDir = "./plots/validaton_prelim_model_2"
# plotTicksBool = FALSE
# cullParam = NULL
# plotRectBool = FALSE

# ------------------------------------
# Model 3: Prelim - param sweep
# topDataDir = "../../analysis/results_validation/sim_output_agg/model_3/2022_03_16_batch_0/survey_data_C/survey_data_C/"
# configDir = "../../analysis/results_validation/fitting_config/2022_02_18_cullParam/"
# passKeysDir = "../../analysis/results_validation/fitting_output/model_3/2022_03_16_batch_0/survey_data_C/survey_data_C/2022_03_18_155829_2022_02_18_cullParam_cull_0.10/grid-tol_applied_only_where_both_bool-0.48_mask_0/"
# outDir = "./plots/validaton_prelim_model_3/cullParam_0_10/"
# plotTicksBool = FALSE
# cullParam = 0.1
# plotRectBool = TRUE

# topDataDir = "../../analysis/results_validation/sim_output_agg/model_3/2022_03_16_batch_0/survey_data_C/survey_data_C/"
# configDir = "../../analysis/results_validation/fitting_config/2022_02_18_cullParam/"
# passKeysDir = "../../analysis/results_validation/fitting_output/model_3/2022_03_16_batch_0/survey_data_C/survey_data_C/2022_03_18_155829_2022_02_18_cullParam_cull_0.15/grid-tol_applied_only_where_both_bool-0.48_mask_0/"
# outDir = "./plots/validaton_prelim_model_3/cullParam_0_15/"
# plotTicksBool = FALSE
# cullParam = 0.15
# plotRectBool = TRUE

# topDataDir = "../../analysis/results_validation/sim_output_agg/model_3/2022_03_16_batch_0/survey_data_C/survey_data_C/"
# configDir = "../../analysis/results_validation/fitting_config/2022_02_18_cullParam/"
# passKeysDir = "../../analysis/results_validation/fitting_output/model_3/2022_03_16_batch_0/survey_data_C/survey_data_C/2022_03_18_155829_2022_02_18_cullParam_cull_0.20/grid-tol_applied_only_where_both_bool-0.48_mask_0/"
# outDir = "./plots/validaton_prelim_model_3/cullParam_0_20/"
# plotTicksBool = FALSE
# cullParam = 0.2
# plotRectBool = TRUE

# topDataDir = "../../analysis/results_validation/sim_output_agg/model_3/2022_03_16_batch_0/survey_data_C/survey_data_C/"
# configDir = "../../analysis/results_validation/fitting_config/2022_02_18_cullParam/"
# passKeysDir = "../../analysis/results_validation/fitting_output/model_3/2022_03_16_batch_0/survey_data_C/survey_data_C/2022_03_18_155829_2022_02_18_cullParam_cull_0.25/grid-tol_applied_only_where_both_bool-0.48_mask_0/"
# outDir = "./plots/validaton_prelim_model_3/cullParam_0_25/"
# plotTicksBool = FALSE
# cullParam = 0.25
# plotRectBool = TRUE

# ------------------------------------
# Model 3: Validation
topDataDir = "../../analysis/results_validation/sim_output_agg/model_3/2022_03_18_batch_0/survey_data_C/survey_data_C/"
configDir = "../../analysis/results_validation/fitting_config/2022_02_07_validation/"
passKeysDir = "../../analysis/results_validation/fitting_output/model_3/2022_03_18_batch_0/survey_data_C/survey_data_C/2022_03_21_102007_2022_02_07_validation/grid-tol_applied_only_where_both_bool-0.48_mask_0/"
outDir = "./plots/validaton_model_3"
plotTicksBool = TRUE
cullParam = NULL
plotRectBool = FALSE

# ------------------------------------
# Script
# ------------------------------------

maskKey = stringr::str_sub(basename(passKeysDir), -6, -1)

bigDfPath = file.path(topDataDir, "results_summary_fixed_TARGET_SHRINK.rds")
bigDf = readRDS(bigDfPath)

stopifnot(!any(is.na(bigDf$targetDiff)))

configMasksDfAllPath = file.path(configDir, "config_mask.csv")
configMaskDfAll = read.csv(configMasksDfAllPath)
configMaskDfList = split(configMaskDfAll, configMaskDfAll$fit)

configMaskDf = configMaskDfList[[maskKey]]

passKeysAllDf = read.csv(file.path(passKeysDir, "passKeys.csv"))
passKeysAll = passKeysAllDf$passKeys


if(is.numeric(cullParam)){

    print("cullParam")
    print(cullParam)

    cullParamDf = read.csv(file.path(topDataDir, "ControlCullEffectiveness.csv")) |>
        dplyr::filter(ControlCullEffectiveness == cullParam)

    bigDf = bigDf |>
        dplyr::filter(simKey %in% cullParamDf$simKey)

}

plotListAll = plotInfPropAllPoly(bigDf, configMaskDf, passKeysAll, plotTicksBool, plotRectBool, outDir)

