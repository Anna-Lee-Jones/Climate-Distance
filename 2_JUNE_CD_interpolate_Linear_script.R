#load libraries
library(data.table)
library(terra)
library(tidyr)
library(beepr)
library(interp)
library(ggplot2)
library(viridis)
library(cowplot)
library(rnaturalearth)
library(rnaturalearthdata)
#import basemaps of countries and sea
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")  # add continents
sea<-ne_download(scale = 50, type = 'ocean', category = "physical")
#set working directory
setwd("/Volumes/Kew Back Up 1/KEW/Cluster_Code/March_25_Run/June_Output/processing")
#load csv of cells with latitude, longitude and climate distance (not temp and rainfall data)
dt<- fread("Processed_Output.csv", header = TRUE, na.strings = c(NA_character_,"NA"))
dt$min_distance[is.infinite(dt$min_distance)] <- NA

#drop na or set to max distance?
#dt<-drop_na(dt)
dt$min_distance[is.na(dt$min_distance)] <- 5000
max(dt$min_distance,na.rm=T)

# subsample randomly (e.g., 1 million rows)
dt_subset <- dt[sample(.N, 1e6)]  # random sample of 1 million rows

#interpolate min climate distance (linear) #360,180 (1dg), 720,360(0.5dg), 1440,720(0.25dg, 2880,1440(0.125dg))
interp_df <- interp(dt_subset$x, dt_subset$y, dt_subset$min_distance, nx = 2880, ny = 1440, duplicate = "mean", method="linear") |> 
  interp2xyz() |> 
  as.data.frame()
write.csv(interp_df,"1mill_CD_Linear_interp_eightdegree_maxed5000NA.csv", row.names = TRUE)


#test plot

climate_plot <- ggplot()+
  geom_raster(data = interp_df , aes(x = x, y = y, fill= z), interpolate = TRUE)+
  labs( x="", y="", fill="Interpolated Climate Distance")+
  viridis:: scale_fill_viridis(option = "D", na.value = "lightgray", direction=1)+
  geom_sf(data=sea, fill="lightgray", color="lightgray")+
  coord_sf(xlim=c(-180,180), ylim=c(-60,90), expand = FALSE)+
  theme_bw()
tiff("Lin_interp_1mill_eightdegree_world_map.tiff", units="in", width=10, height=5, res=300)
climate_plot
dev.off()
# Custom function to format the legend labels as not logged climate distances
exp_labels <- function(breaks) {
  exp_breaks <- exp(breaks)
  formatted_labels <- sapply(exp_breaks, function(x) format(x, scientific = FALSE, digits = 2))
  return(formatted_labels)
}
# Log World plot
tiff("LOG_Lin_interp_1mill_eightdegree_world_map.tiff", units="in", width=10, height=5, res=300)
ggplot() +
  geom_raster(data = interp_df, aes(x = x, y = y, fill = log(z+1)), interpolate = TRUE) +
  labs(x = "", y = "", fill = "Log Interpolated\nClimate Distance (km)") +
  scale_fill_viridis(option = "D", na.value = "lightgray", direction = 1,
                     labels = exp_labels) +
  geom_sf(data = sea, fill = "lightgray", color = "lightgray") +
  coord_sf(xlim = c(-180, 180), ylim = c(-60, 80), expand = FALSE) +
  theme_bw()
dev.off()

