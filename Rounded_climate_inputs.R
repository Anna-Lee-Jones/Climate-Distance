library(terra)
library(tidyterra)
library(data.table)
setwd("~/KEW/Cluster_Code/Climate_inputs")
T1_temp<-rast("T1_temp_processed_NEW.tif")
T2_temp<-rast("T2_temp_processed_NEW.tif")
T1_rain<-rast("T1_rain_processed_NEW.tif")
T2_rain<-rast("T2_rain_processed_NEW.tif")

#rounding temp to nearest 0.1 degree (1dp)
T1_temp<-round(T1_temp,1)
T2_temp<-round(T2_temp,1)
#rounding rain to nearest mm (0dp)
T1_rain<-round(T1_rain,0)
T2_rain<-round(T2_rain,0)
#stack rasters
all_rast<-rast(list(T1_temp,T2_temp,T1_rain,T2_rain))
#export rast as tif
writeRaster(all_rast,"~/KEW/Cluster_Code/Climate_inputs/climate_input_unrounded_NEW.tif" , overwrite=TRUE)

#next need to convert rast to CSV
#requires laptop with decent RAM, and potentially increasing vector size limit for R
#on windows use this https://www.rdocumentation.org/packages/utils/versions/3.4.1/topics/memory.size
df<-as.data.frame(all_rast, cell=TRUE, xy=TRUE, na.rm=TRUE)#convert rast to dataframe
dt<-setDT(df)#convert dataframe to datatable (better for large exports to csv)
fwrite(dt, "climate_input_unrounded.csv")#runs in parallel, much faster than write.csv

# see stand alone rast_to_csv script 