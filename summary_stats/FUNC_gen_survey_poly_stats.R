options(stringsAsFactors = F)
library(sp)
library(ggplot2)
projStr = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"


genSurveyPolyStats = function(surveyDataPath, outDir){
  
  surveyData = read.csv(surveyDataPath)

  dir.create(outDir, showWarnings=F, recursive=T)
  
  plotDir = file.path(outDir, "plots")
  dir.create(plotDir, showWarnings = F)
  
  coordinates(surveyData) = ~x+y
  proj4string(surveyData) = projStr
  
  allPolys = list.files("mask_polys", full.names=T)
  
  # -----
  
  for(thisPolyPath in allPolys){
    
    print(thisPolyPath)
    
    thisPoly = readRDS(thisPolyPath)
    
    polyBasename = basename(thisPolyPath)
    polyName = gsub(".rds", "", polyBasename)
    
    inPolyCheck = over(surveyData, thisPoly)
    inPolyBool = !is.na(inPolyCheck$ID)
    
    if(any(inPolyBool)){
      
      inPolySpDf = surveyData[inPolyBool,]
      
      inPolyDf = inPolySpDf@data
      
      polyYears = unique(inPolyDf$year)
      
      statDf = data.frame()
      for(thisYear in polyYears){
                
        thisYearDf = inPolyDf[inPolyDf$year==thisYear,]
        
        nPos = sum(thisYearDf$cbsd)
        nTotal = nrow(thisYearDf)
        nNeg = nTotal - nPos
        propPos = nPos / nTotal
        
        thisRow = data.frame(
          year=thisYear,
          nPos=nPos,
          nNeg=nNeg,
          nTotal=nTotal,
          propPos=propPos
        )
        
        statDf = rbind(statDf, thisRow)
        
      }
      
      ggplot(statDf, aes(x=year, y=propPos)) + 
        geom_line() + 
        geom_point() +
        ylim(0,1)
      
      plotPath = file.path(plotDir, paste0(polyName, ".png"))  
      ggsave(plotPath)
      
      statDfPath = file.path(outDir, paste0(polyName, ".csv"))
      write.csv(statDf, statDfPath, row.names = F)
      
    } else {
      
      print(paste0("Skipping - no survey points in poly: ", thisPolyPath))
      
    }
    
  }
  
}
