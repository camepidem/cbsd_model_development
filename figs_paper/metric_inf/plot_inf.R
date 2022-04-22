library(ggplot2)


plotInfProp = function(
    statsDfPath,
    outPath
    ){
    
    statsDfRaw = read.csv(statsDfPath)
    
    statsDf = statsDfRaw[statsDfRaw$year != 2016,]
    
    p = ggplot(statsDf, aes(x=year, y=propPos)) + 
        geom_line() +
        geom_point() +
        ylim(0,1) +
        ylab("Proportion of survey sites infected") +
        xlab("Year")
        
    
    if(max(statsDf$year) > 2010){
        p = p + geom_vline(xintercept = 2010, linetype="dashed", color = "green")
    }
    
    ggsave(outPath)
    
}

statsDirs = list.files("../../summary_stats/mask_stats/", full.names = TRUE)

for(statsDir in statsDirs){
    
    datasetName = basename(statsDir)
    print(datasetName)
    
    kamDfPath = file.path(statsDir, "mask_uga_kam.csv")
    kamOutPath = file.path("plots", paste0(datasetName, "_kam.png"))
    
    plotInfProp(
        kamDfPath,
        kamOutPath
    )
    
    ugaDfPath = file.path(statsDir, "mask_uga_hole.csv")
    ugaOutPath = file.path("plots", paste0(datasetName, "_uga.png"))
    
    plotInfProp(
        ugaDfPath,
        ugaOutPath
    )
    
}
