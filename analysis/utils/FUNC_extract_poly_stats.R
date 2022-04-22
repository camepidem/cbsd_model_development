library(rjson)
library(dplyr)

extractPolygonStats = function(stackedDfPath, surveyMappingPath, indexDir, summaryOutPath){

  dir.create(dirname(summaryOutPath), recursive=T, showWarnings=F)
    
  # Read in management stacked df and append a col with string version of xy cell index and simKey
  stackedDfRaw = readRDS(stackedDfPath)
  aggLocKey = paste0(stackedDfRaw$X, "_", stackedDfRaw$Y)
  aggSimKey = paste0(stackedDfRaw$batch, "_", stackedDfRaw$job, "_", stackedDfRaw$jobSim)
  stackedDf = cbind(stackedDfRaw, locKey=aggLocKey, simKey=aggSimKey)

  surveyMapping = fromJSON(file=surveyMappingPath)

  outCols = c(
    "batch",
    "job",
    "jobSim",
    "simYear",
    "simKey",
    "Kernel_0_Parameter",
    "Kernel_0_WithinCellProportion",
    "Rate_0_Sporulation"
  )
  
  # Infer all sim years from the management stacked df
  simYears = unique(stackedDf$simYear)

  maskList = list()
  #For each sim year
  for(thisSimYear in simYears){

    print(thisSimYear)
    
    # Based on the survey mapping (which specifies raster files),
    # extract the survey data year from the raster name using the sim year
    thisRasterName = surveyMapping[[as.character(thisSimYear)]]
    thisSurveyDataYearStr = gsub("_raster_total.asc", "", thisRasterName)
    
    # Use this surveyDataYear to pull out the index files for that year
    # for each mask (polygon). These allow look up of the XY cell indexes that
    # fall within that mask in that survey data year 
    thisYearMaskDfPaths = list.files(indexDir, thisSurveyDataYearStr, full.names = T)
    
    # For each of these mask index files
    for(thisYearMaskDfPath in thisYearMaskDfPaths){

      polyName = gsub(".csv", "", basename(thisYearMaskDfPath))
      polySuffix = gsub(paste0(thisSurveyDataYearStr, "_"), "", polyName)
      
      thisIndexDfRaw = read.csv(thisYearMaskDfPath)
      
      # The index file generation writes out files for every mask for every year,
      # so some have no surveys in that year (no rows), hence skip
      if(nrow(thisIndexDfRaw) > 0){
        
        # Append the locKey
        indexLocKey = paste0(thisIndexDfRaw$X, "_", thisIndexDfRaw$Y)
        thisIndexDf = cbind(thisIndexDfRaw, locKey=indexLocKey)
        
        # Store this data in a list (maskList)
        maskList[[thisYearMaskDfPath]] = list()
        maskList[[thisYearMaskDfPath]][["df"]] = thisIndexDf
        maskList[[thisYearMaskDfPath]][["polyName"]] = polyName
        maskList[[thisYearMaskDfPath]][["polySuffix"]] = polySuffix
        maskList[[thisYearMaskDfPath]][["thisSimYear"]] = thisSimYear
        maskList[[thisYearMaskDfPath]][["thisSurveyDataYear"]] = as.numeric(thisSurveyDataYearStr)

      }
    }
  }

  # --------------------

  mergedDfList = list()
    
  # Loop over the list that was generated in the previous step of
  # index files and some key metadata
  for(thisYearMaskDfPath in names(maskList)){
    
    print(thisYearMaskDfPath)
    
    # Unpack these same pieces of data
    # NB: This seems a bit redundant. Could have been done in previous loop
    thisYearMaskDf = maskList[[thisYearMaskDfPath]][["df"]]
    polyName = maskList[[thisYearMaskDfPath]][["polyName"]]
    polySuffix = maskList[[thisYearMaskDfPath]][["polySuffix"]]
    thisSimYear = maskList[[thisYearMaskDfPath]][["thisSimYear"]]
    thisSurveyDataYear = maskList[[thisYearMaskDfPath]][["thisSurveyDataYear"]]

    # Match based on sim year and the survey locations
    matchYear = stackedDf$simYear==thisSimYear
    matchMask = stackedDf$locKey%in%thisYearMaskDf$locKey
    
    # Pull out the subset of the stacked management df that matches the above 2 criteria
    thisAggSubsetDf = stackedDf[matchYear&matchMask,]
    
    # For each simulation, calc total num surveys and num pos detections for this mask in this sim year
    nSurveyedAll = aggregate(thisAggSubsetDf$NHostsSurveyed, by=list(simKey=thisAggSubsetDf$simKey), FUN=sum)
    nPosAll = aggregate(thisAggSubsetDf$NHostsSurveyDetections, by=list(simKey=thisAggSubsetDf$simKey), FUN=sum)
    
    thisMergedDf = left_join(nSurveyedAll, nPosAll, by="simKey")
    colnames(thisMergedDf) = c("simKey", "nSurveyed", "nPos")
    
    # Build summary of this data
    thisMergedDf = cbind(
      thisMergedDf,
      infProp = thisMergedDf$nPos / thisMergedDf$nSurveyed,
      simYear=thisSimYear,
      polyName=polyName,
      polySuffix=polySuffix,
      surveyDataYear=thisSurveyDataYear
    )
    
    mergedDfList[[thisYearMaskDfPath]] = thisMergedDf

  }
    
  # Merge all summaries of for each simulation, in a given year for a given mask,
  # how many surveys and how many of them were positive.
  mergedDf = bind_rows(mergedDfList)

  # Merge in the params data from the original stacked df
  allAggKeepCols = stackedDf[,outCols]
  uniqueAggDf = distinct(allAggKeepCols)
  outDf = full_join(mergedDf, uniqueAggDf, by=c("simKey", "simYear"))

  # Save
  saveRDS(outDf, summaryOutPath)

}
