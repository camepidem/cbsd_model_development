options(stringsAsFactors = F)
library(rworldmap)
library(dplyr)
library(rgdal)
library(rgeos)
library(raster)
projStr = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"

inputsDir = "poly_inputs"
outDir = "mask_polys"
dir.create(outDir, showWarnings = F)

countryPolys = getMap(resolution = "high")

# --------------------
# Kam and ugaHole polys

kam_df = tribble(
  ~x, ~y,
  32.1983, 0.08599059,
  33.21496, 0.08599059,
  33.21496, 1.160991,
  32.1983, 1.160991,
  32.1983, 0.08599059
)

kam_matrix = as.matrix(kam_df)
kam_polygon = Polygon(kam_matrix)
kam_list = list(kam_polygon)
kam_polygons = Polygons(kam_list, 1)

uga_poly_df = countryPolys[countryPolys@data$ADM0_A3=="UGA",]
kam_spatial_polygons = SpatialPolygons(list(kam_polygons))

# **Weird behaviour: caused by internal removal of white space**
suppressWarnings({proj4string(uga_poly_df) = proj4string(uga_poly_df)})

proj4string(kam_spatial_polygons) = proj4string(uga_poly_df)
hole_poly = gDifference(uga_poly_df, kam_spatial_polygons)

kam_spdf = SpatialPolygonsDataFrame(kam_spatial_polygons, data=data.frame(ID="KAM", row.names=1))
hole_spdf = SpatialPolygonsDataFrame(hole_poly, data=data.frame(ID="HOLE"))

proj4string(kam_spdf) = projStr
proj4string(hole_spdf) = projStr

saveRDS(kam_spdf, file.path(outDir, "mask_uga_kam.rds"))
saveRDS(hole_spdf, file.path(outDir, "mask_uga_hole.rds"))

allPolyDf = rbind(
  kam_spdf, 
  hole_spdf
)

# -----------------------------
# Gen grid polys
nBreaks = 5

xDiff = xmax(uga_poly_df) - xmin(uga_poly_df)
yDiff = ymax(uga_poly_df) - ymin(uga_poly_df)

dx = xDiff / nBreaks
dy = yDiff / nBreaks

thisXmin = xmin(uga_poly_df)
thisYmin = ymin(uga_poly_df)

chunkCount = 0
for(i in 1:nBreaks){
  
  for(j in 1:nBreaks){
    
    chunkName = paste0("grid_", chunkCount)
    
    thisExtent = extent(thisXmin, thisXmin + dx, thisYmin, thisYmin + dy)
    
    thisExtentSp = as(thisExtent, 'SpatialPolygons')
    thisExtentSpDf = SpatialPolygonsDataFrame(thisExtentSp, data=data.frame(ID=chunkName))
    proj4string(thisExtentSpDf) = projStr
    
    chunkOutUga = over(uga_poly_df, thisExtentSpDf)
    chunkOutUgaBool = is.na(chunkOutUga[1,1])
    
    gridOutPath = file.path(outDir, paste0("mask_uga_", chunkName, ".rds"))
    if(!chunkOutUgaBool){
      saveRDS(thisExtentSpDf, gridOutPath)
      allPolyDf = rbind(allPolyDf, thisExtentSpDf)
    }
    
    thisYmin = thisYmin + dy
    chunkCount = chunkCount + 1
    
  }
  
  thisYmin = ymin(uga_poly_df)
  thisXmin = thisXmin + dx
  
}
