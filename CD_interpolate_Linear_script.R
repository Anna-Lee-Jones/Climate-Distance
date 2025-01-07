#load libraries
library(data.table)
library(beepr)
library(interp)
library(ggplot2)
library(rnaturalearth)
library(rnaturalearthdata)
#import basemaps of countries and sea
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")  # add continents
sea<-ne_download(scale = 50, type = 'ocean', category = "physical")
#set working directory
setwd("/Users/user/KEW/Cluster_Code")
#load csv of cells with latitude, longitude and climate distance (not temp and rainfall data)
dt<- fread("Climate_Distance_only_KM.csv", header = TRUE, na.strings = c(NA_character_,""))
#subsample
test<-dt[sample(nrow(dt), 1000000, replace = FALSE), ]
#remove NA
test<-na.omit(test)
#interpolate (linear)
df2 <- interp(test$X, test$Y, test$distance, nx = 720, ny = 360, duplicate = "mean", method="linear") |> 
  interp2xyz() |> 
  as.data.frame()
write.csv(df2,"1mill_CD_Linear_interp_halfdegree.csv", row.names = TRUE)

#plot
tiff("Lin_interp2_1mill_world_map.tiff", units="in", width=10, height=5, res=300)
ggplot()+
  geom_raster(data = df2 , aes(x = x, y = y, fill= z), interpolate = TRUE)+
  labs( x="", y="", fill="Interpolated\nClimate Distance (km)")+
  viridis:: scale_fill_viridis(option = "H", na.value = "lightgray", direction=1)+
  geom_sf(data=sea, fill="lightgray", color="lightgray")+
  coord_sf(xlim=c(-180,180), ylim=c(-60,90), expand = FALSE)+
  theme_bw()
dev.off()

