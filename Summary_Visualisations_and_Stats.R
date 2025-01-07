library(terra)
library(ggplot2)
library(ggpubr)
library(moranfast)
library(plyr)
library(dplyr)
library(forcats)
library(scales)


setwd("/Users/user/KEW/Cluster_Code")
#CROPLAND VS NON CROPLAND 
cropland_df<-read.csv("Agro_Stack_cropland.csv")
noncropland_df<-read.csv("Agro_Stack_noncropland.csv")
#to deal with sample size difference
noncropland_df<-noncropland_df[sample(nrow(noncropland_df),1000000),]

df<-rbind(cropland_df,noncropland_df)
ggplot(df, aes(x=Land_Type, y=(Climate_Distance))) + 
  geom_boxplot()
ggplot(df, aes(x=Land_Type, y=(Climate_Distance))) + 
  geom_violin()+coord_cartesian()
logdf<-df
logdf$Climate_Distance<-log(df$Climate_Distance)
mu <- ddply(df, "Land_Type", summarise, grp.mean=mean(Climate_Distance))
head(mu)
cropland<-ggplot(df, aes(x=log(Climate_Distance), fill=Land_Type)) + 
  geom_density(alpha=0.4)+labs(x="Log Climate Distance (km)", y="Density")+
  guides(fill=guide_legend(title="Land Type"))+coord_cartesian(xlim=c(0,7.5))+
  scale_x_continuous(breaks = seq(-1,20,by = 1),
                     limits = c(-1,20),
                     labels = math_format())+
  theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                   panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
cropland
group_by(df,Land_Type) %>%
  summarise(
    count = n(),
    mean = mean(Climate_Distance, na.rm = TRUE),
    IQR = IQR(Climate_Distance, na.rm = TRUE))
df$logClimateDistance<-log(df$Climate_Distance)#log transform data into normal distribution
df<-subset(df,logClimateDistance!="-Inf")
t.test(Climate_Distance ~ Land_Type, data=df)
#STEEP VS NOT STEEP CROPLAND (12% CUT OFF)
steep_df<-read.csv("Agro_steep.csv")
nonsteep_df<-read.csv("Agro_notsteep.csv")
df2<-rbind(steep_df,nonsteep_df)
mu <- ddply(df2, "Cropland_Type", summarise, grp.mean=mean(Climate_Distance))
head(mu)
steep<-ggplot(df2, aes(x=log(Climate_Distance), fill=Cropland_Type)) + 
  geom_density(alpha=0.4)+labs(x="Log Climate Distance (km)", y="Density")+
  guides(fill=guide_legend(title="Cropland Steepness"))+coord_cartesian(xlim=c(0,7.5))+
  scale_x_continuous(breaks = seq(-1,20,by = 1),
                     limits = c(-1,20),
                     labels = math_format())+
  theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                   panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
steep
df2$logClimateDistance<-log(df2$Climate_Distance)#log transform data into normal distribution
df2<-subset(df2,logClimateDistance!="-Inf")
t.test(Climate_Distance ~ Cropland_Type, data=df2)
#CROP EXPANSION/LOSS/CONSTANT
expan_df<-read.csv("crop_expansion.csv")
const_df<-read.csv("crop_constant.csv")
loss_df<-read.csv("crop_loss.csv")
df3<-rbind(expan_df,const_df,loss_df)
mu <- ddply(df3, "Type", summarise, grp.mean=mean(Climate_Distance))
head(mu)
df3$Type<-as.factor(df3$Type)
crop_change<-ggplot(df3, aes(x=log(Climate_Distance), fill=Type)) + 
  geom_density(alpha=0.4)+labs(x="Log Climate Distance (km)", y="Density")+
  guides(fill=guide_legend(title="Cropland Change"))+coord_cartesian(xlim=c(0,7.5))+
  scale_x_continuous(breaks = seq(-1,20,by = 1),
                     limits = c(-1,20),
                     labels = math_format())+
  theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                   panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
crop_change
df3$logClimateDistance<-log(df3$Climate_Distance)#log transform data into normal distribution
df3<-subset(df3,logClimateDistance!="-Inf")
field_aov<-aov(logClimateDistance~Type, data=df3)
hist(field_aov$residuals)
summary(field_aov)
TukeyHSD(field_aov)
#CENTRES OF AGROBIODIVERSITY
agbio_df<-read.csv("centre_agrobio.csv")
non_agbio_df<-read.csv("noncentre_agrobio.csv")
df4<-rbind(agbio_df,non_agbio_df)
mu <- ddply(df4, "Type", summarise, grp.mean=mean(Climate_Distance))
head(mu)
#shorter legend labels
df4[df4=="Centre of Agrobiodiversity"]<-"Center"
df4[df4=="Non-centre of Agrobiodiversity"]<-"Non-center"

agrobio<-ggplot(df4, aes(x=log(Climate_Distance), fill=Type)) + 
  geom_density(alpha=0.4)+labs(x="Log Climate Distance (km)", y="Density")+
  guides(fill=guide_legend(title="Agrobiodiversity"))+coord_cartesian(xlim=c(0,7.5))+
  scale_x_continuous(breaks = seq(-1,20,by = 1),
                     limits = c(-1,20),
                     labels = math_format())+
  theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                   panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
agrobio
df4$logClimateDistance<-log(df4$Climate_Distance)#log transform data into normal distribution
df4<-subset(df4,logClimateDistance!="-Inf")
t.test(Climate_Distance ~ Type, data=df4)

#field size
vsmall<-read.csv("field_vsmall.csv")
small<-read.csv("field_small.csv")
medium<-read.csv("field_medium.csv")
large<-read.csv("field_large.csv")
vlarge<-read.csv("field_vlarge.csv")
df5<-rbind(vsmall,small,medium,large, vlarge)
colnames(df5)<-c("X","Climate_Distance","Field_Size")
df5$Field_Size<-as.factor(df5$Field_Size)
df5$Field_Size<-factor(df5$Field_Size,levels=c("vsmall","small","medium","large","vlarge"))
mu <- ddply(df5, "Field_Size", summarise, grp.mean=mean(Climate_Distance))
head(mu)
field<-ggplot(df5, aes(x=log(Climate_Distance), fill=Field_Size)) + 
  geom_density(alpha=0.4)+labs(x="Log Climate Distance (km)", y="Density")+
  guides(fill=guide_legend(title="Field Size"))+coord_cartesian(xlim=c(0,7.5))+
  scale_x_continuous(breaks = seq(-1,20,by = 1),
                     limits = c(-1,20),
                     labels = math_format())+
  theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                   panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
field
#STATS FOR FIELD SIZE 
df5$logClimateDistance<-log(df5$Climate_Distance)#log transform data into normal distribution
df5<-subset(df5,logClimateDistance!="-Inf")
field_aov<-aov(logClimateDistance~Field_Size, data=df5)
hist(field_aov$residuals)
summary(field_aov)
tt<-TukeyHSD(field_aov)
print(tt, digits = 8)
#P adj is 0 for all pairings

## big multiplot
#load libraries
library(data.table)#efficient handling of large csv as data table rather than dataframe
library(sf)#simple features library
library(rnaturalearth)
library(rnaturalearthdata)
library(dplyr)
library(sp)
library(tidyverse)
library(stringr)
library(beepr)
library(ggnewscale)


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
worldplt<-ggplot()+
  geom_raster(data = out , aes(x = x, y = y, fill= z), interpolate = TRUE)+
  labs( x="", y="", fill="Interpolated\nClimate Distance (km)")+
  viridis:: scale_fill_viridis(option = "H", na.value = "white", direction=1)+
  geom_sf(data=na_points, size = 0.001, shape = 3, color = "white", alpha=0.03)+
  geom_sf(data=sea, fill="lightgray", color="lightgray")+
  coord_sf(xlim=c(-180,180), ylim=c(-60,90), expand = FALSE)+
  theme_bw()
worldplt
#combine plots
tiff("world_map_multiplot.tiff", units="in", width=10, height=7, res=300)
ggarrange(worldplt,
          ggarrange(cropland, crop_change, ncol = 3, labels = c("B", "C"), widths = c(1,1,0.1)), 
          nrow = 2, labels = "A", heights=c(1,0.5)) 
dev.off()

tiff("second_multiplot.tiff", units="in", width=12, height=3, res=300)
ggarrange( field, agrobio, steep,
          nrow = 1,ncol=3, labels = c("A", "B", "C"), widths = c(1,1,1)) 
dev.off()

