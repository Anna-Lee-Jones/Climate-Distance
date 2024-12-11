#Centres of Agrobiodiversity
library(terra)

#set working directory
setwd("/Users/user/KEW/Cluster_Code")

#import tif of all the outputs from cluster
output_rast<-rast("ALL_OUTPUT.tif")#climate distances


agrobiodiversity<-vect("~/agrobiodiversity-polygons 2/agrobiodiversity-polygon.shp")
plot(agrobiodiversity)
#split into Hotspot vs Vavilov ? whats ref for hotspots
agrobiodiversity_Hotspot<-agrobiodiversity[1:26]
agrobiodiversity_Vavilov<-agrobiodiversity[27:44]
plot(agrobiodiversity_Hotspot)
plot(agrobiodiversity_Vavilov)
#average climate distance per agrobiodiversity hotspot
AB_avg_all<-extract(output_rast,agrobiodiversity, mean, na.rm=TRUE)
AB_avg_all
write.csv(AB_avg_all,"agrobiodiv_cd_all.csv")
AB_avg_hotspot<-extract(output_rast,agrobiodiversity_Hotspot, mean, na.rm=TRUE)
AB_avg_hotspot
write.csv(AB_avg_hotspot,"agrobiodiv_cd_hotspot.csv")
AB_avg_vav<-extract(output_rast,agrobiodiversity_Vavilov, mean, na.rm=TRUE)
AB_avg_vav
write.csv(AB_avg_vav,"agrobiodiv_cd_vavilov.csv")

#create rasters of climate distance for only agrobiodiversity hotspots vs other areas using mask 
AB_mask<- mask(output_rast,agrobiodiversity)
not_AB_mask<-mask(output_rast,agrobiodiversity,inverse=TRUE)
plot(AB_mask)
#stack rasters and get summary stats
STACK<-rast(list(AB_mask,not_AB_mask))
names(STACK)<-c("AB","NotAB")
boxplot(STACK)
global(STACK, c("sum", "mean", "sd","notNA"), na.rm=TRUE)

#export centre of agrobio vs not raster, convert to csv on david laptop
plot(STACK)
writeRaster(STACK,"centre_agro_stack.tif", overwrite=TRUE)

#agrobiodiversity hotspots have lower average climate distance that other areas
#need to do morans on this as csv
t.test.fromSummaryStats <- function(mu,n,s) {
  -diff(mu) / sqrt( sum( s^2/n ) )
}

mu <- c(1.0114410,0.8008155)
n <- c(8034524,1573121)
s <- c(1.416700,1.299659)
t.test.fromSummaryStats(mu,n,s)
qt(p = .05, df = 8034523)
# Finding the p-value
p_value=2*pt(q=183.0809, df=8034523, lower.tail=FALSE)
p_value
