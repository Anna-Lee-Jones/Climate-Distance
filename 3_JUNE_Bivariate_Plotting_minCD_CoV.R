#CHANGE TO BIVAR OF SLOPE VS INTERPOLATED CD?
#WOULD NEED SLOPE AS CSV

#load libraries
library(data.table)#efficient handling of large csv as data table rather than dataframe
library(sf)#simple features library
library(sp)
library(terra)
library(rnaturalearth)
library(rnaturalearthdata)
library(ggplot2)
library(dplyr)
library(sp)
library(tidyverse)
library(stringr)
library(beepr)
library(ggnewscale)
library(tidyr)
library(biscale)
#set working directory
setwd("/Volumes/Kew Back Up 1/KEW/Cluster_Code/March_25_Run/June_Output/processing")

#import basemaps of countries and sea
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")  # add continents
sea<-ne_download(scale = 50, type = 'ocean', category = "physical")


#Import interpolated CSVs 
CD<-fread("1mill_CD_Linear_interp_quartdegree_maxed5000NA.csv", header  = TRUE)
CD<-subset(CD, select = c(x,y,z) )
CoV<-fread("1mill_CoV_Linear_interp_quartdegree_0NA.csv", header  = TRUE)
CoV<-subset(CoV, select = c(x,y,z) )
merged<-merge(CD, CoV, by=c("x","y")) 
colnames(merged)<-c("x","y","CD","CoV")
merged<-drop_na(merged)

# Add small jitter to mean and CoV variables
#merged$mean <- jitter(merged$mean, factor = 1)
merged$CoV <- jitter(merged$CoV, factor = 1)

# Classify the variables using biscale
bi_df <- bi_class(merged, x = CD, y = CoV, style = "quantile", dim = 3)
colnames(bi_df)<-c("x","y","CD","CoV","bivar")
pallet <- "PurpleOr"
biplot<-ggplot() +
  geom_raster(data = bi_df, aes(x = x, y = y, fill = bivar), show.legend = F) +
  bi_scale_fill(pal = pallet, dim = 3) +
  geom_sf(data=sea, fill="black", color="black")+
  coord_sf(xlim=c(-180,180), ylim=c(-60,80), expand = FALSE)+
  labs( x="",y="")+
  theme_void()
biplot
# Create the legend for the bivariate map
legend <- bi_legend(pal = pallet,   
                    flip_axes = FALSE,
                    rotate_pal = FALSE,
                    dim = 3,
                    xlab = "Min CD",
                    ylab = "CoV of CD",
                    size = 12)
legend

library(cowplot)
finalPlot <- ggdraw() +
  draw_plot(biplot, 0, 0, 1, 1) +  # Draw the main map plot
  draw_plot(legend, -0.04, 0.21, 0.3, 0.3)  # Draw the legend in the specified position
tiff("bivariate_map.tiff", units="in", width=10, height=7, res=300)
finalPlot
dev.off()

#plot interpolated climate distance, with seas masked 
#plot area cropped to exclude antartica
worldplt<-ggplot()+
  geom_raster(data = merged , aes(x = x, y = y, fill= CoV), interpolate = TRUE)+
  labs( x="", y="", fill="Interpolated\nClimate Distance (km)")+
  viridis:: scale_fill_viridis(option = "H", na.value = "darkred", direction=1)+
  #geom_sf(data=na_points, fill="white",colour="white", cex=0.1)+
  geom_sf(data=sea, fill="lightgray", color="lightgray")+
  coord_sf(xlim=c(-180,180), ylim=c(-60,80), expand = FALSE)+
  theme_bw()
worldplt
