
#load library
library(terra)
library(ggplot2)
library(tidyverse)
library(tidyr)
library(data.table)

#set working directory
setwd("/Volumes/Kew Back Up 1/KEW/Cluster_Code/March_25_Run/June_Output/processing")

#load the climate distance + slope csv
output_df<-read.csv("ClimateDistance_Slope.csv")

#randomly sample 10k points for faster plotting
output_df_100k <- output_df[sample(nrow(output_df), 100000), ]
colnames(output_df_100k)<-c("X_Coordinate","Y_Coordinate","distance" ,"slope")
# Basic scatterplot
ggplot(output_df_100k, aes(x=slope, y=distance) ) +
  geom_point()

# 2d histogram with default option
ggplot(output_df_100k, aes(x=distance, y=slope) ) +
  geom_bin2d() +
  theme_bw()

# Bin size control + color palette
ggplot(output_df_100k, aes(x=slope, y=distance) ) +
  geom_bin2d(bins = 70) +
  scale_fill_continuous(type = "viridis") +
  theme_bw()

#James's plot

## Use densCols() output to get density at each point
z <- densCols(output_df_100k$slope,output_df_100k$distance, nbin=5000, bandwidth=0.5,colramp=colorRampPalette(c("black", "white")))
output_df_100k$dens <- col2rgb(z)[1,] + 1L
cols <-  colorRampPalette(c("#000099", "#00FEFF", "#45FE4F", 
                            "#FCFF00", "#FF9400", "#FF3100"))(256)
output_df_100k$col <- cols[output_df_100k$dens]
#THIS ONE IS THE BEST PLOT
par(mfrow=c(1,1))
p<-plot(distance~slope, data=output_df_100k[order(output_df_100k$dens),], pch=20, col=col, cex=0.8,
     ylab="Climate Distance (km)", xlab="Slope", las=1, ylim=c(0,2500), xlim=c(0,40))
#save as R object for replotting elsewhere
saveRDS(p,"Slope_Distance_heatmap_plot.rds")
# Save as high-resolution TIFF
getwd()
tiff("Slope_Distance_heatmap_plot.tiff", width = 5, height = 5, units = "in", 
     res = 300)
plot(distance~slope, data=output_df_100k[order(output_df_100k$dens),], pch=20, col=col, cex=0.8,
     ylab="Climate Distance (km)", xlab="Slope", las=1, ylim=c(0,2500), xlim=c(0,40))
dev.off()

# log scale
plot(log(distance+1)~slope, data=output_df_100k[order(output_df_100k$dens),], pch=20, col=col, cex=0.8,
     ylab="Climate Distance (km)", xlab="Slope", las=1, ylim=c(0,10), xlim=c(0,32), yaxt='n')
num <- c(0,1,5,10,25,50,100)
lognum <- log(num+1)
axis(2, at=lognum, labels=num, las=2)

####### NOW FOR NUMBER OF CLIMATE ANALOGS ########

#load the number of analogs + slope csv
output_df<-read.csv("NumAnalog_Slope.csv")

#randomly sample 10k points for faster plotting
output_df_100k <- output_df[sample(nrow(output_df), 100000), ]
colnames(output_df_100k)<-c("X_Coordinate","Y_Coordinate","num_analog" ,"slope")

## Use densCols() output to get density at each point
z <- densCols(output_df_100k$slope,output_df_100k$num_analog, nbin=5000, bandwidth=0.5,colramp=colorRampPalette(c("black", "white")))
output_df_100k$dens <- col2rgb(z)[1,] + 1L
cols <-  colorRampPalette(c("#000099", "#00FEFF", "#45FE4F", 
                            "#FCFF00", "#FF9400", "#FF3100"))(256)
output_df_100k$col <- cols[output_df_100k$dens]
#THIS ONE IS THE BEST PLOT
par(mfrow=c(1,1))
p<-plot(num_analog~slope, data=output_df_100k[order(output_df_100k$dens),], pch=20, col=col, cex=0.8,
        ylab="Number of Climate Analogs", xlab="Slope", las=1, ylim=c(0,20), xlim=c(0,40))
p

# Save as high-resolution TIFF
setwd("/Volumes/Kew Back Up 1/KEW/Cluster_Code/March_25_Run/June_Output/processing/plots")
tiff("Slope_NumAnalog_heatmap_plot.tiff", width = 5, height = 5, units = "in", 
     res = 300)
plot(num_analog~slope, data=output_df_100k[order(output_df_100k$dens),], pch=20, col=col, cex=0.8,
     ylab="Number of Climate Analogs", xlab="Slope", las=1, ylim=c(0,20), xlim=c(0,40))
dev.off()

