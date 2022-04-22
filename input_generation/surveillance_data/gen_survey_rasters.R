options(stringsAsFactors = F)
library(raster)

genSurveyRasters = function(surveyData, outDir, templateRasterPath){
  
  templateRaster = raster(templateRasterPath)
  templateRaster[] = 0
  
  dir.create(outDir, recursive=T, showWarnings = F)
  
  allYears = sort(unique(surveyData$year))
  
  allYears = allYears[allYears > 1970]
  
  
  for(thisYear in allYears){
    
    print(thisYear)
    
    thisYearDf = surveyData[surveyData$year==thisYear,]
    coordinates(thisYearDf) = ~x+y
    
    thisYearDfPos = thisYearDf[thisYearDf$cbsd==1,]
    thisYearDfNeg = thisYearDf[thisYearDf$cbsd==0,]
    
    # browser()
    
    if(!nrow(thisYearDfPos)==0){
      outRasterPos = rasterize(x=thisYearDfPos, y=templateRaster, field=1, fun="sum", background=0)  
    } else {
      outRasterPos = templateRaster
    }
    
    if(!nrow(thisYearDfNeg)==0){
      outRasterNeg = rasterize(x=thisYearDfNeg, y=templateRaster, field=1, fun="sum", background=0)
    } else {
      outRasterNeg = templateRaster
    }
    
    outRasterTotal = outRasterPos + outRasterNeg
    
    outPathPos = file.path(outDir, paste0(thisYear, "_raster_pos.tif"))
    outPathNeg = file.path(outDir, paste0(thisYear, "_raster_neg.tif"))
    outPathTotal = file.path(outDir, paste0(thisYear, "_raster_total.tif"))
    
    writeRaster(outRasterPos, outPathPos, overwrite=TRUE)
    writeRaster(outRasterNeg, outPathNeg, overwrite=TRUE)
    writeRaster(outRasterTotal, outPathTotal, overwrite=TRUE)
    
  }
  
}

