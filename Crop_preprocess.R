#load libraries
library(terra)
library(dplyr)

setwd("~/OneDrive - Nexus365/Cluster_Code")
#creat vrt to read in multiple crop cover tifs for 2003 and 2019
vrt(
  x = list.files(path = "~/OneDrive - Nexus365/Cluster_Code/crop/2003", pattern = "*.tif", full.names = TRUE), 
  filename = "Cropland_03.vrt",overwrite=TRUE
)
vrt(
  x = list.files(path = "~/OneDrive - Nexus365/Cluster_Code/crop/2019", pattern = "*.tif", full.names = TRUE), 
  filename = "Cropland_19.vrt",overwrite=TRUE
)
# afterwards read it as if it was a normal raster:
crop_03_rast <- rast("Cropland_03.vrt")
crop_19_rast <- rast("Cropland_19.vrt")
plot(crop_03_rast)
crop_03_rast
#convert NA to 0 for binary calcs
ncell(crop_03_rast)
#


#import tif of all the outputs from cluster
output_rast<-rast("ALL_OUTPUT.tif")

#match projections
crop_03_rast<- terra::project(x=crop_03_rast, y=output_rast, method="near")
crop_19_rast<-terra::project(x=crop_19_rast, y=output_rast, method="near")
plot(crop_19_rast)
plot(crop_03_rast)
crop_19_rast
dist<-output_rast$"26"
crop_19_dist<-mask(dist,crop_19_rast)

#calculate expansion and loss areas
crop_expansion<-crop_19_rast - crop_03_rast
crop_expansion
plot(crop_expansion)

## from-to-becomes
# classify the values into two groups 
# 0 or less becomes 0, 1 becomes 1
m <- c(-2, 0, 0,
       0, 1, 1)
rclmat <- matrix(m, ncol=3, byrow=TRUE)
crop_expansion <- classify(crop_expansion, rclmat, include.lowest=TRUE)
plot(crop_expansion)
crop_expansion<-terra::project(x=crop_expansion, y=crop_19_rast, method="near")
plot(crop_expansion)
#crop loss
crop_loss<- crop_03_rast - crop_19_rast
crop_loss <- classify(crop_loss, rclmat, include.lowest=TRUE)
plot(crop_loss)
#crop constant
crop_constant<- crop_19_rast - crop_expansion
crop_constant <- classify(crop_constant, rclmat, include.lowest=TRUE)
plot(crop_constant)

#save all the crop layers 
crop_all<-rast(list(crop_03_rast,crop_19_rast,crop_expansion,crop_loss,crop_constant))
names(crop_all)<-c("Cropland_03","Cropland_19","Crop_Expansion","Crop_Loss","Crop_Constant")
plot(crop_all)

#output all layer raster
writeRaster(crop_all,"~/OneDrive - Nexus365/Cluster_Code/crop_output.tif" , overwrite=TRUE)


plot(crop_expansion, col=c("black","green"))
plot(crop_loss, col=c("black","red"))
plot(crop_constant)
plot(crop_03_rast)
plot(crop_19_rast)
