#load libraries
library(terra)
library(tidyterra)
library(data.table)

#set working directory
setwd("/Users/user/KEW/Cluster_Code")
#load tif raster to be converted
#requires laptop with decent RAM, and potentially increasing vector size limit for R
#on windows use this https://www.rdocumentation.org/packages/utils/versions/3.4.1/topics/memory.size

rast<-rast("centre_agro_stack.tif")
df<-as.data.frame(rast, cell=TRUE, xy=FALSE)#convert rast to dataframe
dt<-setDT(df)#convert dataframe to datatable (better for large exports to csv)
fwrite(dt, "Converted_Rast.csv")#runs in parallel, much faster than write.csv
