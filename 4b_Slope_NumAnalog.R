#load libraries
library(terra)
library(dplyr)
library(spdep)
library(tidyterra)

#set working directory
setwd("/Volumes/Kew Back Up 1/KEW/Cluster_Code/March_25_Run/June_Output/processing")

#import tif of all the outputs from cluster
output_rast<-rast("OUTPUT_numanalog.tif")#climate distances
slope_rast<-rast("slope_processed.tif")#slope of input 10%

#reproject  the slope to match the outout  tif
slope_rast<-terra::project(x=slope_rast, y=output_rast, method="near")
slope_rast<-slope_rast$slope

# Mask slope raster to only keep values where output_rast has data
slope_masked <- mask(slope_rast, output_rast)

# Stack the two rasters
stacked_rast<-rast()
stacked_rast$distance<-output_rast$OUTPUT_numanalog
stacked_rast$slope<-slope_masked$slope

# Define cropping extent: xmin, xmax, ymin, ymax to exclude the south pole
# Keep full longitude range, but restrict latitude to above -60
crop_extent <- ext(-180, 180, -60, 90)

# Apply crop to your stacked raster
stacked_cropped <- crop(stacked_rast, crop_extent)

# Plot to verify
plot(stacked_cropped)

#write tif to file
writeRaster(stacked_rast, "stacked_numanalog_slope.tif", overwrite = TRUE)
#convert tif to csv using tif to csv python script

csv<-fread('ClimateDistance_Slope.csv')
plot(csv$Climate_Distance,csv$Slope)
