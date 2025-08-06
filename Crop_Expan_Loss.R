#load libraries
library(terra)
library(dplyr)
library(spdep)
library(tidyterra)
#set working directory
setwd("~/KEW/Cluster_Code")

#import tif of all the outputs from cluster
output_rast<-rast("ALL_OUTPUT.tif")#climate distances
crop_rast<-rast("crop_output.tif")#crop binary
slope_rast<-rast("10percen_Slope.tif")#slope of input 10%
#crop rast contains 1km crop land at 2003 and 2019, gain, loss and constant areas in binary
crop_rast<-terra::project(x=crop_rast, y=output_rast, method="near")
slope_rast<-terra::project(x=slope_rast, y=output_rast, method="near")
crop_expansion<-subst(crop_rast$Crop_Expansion, 0, NA)
crop_loss<-subst(crop_rast$Crop_Loss, 0, NA)
crop_constant<-subst(crop_rast$Crop_Constant, 0, NA)

#mask output `CDs` to agricultural areas 
crop_expansion_CD<-mask(output_rast, crop_expansion)
crop_loss_CD<-mask(output_rast, crop_loss)
crop_constant_CD<-mask(output_rast, crop_constant)

#stack
crop_change_stack<-rast()
crop_change_stack$expansion<-crop_expansion_CD$ALL_OUTPUT
crop_change_stack$loss<-crop_loss_CD$ALL_OUTPUT
crop_change_stack$constant<-crop_constant_CD$ALL_OUTPUT

#save stacked tif
writeRaster(crop_change_stack,"crop_change_stack.tif", overwrite=TRUE)

#add in climate distances retrospectively to agro steep stack:
crop_change_stack<-rast("crop_change_stack.tif")

#stats on stack
global(crop_change_stack, c("sum", "mean", "sd","notNA"), na.rm=TRUE)
boxplot(crop_change_stack)

#repeat for slope input data
crop_expansion_slope<-mask(slope_rast, crop_expansion)
crop_loss_slope<-mask(slope_rast, crop_loss)
crop_constant_slope<-mask(slope_rast, crop_constant)
#stack
crop_change_slope_stack<-rast()
crop_change_slope_stack$expansion<-crop_expansion_slope$slope
crop_change_slope_stack$loss<-crop_loss_slope$slope
crop_change_slope_stack$constant<-crop_constant_slope$slope
#save stacked tif
writeRaster(crop_change_slope_stack,"crop_change_slope.tif", overwrite=TRUE)

#add in climate distances retrospectively to agro steep stack:
crop_change_slope_stack<-rast("crop_change_slope.tif")

#stats on stack
global(crop_change_slope_stack, c("sum", "mean", "sd","notNA"), na.rm=TRUE)
boxplot(crop_change_slope_stack)
