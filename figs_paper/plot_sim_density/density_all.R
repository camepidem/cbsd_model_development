library(ggplot2)
library(ggspatial)
library(rasterVis)

bigDf = readRDS("../../analysis/results_fitting/sim_output_agg/model_2/2021_12_01_merged/survey_data_C/survey_data_C/results_summary_fixed_TARGET_MINIMAL.rds") |>
    dplyr::mutate(Rate_0_Sporulation_log = log(Rate_0_Sporulation), batch=substr(simKey, 1, 18))

batches = unique(bigDf$batch)

convexBatchVec = c(
    "2019_03_25_batch_0",
    "2019_04_20_batch_0",
    "2019_05_21_batch_0",
    "2019_08_03_batch_0"
)

xKey = "Kernel_0_Parameter"
yKey = "Rate_0_Sporulation_log"

convexBatchDfList = list()
count = 0
for(convexBatch in convexBatchVec){
    
    key = paste0("batch_", count)
    
    thisDf = bigDf[bigDf$batch==convexBatch,]
    thisDf$batch = key
    
    thisHull = thisDf[chull(thisDf[[xKey]], thisDf[[yKey]]),]
    convexBatchDfList[[key]] = thisHull
    
    count = count + 1
}

# ------------------------------------


sampleDf = data.frame(
    x=bigDf[[xKey]],
    y=bigDf[[yKey]]
)

# Build convex hull of all sims
# hull = bigDf[chull(bigDf[[xKey]], bigDf[[yKey]]),]

# Rasterise pass and sample data
xmn=round(min(bigDf[[xKey]]), digits = 1)
xmx=round(max(bigDf[[xKey]]), digits = 1)
ymn=round(min(bigDf[[yKey]]), digits = 1)
ymx=round(max(bigDf[[yKey]]), digits = 1)

templateRaster = raster::raster(
    xmn=xmn,
    xmx=xmx,
    ymn=ymn,
    ymx=ymx,
    resolution=c(0.06)
)

sampleRaster = raster::rasterize(sampleDf, templateRaster, fun="count")

# Plot
p = gplot(sampleRaster) +
    geom_tile(aes(fill = value)) +
    scale_fill_continuous(na.value="transparent") +
    xlab(xKey) +
    ylab(yKey) + 
    labs(fill="Count") + 
    xlab(expression("Dispersal kernel exponent, "*italic(α))) +
    ylab(expression("Log of transmission rate, "*ln(italic(β))))

for(convexBatch in names(convexBatchDfList)){

    thisHull = convexBatchDfList[[convexBatch]]
    p = p + geom_polygon(data = thisHull, aes_string(x=xKey, y=yKey, colour="batch", group="batch"), alpha = 0)

}

p = p + labs(colour="Batch") +
    theme(axis.text=element_text(size=12))
                                    

# p
cowplot::save_plot("sampling_density.png", p)
