#load libraries
library(terra)
library(dplyr)
library(parallel)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(ggplot2)
library(tidyterra)
library(readr)

#set wd
setwd("~/KEW/Cluster_Code/Climate_inputs")
# read chelsa TEMP tif files in as raster:

T1_temp_rast <- rast("CHELSA_bio1_2011-2040_gfdl-esm4_ssp370_V.2.1.tif")
T2_temp_rast <- rast("CHELSA_bio1_2041-2070_gfdl-esm4_ssp370_V.2.1.tif")

T1_rain_rast<-rast("CHELSA_bio12_2011-2040_gfdl-esm4_ssp370_V.2.1.tif")
T2_rain_rast<-rast("CHELSA_bio12_2041-2070_gfdl-esm4_ssp370_V.2.1.tif")


# import a world countries map:
countries <- geodata::world(resolution=2,path = tempdir())
# make a polygon map delimiting the entire extent of the Earth:
earth <- terra::vect(terra::ext(), crs = "EPSG:4326")
# erase the countries (land parts) to get just the marine polygon:
marine <- terra::erase(earth, countries)
#invert erase the sea to get a single spatial vector of 'land'
land <- terra::erase(earth, marine)

#crop chelsa rasters to land extent
T1_temp_rast_land<-mask(T1_temp_rast, land)
writeRaster(T1_temp_rast_land,"T1_temp_full.tif")
T2_temp_rast_land<-mask(T2_temp_rast, land)
writeRaster(T2_temp_rast_land,"T2_temp_full.tif")
T1_rain_rast_land<-mask(T1_rain_rast, land)
writeRaster(T1_rain_rast_land,"T1_rain_full.tif")
T2_rain_rast_land<-mask(T2_rain_rast, land)
writeRaster(T2_rain_rast_land,"T2_rain_full.tif")

#sample 2% cells, set rest to NA
T1_temp_rast_land<-rast("T1_temp_full.tif")
T1_temp_sample<-T1_temp_rast_land
c<-cells(T1_temp_sample)#returns cell numbers that are not NA
ncells<-length(c)
set.seed(123)
sample_lst<-sample(c,round(ncells*0.02,0))
#need to find a way to reuse the sample cell list
#without crashing, all tifs need same sample list
#stacking crashes
#could try sample(as.raster=TRUE)
#https://rdrr.io/cran/terra/man/sample.html

T1_temp_sample[c[-sample_lst]]<-NA
writeRaster(T1_temp_sample,"T1_temp_processed_NEW.tif" , overwrite=TRUE)

#can run each block independenlty (just load packages and setwd if r is crashing)
T2_temp_rast_land<-rast("T2_temp_full.tif")
gc()#clear unused R memory
T2_temp_sample<-T2_temp_rast_land
c<-cells(T2_temp_sample)
ncells<-length(c)
set.seed(123)
sample_lst<-sample(c,round(ncells*0.02,0))
sample_lst[1:10]# [1] 358105306 309476038 872852479 248303699 642423349
T2_temp_sample[c[-sample_lst]]<-NA
gc()
writeRaster(T2_temp_sample,"T2_temp_processed_NEW.tif" , overwrite=TRUE)

gc()
T1_rain_rast_land<-rast("T1_rain_full.tif")
T1_rain_sample<-T1_rain_rast_land
c<-cells(T1_rain_sample)
ncells<-length(c)
set.seed(123)
sample_lst<-sample(c,round(ncells*0.02,0))
sample_lst[1:10]# [1] 358105306 309476038 872852479 248303699 642423349
T1_rain_sample[c[-sample_lst]]<-NA
writeRaster(T1_rain_sample,"T1_rain_processed_NEW.tif" , overwrite=TRUE)

gc()
T2_rain_rast_land<-rast("T2_rain_full.tif")
T2_rain_sample<-T2_rain_rast_land
T2_rain_sample[c[-sample_lst]]<-NA
writeRaster(T2_rain_sample,"T2_rain_processed_NEW.tif" , overwrite=TRUE)
#next script: rounded_climate_inputs (stack rasters, round as desired and then export as CSV)



