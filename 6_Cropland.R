#load libraries
library(terra)
library(dplyr)
library(spdep)
#set working directory
setwd("/Volumes/Kew Back Up 1/KEW/Cluster_Code/March_25_Run/June_Output/Processing")

#haven't changed anything else for the new June 2025 run yet!


#import tif of CD outputs from cluster
output_rast<-rast("OUTPUT_minCD.tif")#just min climate distances
crop_rast<-rast("/Volumes/Kew Back Up 1/KEW/Cluster_Code/crop_output.tif")
plot(crop_rast$Cropland_03)
plot(output_rast$OUTPUT_minCD)
crop_rast<-terra::project(x=crop_rast, y=output_rast, method="near")
plot(crop_rast$Cropland_19)

#MASK NEEDS TO ONLY APPLY TO 1 CROP VALUES, CURRENTLY JUST USING ANY WHICH AREN'T NA
crop_rast_NA<-subst(crop_rast$Cropland_19, 0, NA)
plot(crop_rast_NA)

#mask output `CDs` to agricultural areas from 2019 and inverse
agro_dist<-rast()
agro_dist$AGRO<-mask(output_rast, crop_rast_NA)
agro_dist$NON_AGRO<-mask(output_rast, crop_rast_NA, inverse=TRUE)
#change variable names to distance
varnames(agro_dist)<-"distance"

#write tifs to file
writeRaster(agro_dist,"Agro_stack.tif", overwrite=TRUE)
writeRaster(agro_dist$AGRO,"AGRO.tif", overwrite=TRUE)
writeRaster(agro_dist$NON_AGRO,"NONAGRO.tif", overwrite=TRUE)

#convert tifs to csv using python script

#Looking at spatial autocorrelation
#Load github package
library(remotes)
install_github('mcooper/moranfast') #needs remotes package
library(moranfast)


agro_df<-read.csv("AGRO.csv")
subset<-agro_df[sample(nrow(agro_df), 100000), ]
#this works up to 1mill values, beyond that takes a while but will run
moranfast(subset$distance, subset$X_Coordinate, subset$Y_Coordinate)

# create a bubble plot with the random values
library(sp)
library(gstat) 
# convert simple data frame into a spatial data frame object
coordinates(subset)= ~ X_Coordinate+Y_Coordinate
bubble(subset, zcol='distance', fill=TRUE, do.sqrt=FALSE, maxsize=3)
#runs slowly for >1 mill
TheVariogram=variogram(distance~1, data=subset)
plot(TheVariogram)

