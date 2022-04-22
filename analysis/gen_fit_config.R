options(stringsAsFactors = F)
library(dplyr)

# outPath = "results_fitting/fitting_config/sweep_mask_uga_kam/config_mask.csv"
outPath = "./results_scenario_0/fitting_config/coarse/config_mask.csv"

dir.create(dirname(outPath), showWarnings = F, recursive = T)

yearsRange = c(seq(2004, 2015), 2017)
# tolRange = seq(0.5, 0.10, -0.05)
tolRange = c(0.25)

maskVec = c("mask_uga_hole", "mask_uga_kam")
# maskVec = c("mask_uga_kam")

configList = list()
count = 0
fitCount = 0
for(thisTol in tolRange){
  
  fitStr = paste0("mask_", fitCount)
  
  for(thisMask in maskVec){
    
    for(thisYear in yearsRange){
      
      thisRow = data.frame(
        fit=fitStr,
        surveyDataYear=thisYear,
        mask=thisMask,
        tol=thisTol
      )
      
      configList[[as.character(count)]] = thisRow
      
      count = count + 1
      
    }
    
  }
  
  fitCount = fitCount + 1
  
}

configDf = bind_rows(configList)
write.csv(configDf, outPath, row.names = F)
