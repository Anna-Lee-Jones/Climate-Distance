#load libraries
library(terra)
library(dplyr)
library(spdep)
library(tidyterra)
#set working directory
setwd("/Users/user/KEW/Cluster_Code")

#import tif of all the outputs from cluster
output_rast<-rast("ALL_OUTPUT.tif")#climate distances
crop_rast<-rast("crop_output.tif")#crop binary
slope_rast<-rast("10percen_Slope.tif")#slope of input 10%
plot(slope_rast)
crop_rast<-terra::project(x=crop_rast, y=output_rast, method="near")
slope_rast<-terra::project(x=slope_rast, y=output_rast, method="near")
slope_rast$distance<-output_rast
plot(crop_rast$Cropland_19)


#MASK NEEDS TO ONLY APPLY TO 1 CROP VALUES, CURRENTLY JUST USING ANY WHICH AREN'T NA
crop_rast_NA<-subst(crop_rast$Cropland_19, 0, NA)
plot(crop_rast_NA)

#mask output `CDs` to agricultural areas from 2019, steep vs not
slope_agro_rast<-mask(slope_rast, crop_rast_NA)#crop slope rast to agro regions
steep_agro_rast<-slope_agro_rast
notsteep_agro_rast<-slope_agro_rast

#set slope cut off for steep, slope>12=steep, all other slope values to NA
gc()
steep_agro_rast$slope <- app(steep_agro_rast$slope, fun=function(slope){ slope[slope <12] <- NA; return(slope)} )
#drop NA
steep_agro_rast$distance<-mask(steep_agro_rast$distance, steep_agro_rast$slope)
global(steep_agro_rast, c("sum", "mean", "sd","notNA"), na.rm=TRUE)

#repeat for notsteep, slope <12
gc()
notsteep_agro_rast$slope <- app(notsteep_agro_rast$slope, fun=function(slope){ slope[slope >12] <- NA; return(slope)} )
notsteep_agro_rast$distance<-mask(notsteep_agro_rast$distance, notsteep_agro_rast$slope)
global(notsteep_agro_rast, c("sum", "mean", "sd","notNA"), na.rm=TRUE)

#stack 
slope_agro_rast_all<-rast()
slope_agro_rast_all$all<-slope_agro_rast$distance
slope_agro_rast_all$steep<-steep_agro_rast$distance
slope_agro_rast_all$notsteep<-notsteep_agro_rast$distance
writeRaster(slope_agro_rast_all,"slope_agro_stack.tif", overwrite=TRUE)

#skip to here
slope_agro_rast_all<-rast("slope_agro_stack.tif")



#Boxplot climate distances
stats<-global(slope_agro_rast_all, c("sum", "mean", "sd","notNA"), na.rm=TRUE)
stats
boxplot(slope_agro_rast_all)
boxplot(slope_agro_rast_all$steep)
slope_agro_rast_all$steep

#at this point could convert the agro and non agro rasters to csv 
#and then do stats with CSV, including the morrans I test for spatial autocorrelation
#this part will need to run and export on davids laptop:
steep_agro_df<-as.data.frame(slope_agro_rast_all$steep, cells=F, xy=T)
notsteep_agro_df<-as.data.frame(slope_agro_rast_all$notsteep, cells=F, xy=T)




