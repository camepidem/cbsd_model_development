outDir = './results_fitting/process_config/model_2_fitting/'
model = "model_2"
datasetTargetInf = "survey_data_C"

# --------------------------------

templateJson = rjson::fromJSON(file="templates/config_model_2_fitting.json")

batchDf = read.csv("./templates/sim_stats.csv")

batchDfSubset = batchDf[batchDf$model==model,]

count = 0
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
