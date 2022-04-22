library(ggplot2)
library(ggspatial)
library(rasterVis)

bigDf = readRDS("../analysis/results_fitting/sim_output_agg/model_2/2020_01_27_merged/survey_data_C/survey_data_C/results_summary_fixed_TARGET_MINIMAL.rds") |>
    dplyr::mutate(Rate_0_Sporulation_log = log(Rate_0_Sporulation), batch=substr(simKey, 1, 18))

batches = unique(bigDf$batch)

# ------------------------------------

for(batch in batches){

    print(batch)

    smallDf = bigDf[bigDf$batch==batch,]

    xKey = "Kernel_0_Parameter"
    yKey = "Rate_0_Sporulation_log"

    sampleDf = data.frame(
        x=smallDf[[xKey]],
        y=smallDf[[yKey]]
    )

    # Build convex hull of all sims
    hull = bigDf[chull(bigDf[[xKey]], bigDf[[yKey]]),]

    # Rasterise pass and sample data
    xmn=round(min(smallDf[[xKey]]), digits = 1)
    xmx=round(max(smallDf[[xKey]]), digits = 1)
    ymn=round(min(smallDf[[yKey]]), digits = 1)
    ymx=round(max(smallDf[[yKey]]), digits = 1)

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
        geom_polygon(data = hull, aes_string(x=xKey, y=yKey), alpha = 0.2) +
        xlab(xKey) +
        ylab(yKey) +
        ggtitle(batch)


    ggsave(file.path("plots", paste0(batch, ".png")), p)
    # p`

}
