# load required packages:
library(terra)
library(geodata)
library(readxl)
library(ggplot2)
library(ggpubr)

#set working directory
setwd("~/OneDrive - Nexus365/Cluster_Code")
# import a world countries map:
countries <- world(resolution = 5, path = "maps")  # you may choose a smaller (more detailed) resolution for the polygon borders, and a different folder path to save the imported map
head(countries)
plot(countries)
countries

#import tif of all the outputs from cluster
output_rast<-rast("ALL_OUTPUT.tif")#climate distances

#determine countries using intersect method, takes a long time to run
CN_avg<-extract(output_rast,countries, mean, na.rm=TRUE)#this doesn't work if tidyr or tidyterra are loaded 
CN_avg$COUNTRY<- countries[1:231]$NAME_0


#Import the GHI dataset
GHI_data <- read_excel("GHI_data.xlsx", sheet = "Sheet1")
#merge datasets by country name
CN_avg_GHI<-merge(CN_avg,GHI_data,by="COUNTRY")
#plot relationship
plot(CN_avg_GHI$ALL_OUTPUT,CN_avg_GHI$GHI)
#should output result

##############################################
#restrict to just croplands

crop_rast<-rast("crop_output.tif")#crop binary
crop_rast<-terra::project(x=crop_rast, y=output_rast, method="near")
crop_rast_NA<-subst(crop_rast$Cropland_19, 0, NA)
crop_CD<-mask(output_rast, crop_rast_NA)
#determine countries using intersect method
CN_crop_avg<-extract(crop_CD,countries, mean, na.rm=TRUE)
CN_crop_avg$COUNTRY<- countries[1:231]$NAME_0
#Import the GHI dataset
GHI_data <- read_excel("GHI_data.xlsx", sheet = "Sheet1")
#merge datasets by country name
CN_crop_GHI<-merge(CN_crop_avg,GHI_data,by="COUNTRY")

#export
colnames(CN_crop_GHI)<-c("Country","ID","Climate_Distance", "GHI")
write.csv(CN_crop_GHI,"~/OneDrive - Nexus365/Cluster_Code/Country_CD_GHI.csv" )
write.csv(CN_crop_avg,"~/OneDrive - Nexus365/Cluster_Code/Country_CD.csv" )

################ SKIP TO HERE ###############################
CN_crop_GHI<-read.csv("/Users/user/KEW/Cluster_Code/Country_CD_GHI.csv")
CN_crop_GHI$GHI<-as.numeric(CN_crop_GHI$GHI)
CN_crop_GHI<-subset(CN_crop_GHI, Climate_Distance<240)#exclude very high CD outliers
#plot relationship
plot(CN_crop_GHI$Climate_Distance,CN_crop_GHI$GHI)
#pearsons correlation to be used for non-normal quantitative correlation
ggscatter(CN_crop_GHI, x = "Climate_Distance", y = "GHI",color="black",
          add = "reg.line",add.params = list(color = "#00BFC4", fill = "#00BFC4"), conf.int = TRUE,
          cor.coef = TRUE, cor.method = "pearson", cor.coef.coord = c(2,45),
          xlab = "Climate Distance (km)", ylab = "Global Hunger Index")
library(scales)
hex <- hue_pal()(2)
hex

