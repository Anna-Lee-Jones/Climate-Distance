#Script to plot global map of climate distances (2% cells 1km res)

#load libraries
library(data.table)#efficient handling of large csv as data table rather than dataframe
library(sf)#simple features library
library(rnaturalearth)
library(rnaturalearthdata)
library(ggplot2)
library(dplyr)
library(sp)
library(tidyverse)
library(akima)#for interpolation
library(stringr)
library(beepr)

#set working directory
setwd("/Users/user/KEW/Cluster_Code")

#load csv of cells with latitude, longitude and climate distance (not temp and rainfall data)
dt<- fread("Climate_Distance_only_KM.csv", header = TRUE, na.strings = c(NA_character_,""))
#0 climate distance means climate doesn't change between T1 and T2
#NA climate distance means no analog found in T2

#import basemaps of countries and sea
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")  # add continents
sea<-ne_download(scale = 50, type = 'ocean', category = "physical")

#subset the data for testing
dt_test<-dt[sample(1:nrow(dt),1000000, replace=FALSE),]
#1000 0.17s
#10,000 4.25s
#100,000 1.1 min, 6 min for 0.25 degree res
#1 mill 25 min (for 1 degree res)
#1 mill 1hr for 0.5 deg res, 1.78 hours for 0.24 deg res
#10 mill didn't finish in 12hr for 0.5 deg res


#subset the NA climate distance cells (no analog found)
na_test<-dt_test[rowSums(is.na(dt_test))>0,]
na<-dt[rowSums(is.na(dt))>0,]

#make NA cells geompoints
na_points<-st_as_sf(na_test, coords = c("X","Y"),crs=4326)
na_points<-st_as_sf(na, coords = c("X","Y"),crs=4326)

#remove NA climate distance cells for interpolation
dt_test<-na.omit(dt_test)
dt<-na.omit(dt)

#interpolate climate distance between cells 
#don't know how to make the interpolation "higher res", one value calculated per degree over range
start.time <- Sys.time()
val_interpol <- with(dt_test, akima::interp(X, Y, distance, xo = seq(min(-180), max(180), length =1441), yo = seq(min(-90), max(90), length =721), duplicate="mean"))
end.time <- Sys.time()
time.taken <- round(end.time - start.time,2)
time.taken
beep(2)

d1 <- expand.grid(x = 1:1441, y = 1:721) 
out <- transform(d1, z = val_interpol$z[as.matrix(d1)])
out$x <- (out$x-721)/4
out$y <- (out$y-361)/4
#save the interpolated data frame 
write.csv(out,"1mill_CD_interpolated_quartdegree.csv", row.names = TRUE)

#plot interpolated climate distance, with seas masked 
#plot area cropped to exclude antartica
tiff("1mill_world_map_CD_quartdegree.tiff", units="in", width=10, height=5, res=300)
ggplot()+
  geom_raster(data = out , aes(x = x, y = y, fill= z), interpolate = TRUE)+
  labs( x="", y="", fill="Interpolated\nClimate Distance (km)")+
  viridis:: scale_fill_viridis(option = "H", na.value = "lightgray", direction=1)+
  geom_sf(data=sea, fill="lightgray", color="lightgray")+
  coord_sf(xlim=c(-180,180), ylim=c(-60,90), expand = FALSE)+
  theme_bw()
dev.off()
#same plot but with
#NA cells plotted on top in white

tiff("1mill_world_map_CD_NA_quartdegree.tiff", units="in", width=10, height=7, res=300)
ggplot()+
  geom_raster(data = out , aes(x = x, y = y, fill= z), interpolate = TRUE)+
  labs( x="", y="", fill="Interpolated\nClimate Distance (km)")+
  viridis:: scale_fill_viridis(option = "H", na.value = "white")+
  geom_sf(data=na_points, size = 0.01, shape = 3, color = "white", alpha=0.1)+
  geom_sf(data=sea, fill="lightgray", color="lightgray")+
  coord_sf(xlim=c(-180,180), ylim=c(-60,90), expand = FALSE)+
  theme_bw()
dev.off()



