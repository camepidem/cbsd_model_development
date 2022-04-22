mergeMaskStats = function(
    maskDir
){
    outDir = file.path(maskDir, "merged")

    dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

    maskPaths = list.files(maskDir, full.names = T, pattern="mask_")
    maskList = list()
    for(maskPath in maskPaths){
        maskList[[maskPath]] = read.csv(maskPath) |> 
            dplyr::mutate(polySuffix=tools::file_path_sans_ext(basename(maskPath))) |>
            dplyr::mutate(polyName = paste0(year, "_", polySuffix)) |>
            dplyr::rename(surveyDataYear=year)
    }
    maskDf = dplyr::bind_rows(maskList)

    write.csv(maskDf, file.path(outDir, "mask_stats_merged.csv"), row.names=FALSE)

}
