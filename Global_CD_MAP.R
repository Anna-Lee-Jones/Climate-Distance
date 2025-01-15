#Script to plot interpolated global map of climate distances 

#load libraries
library(data.table)#efficient handling of large csv as data table rather than dataframe
library(sf)#simple features library
library(rnaturalearth)
library(rnaturalearthdata)
library(ggplot2)
library(dplyr)
library(sp)
library(tidyverse)
library(stringr)
library(beepr)
library(ggnewscale)

#set working directory
setwd("/Users/user/KEW/Cluster_Code")

#load csv of cells with latitude, longitude and climate distance (not temp and rainfall data)
dt<- fread("Climate_Distance_only_KM.csv", header = TRUE, na.strings = c(NA_character_,""))

#0 climate distance means climate doesn't change between T1 and T2
#NA climate distance means no analog found in T2
#subset the NA cells 
na<-dt[rowSums(is.na(dt))>0,]
#make NA cells geompoints
na_points<-st_as_sf(na, coords = c("X","Y"),crs=4326)

#import basemaps of countries and sea
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")  # add continents
sea<-ne_download(scale = 50, type = 'ocean', category = "physical")


#Import interpolated CSV 
out<-fread("1mill_CD_Linear_interp_halfdegree.csv", header  = TRUE)
out<-subset(out, select = c(x,y,z) )
#plot interpolated climate distance, with seas masked 
#plot area cropped to exclude antartica
tiff("1mill_Lin_interp_CD_halfdegree.tiff", units="in", width=10, height=5, res=300)
ggplot()+
  geom_raster(data = out , aes(x = x, y = y, fill= z), interpolate = TRUE)+
  labs( x="", y="", fill="Interpolated\nClimate Distance (km)")+
  viridis:: scale_fill_viridis(option = "H", na.value = "white", direction=1)+
  geom_sf(data=na_points, size = 0.001, shape = 3, color = "white", alpha=0.1)+
  geom_sf(data=sea, fill="lightgray", color="lightgray")+
  coord_sf(xlim=c(-180,180), ylim=c(-60,90), expand = FALSE)+
  theme_bw()
dev.off()
