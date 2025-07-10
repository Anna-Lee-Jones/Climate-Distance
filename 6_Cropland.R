#load libraries
library(terra)
library(dplyr)
library(spdep)
#set working directory
setwd("/Volumes/Kew Back Up 1/KEW/Cluster_Code/March_25_Run/June_Output/Processing")

#haven't changed anything else for the new June 2025 run yet!


#import tif of all the outputs from cluster
output_rast<-rast("./Jan25_run/KMonly_OUTPUT_EXACT_capped1k.tif")#just mean climate distances
crop_rast<-rast("crop_output.tif")
plot(crop_rast1$Cropland_03)
plot(output_rast$distance)
crop_rast<-terra::project(x=crop_rast, y=output_rast, method="near")
plot(crop_rast$Cropland_19)

#MASK NEEDS TO ONLY APPLY TO 1 CROP VALUES, CURRENTLY JUST USING ANY WHICH AREN'T NA
crop_rast_NA<-subst(crop_rast$Cropland_19, 0, NA)
plot(crop_rast_NA)

#mask output `CDs` to agricultural areas from 2019
agro_dist<-rast()
agro_dist$AGRO<-mask(output_rast, crop_rast_NA)
#agro_dist$ALL<-output_rast
agro_dist$NON_AGRO<-mask(output_rast, crop_rast_NA, inverse=TRUE)
writeRaster(agro_dist,"Agro_stack.tif", overwrite=TRUE)
#writeRaster(agro_dist$AGRO,"AGRO_EXACT_CAPPED.tif", overwrite=TRUE)
#writeRaster(agro_dist$NON_AGRO,"NONAGRO_EXACT_CAPPED.tif", overwrite=TRUE)
#SKIP TO HERE
agro_dist<-rast("Agro_stack.tif")

#at this point could convert the agro and non agro rasters to csv 
#and then do stats with CSV, including the morrans I test for spatial autocorrelation
#this part will need to run and export on davids laptop:
agro_df<-as.data.frame(agro_dist$AGRO, cells=T, xy=T)

#install_github('mcooper/moranfast')
library(moranfast)
#set working directory
setwd("~/OneDrive - Nexus365/Cluster_Code")

agro_df<-read.csv("agro.csv")
non_rand<-agro_df[1:10000,]
subset<-agro_df[sample(nrow(agro_df), 1000000), ]
#this works up to 1mill values, beyond that takes a while but will run
moranfast(subset$AGRO, subset$x, subset$y)

# create a bubble plot with the random values
library(sp)
library(gstat) 
# convert simple data frame into a spatial data frame object
coordinates(subset)= ~ x+y
bubble(subset, zcol='AGRO', fill=TRUE, do.sqrt=FALSE, maxsize=3)
#runs slowly for >1 mill
TheVariogram=variogram(AGRO~1, data=subset)
plot(TheVariogram)

