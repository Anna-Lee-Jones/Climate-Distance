#load library
library(terra)
library(ggplot2)
library(tidyverse)
library(tidyr)
library(data.table)


output_df<-read.csv("/Users/user/Library/CloudStorage/OneDrive-Nexus365/Cluster_Code/KM_NEW_OUTPUT_climatedist.csv")
#remove NA distances (distance greater than 10 degrees or no analog)
output_df<-subset(output_df,!is.na(distance))
# Basic scatterplot
ggplot(output_df, aes(x=slope, y=distance) ) +
  geom_point()

# 2d histogram with default option
ggplot(output_df, aes(x=slope, y=distance) ) +
  geom_bin2d() +
  theme_bw()

# Bin size control + color palette
ggplot(output_df, aes(x=slope, y=distance) ) +
  geom_bin2d(bins = 70) +
  scale_fill_continuous(type = "viridis") +
  theme_bw()
#no zero distances
output_df_no0<-subset(output_df,distance!=0)
ggplot(output_df_no0, aes(x=slope, y=distance) ) +
  geom_bin2d(bins = 70) +
  scale_fill_continuous(type = "viridis") +
  theme_bw()
#log transformed distances
output_df_log<-output_df_no0
output_df_log$logdist<-log(output_df_log$distance)
ggplot(output_df_log, aes(x=slope, y=logdist) ) +
  geom_bin2d(bins = 70) +
  scale_fill_continuous(type = "viridis") +
  theme_bw()

#remove "minimal change" distances, eg <0.01 degrees
output_df_clipped<-subset(output_df, distance>0.01)
ggplot(output_df_clipped, aes(x=slope, y=distance) ) +
  geom_bin2d(bins = 70) +
  scale_fill_continuous(type = "viridis") +
  theme_bw()

#James's plot

## Use densCols() output to get density at each point
z <- densCols(output_df$slope,output_df$distance, nbin=5000, bandwidth=0.5,colramp=colorRampPalette(c("black", "white")))
output_df$dens <- col2rgb(z)[1,] + 1L
cols <-  colorRampPalette(c("#000099", "#00FEFF", "#45FE4F", 
                            "#FCFF00", "#FF9400", "#FF3100"))(256)
output_df$col <- cols[output_df$dens]
 #may need to do this plotting on big laptop
par(mfrow=c(1,1))
plot(distance~slope, data=output_df[order(output_df$dens),], pch=20, col=col, cex=0.8,
     ylab="Climate Distance (km)", xlab="Slope", las=1, ylim=c(0,1500), xlim=c(0,50))
# log scale
plot(log(distance+1)~slope, data=output_df[order(output_df$dens),], pch=20, col=col, cex=0.8,
     ylab="Climate Distance (km)", xlab="Slope", las=1, ylim=c(0,4.8), xlim=c(0,32), yaxt='n')
num <- c(0,1,5,10,25,50,100)
lognum <- log(num+1)
axis(2, at=lognum, labels=num, las=2)




