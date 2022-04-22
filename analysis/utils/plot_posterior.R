options(stringsAsFactors = F)
library(ggplot2)
library(dplyr)

plotPosterior = function(bigMinimalDf, passKeys, hexBins, resultsDir, title, paramsPath=NULL){
  
  plotA = function(outPath){
    
    hull = bigDf %>% slice(chull(Kernel_0_Parameter, logBeta))
    
    p = ggplot(passParamsDf, aes(x=Kernel_0_Parameter, y=logBeta) ) +
      geom_polygon(data = hull, alpha = 0.2) +
      geom_hex(aes(fill=..density..), bins = hexBins) +
      theme_bw() +
      ylab("log(beta)") +
      xlab("alpha") +
      theme(legend.position = "none") + 
      ggtitle(title) + 
      xlim(0, 6) + 
      ylim(0, 8)
    
    if(!is.null(paramsPath)){
      p = p + 
        geom_hline(yintercept = paramBeta, colour="green") + 
        geom_vline(xintercept = paramAlpha, colour="green")
    }
    
    suppressMessages(ggsave(outPath))
    
  }
  
  
  plotB = function(outPath){
    
    hull = bigDf %>% slice(chull(Kernel_0_Parameter, Kernel_0_WithinCellProportion))
    
    p = ggplot(passParamsDf, aes(x=Kernel_0_Parameter, y=Kernel_0_WithinCellProportion) ) +
      geom_polygon(data = hull, alpha = 0.2) +
      geom_hex(aes(fill=..density..), bins = hexBins) +
      theme_bw() +
      ylab("p") +
      xlab("alpha")+
      theme(legend.position = "none") + 
      ggtitle(title) + 
      xlim(0, 6) + 
      ylim(0, 1)
    
    if(!is.null(paramsPath)){
      p = p +
        geom_hline(yintercept = paramP, colour="green") +
        geom_vline(xintercept = paramAlpha, colour="green")
    }

    suppressMessages(ggsave(outPath))
    
  }
  
  
  plotC = function(outPath){
    
    hull = bigDf %>% slice(chull(logBeta, Kernel_0_WithinCellProportion))
    
    p = ggplot(passParamsDf, aes(x=logBeta, y=Kernel_0_WithinCellProportion) ) +
      geom_polygon(data = hull, alpha = 0.2) +
      geom_hex(aes(fill=..density..), bins = hexBins) +
      theme_bw() +
      ylab("p") +
      xlab("log(beta)")+
      theme(legend.position = "none") + 
      ggtitle(title) + 
      ylim(0, 1) +
      xlim(0, 8)
    
    if(!is.null(paramsPath)){
        p = p +
          geom_hline(yintercept = paramP, colour="green") +
          geom_vline(xintercept = paramBeta, colour="green")
    }

    suppressMessages(ggsave(outPath))
    
  }
  
  
  keepColumns = c("simKey", "Kernel_0_Parameter", "Kernel_0_WithinCellProportion", "Rate_0_Sporulation")
  plotColumns = c("simKey", "Kernel_0_Parameter", "Kernel_0_WithinCellProportion", "logBeta")
  
  bigMinimalDf = unique(bigMinimalDf[,keepColumns])
  
  # Append log beta
  logBeta = log(bigMinimalDf$Rate_0_Sporulation)
  bigDf = cbind(bigMinimalDf, logBeta)

  # Generate convex hull for all parameters
  # allParamsDf = unique(bigDf[,plotColumns])

  # Isolate simulations that passed fitting
  passDf = bigDf[bigDf$simKey%in%passKeys,]
  passParamsDf = unique(passDf[,plotColumns])


  # If artificial sims, get input params
  if(!is.null(paramsPath)){
    paramsDf = read.table(paramsPath, skip = 4)
    paramAlpha = paramsDf$V2
    paramBeta = log(paramsDf$V4)
    paramP = paramsDf$V6
  }


  outPath = file.path(resultsDir, "plotA.png")
  plotA(outPath)

  outPath = file.path(resultsDir, "plotB.png")
  plotB(outPath)

  outPath = file.path(resultsDir, "plotC.png")  
  plotC(outPath)

}

