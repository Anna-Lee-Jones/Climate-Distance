#load libraries
library(terra)
library(tidyterra)
library(data.table)

df<- fread("~/OUPUT_TR_1km_T1T2_slope_dist.csv")
dist_rast<-as_spatraster(df, xycols = 2:3, crs="EPSG:4326", digits=1)
writeRaster(dist_rast, "~/OUTPUT_TR_1km_T1T2_slope_dist.tif")

