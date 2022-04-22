options(stringsAsFactors = F)
library(dplyr)

outPath = "results_validation/fitting_config/val_broad_just_fitting/config_mask.csv"

yearsRangeFit = seq(2004, 2010)
tolFit = 0.3

yearsRangeVal = c(seq(2011, 2015), 2017)
# tolRangeVal = seq(0.4, 0.20, -0.02)
tolRangeVal = c(1)

maskVec = c("mask_uga_hole", "mask_uga_kam")

configList = list()
count = 0
fitCount = 0
for(thisTolVal in tolRangeVal){
  
  fitStr = paste0("mask_", fitCount)
  
  for(thisMask in maskVec){
    
    for(yearFit in yearsRangeFit){
      
      thisRow = data.frame(
        fit=fitStr,
        surveyDataYear=yearFit,
        mask=thisMask,
        tol=tolFit
      )
      
      configList[[as.character(count)]] = thisRow
      
      count = count + 1
      
    }
    
    for(thisYearVal in yearsRangeVal){
      
      thisRow = data.frame(
        fit=fitStr,
        surveyDataYear=thisYearVal,
        mask=thisMask,
        tol=thisTolVal
      )
      
      configList[[as.character(count)]] = thisRow
      
      count = count + 1
      
    }
    
  }
  
  fitCount = fitCount + 1
  
}

configDf = bind_rows(configList)
write.csv(configDf, outPath, row.names = F)
