# Aggregate grid polys into single sf df
maskDir = "../../summary_stats/mask_polys/" #mask_uga_grid_0.rds"

maskPaths = list.files(maskDir, "grid", full.names = T)

allMaskDf = data.frame()
for(maskPath in maskPaths){
    
    print(maskPath)
    
    maskDataSp = readRDS(maskPath)
    
    maskData = sf::st_as_sf(maskDataSp)
    
    allMaskDf = rbind(allMaskDf, maskData)
    
}

outPath = "data/masksDf.rds"
saveRDS(allMaskDf, outPath)

# ----------------------------
# Merge grid data

maskDir = "../../summary_stats//mask_stats/survey_data_C/"
maskPaths = list.files(maskDir, full.names = T, pattern="mask_.*grid")
maskList = list()
for(maskPath in maskPaths){
    maskList[[maskPath]] = read.csv(maskPath) |> dplyr::mutate(polySuffix=tools::file_path_sans_ext(basename(maskPath))) |>
        dplyr::mutate(polyName = paste0(year, "_", polySuffix))
}
maskDf = dplyr::bind_rows(maskList)

write.csv(maskDf, "./data/mask_stats_merged.csv", row.names=FALSE)

