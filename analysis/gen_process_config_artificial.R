paramsInt = 2
model = "model_2"
templatePath = "templates/config_model_2_fitting_artificial.json"

# --------------------------------
outDir = file.path("./results_fitting/process_config/", paste0("model_2_artificial_fitting_params_", paramsInt))
templateJson = rjson::fromJSON(file=templatePath)

batchDf = read.csv("./templates/sim_stats.csv")
batchDfSubset = batchDf[batchDf$model==model,]

artificialJobsVec = list.files("../artificial/artificial_survey/", paste0("params_", paramsInt), full.names = TRUE) |>
    basename() |>
    tools::file_path_sans_ext() |>
    sort()

# --------------------

count = 0
for(datasetTargetInf in artificialJobsVec){
    
    for(iRow in seq_len(nrow(batchDfSubset))){
        
        thisRow = batchDfSubset[iRow,]
        
        thisBatch = thisRow$batch
        
        thisTemplate = templateJson
        thisTemplate[["batch"]] = thisBatch
        thisTemplate[["datasetTargetInf"]] = datasetTargetInf
        
        outPath = file.path(outDir, paste0("config_model_2_fitting_", count, ".json"))
        
        outStr = rjson::toJSON(thisTemplate, indent = 1)
        
        fileConn=file(outPath)
        writeLines(outStr, fileConn)
        close(fileConn)
        
        count = count + 1
        
    }
    
    
}
