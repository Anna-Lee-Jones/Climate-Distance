#load libraries
library(terra)
library(data.table)

#set working directory
setwd("/Users/user/KEW/Cluster_Code")

#requires laptop with decent RAM, and potentially increasing vector size limit for R
#on windows use this https://www.rdocumentation.org/packages/utils/versions/3.4.1/topics/memory.size

#load tif raster to be converted
rast<-rast("climate_input_unrounded.tif")
df<-as.data.frame(rast, cell=TRUE, xy=TRUE)#convert rast to dataframe
dt<-setDT(df)#convert dataframe to datatable (better for large exports to csv)
fwrite(dt, "climate_input_unrounded.csv")#runs in parallel, much faster than write.csv
