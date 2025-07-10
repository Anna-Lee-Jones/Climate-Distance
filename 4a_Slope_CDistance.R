#load libraries
library(terra)
library(dplyr)
library(spdep)
library(tidyterra)

#set working directory
setwd("/Volumes/Kew Back Up 1/KEW/Cluster_Code/March_25_Run/June_Output/processing")

#import tif of all the outputs from cluster
output_rast<-rast("OUTPUT_minCD.tif")#climate distances
output_rast$OUTPUT_minCD
slope_rast<-rast("slope_processed.tif")#slope of input 10%

#reproject  the slope to match the outout  tif
slope_rast<-terra::project(x=slope_rast, y=output_rast, method="near")
slope_rast<-slope_rast$slope

# Count non-NA cells in the CD_output raster
n_valid <- global(!is.na(output_rast), fun = "sum", na.rm = TRUE)
print(n_valid)#correct, there are 6 million cells, NA (no analog found) are removed

# Mask slope raster to only keep values where output_rast has data
slope_masked <- mask(slope_rast, output_rast)

# Stack the two rasters
stacked_rast<-rast()
stacked_rast$distance<-output_rast$OUTPUT_minCD
stacked_rast$slope<-slope_masked$slope

#check the min max values and cell numbers make sense
stacked_rast <- setMinMax(stacked_rast)
n_valid <- global(!is.na(stacked_rast), fun = "sum", na.rm = FALSE)
print(n_valid)

# Define cropping extent: xmin, xmax, ymin, ymax to exclude the south pole
# Keep full longitude range, but restrict latitude to above -60
crop_extent <- ext(-180, 180, -60, 90)

# Apply crop to your stacked raster
stacked_cropped <- crop(stacked_rast, crop_extent)
# Plot to verify
plot(stacked_cropped)

writeRaster(stacked_rast, "stacked_minCD_slope.tif", overwrite = TRUE)


csv<-fread('ClimateDistance_Slope.csv')
plot(csv$Climate_Distance,csv$Slope)
