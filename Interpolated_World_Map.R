#load libraries
library(data.table)
library(sf)
library(terra)
library(tidyr)
library(plyr)
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
setwd("/Volumes/Kew Back Up 1/KEW/Cluster_Code")

#load csv of cells with latitude, longitude and climate distance (not temp and rainfall data)
dt<- fread("Climate_Distance_only_KM.csv", header = TRUE, na.strings = c(NA_character_,"NA"))

#set column names
colnames(dt)<-c("x","y","distance")

#set inf distances (no analog found) to NA
dt$distance[is.infinite(dt$distance)] <- NA

#summarise climate distance data
summary(dt$distance)

#set NA cells (no analog found) to a max distance
dt$distance[is.na(dt$distance)] <- 3000

# subsample randomly (e.g., 1 million rows)
dt_subset <- dt[sample(.N, 1e6)]  # random sample of 1 million rows

#interpolate min climate distance (linear) #360,180 (1dg), 720,360(0.5dg), 1440,720(0.25dg, 2880,1440(0.125dg))
interp_df <- interp(dt_subset$x, dt_subset$y, dt_subset$distance, nx = 720, ny = 360, duplicate = "mean", method="linear") |> 
  interp2xyz() |> 
  as.data.frame()
write.csv(interp_df,"1mill_CD_Linear_interp_eightdegree_maxed3000NA.csv", row.names = TRUE)
#skip to here
interp_df<-read.csv("OLD_RESULT_1mill_CD_Linear_interp_eightdegree_maxed3000NA.csv")

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

#Post interpolation smoothing options
# Create a custom Gaussian kernel
gaussian_kernel <- function(size, sigma) {
  center <- floor(size / 2)
  mat <- outer(0:(size - 1), 0:(size - 1), function(i, j) {
    x <- i - center
    y <- j - center
    exp(-(x^2 + y^2) / (2 * sigma^2))
  })
  mat / sum(mat)
}

# Example: 5x5 kernel with sigma = 1.5
g_kernel <- gaussian_kernel(5, 1.5)

# Apply smoothing
r_smooth <- focal(r, w = g_kernel, fun = sum, na.rm = TRUE)

# Convert back to data frame
interp_df_smooth <- as.data.frame(r_smooth, xy=TRUE)
colnames(interp_df_smooth) <- c("x", "y", "z")

#plot smoothed result
tiff("/Volumes/Kew Back Up 1/KEW/Cluster_Code/Final Figures/World Map/smooth_Lin_interp_1mill_eightdegree_world_map.tiff", units="in", width=10, height=5, res=300)
ggplot() +
  geom_raster(data = interp_df_smooth, aes(x = x, y = y, fill = log(z+1)), interpolate = TRUE) +
  labs(x = "", y = "", fill = "Log Interpolated\nClimate Distance (km)") +
  scale_fill_viridis(option = "D", na.value = "lightgray", direction = 1,
                     labels = exp_labels) +
  geom_sf(data = sea, fill = "lightgray", color = NA) +
  coord_sf(xlim = c(-180, 180), ylim = c(-60, 80), expand = FALSE) +
  theme_bw()
dev.off()
