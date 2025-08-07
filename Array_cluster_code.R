#load libraries
library(data.table)
library(dplyr)
library(geosphere)

#setwd to folder containing input and output files
setwd("~/OneDrive - Nexus365/Cluster_Code/APRIL_RUN")

# Read climate dataframe from CSV file (change filepath to where input CSV is stored)
clim_sampled <- fread("NEW_10percen_TR_1km_T1T2_slope.csv")
setcolorder(clim_sampled, c("cid","x","y","T1_temp","T2_temp","T1_rain","T2_rain","Slope"))
#add empty distance column for ouputs
clim_sampled$distance<-list()

#read in output csv of cells which have already been analysed
sampled_cells<-fread("OUTPUT_TR_1km_T1T2_slope_dist.csv")
sampled_cells<-data.frame(sampled_cells$V1)
colnames(sampled_cells)<-"cid"
#remove matching cells from input dataframe
clim_sampled<-anti_join(clim_sampled, sampled_cells, by="cid")
#total number of cells already calculated
total_sampled_cells<-nrow(sampled_cells)

# Pre-allocate memory for sample and sample_na
sample <- data.frame()
sample_na <- data.frame()
sample_indices<-list()
#set climate analogue search radius options
A<-0.5
B<-1
C<-10

# Step 1: Randomly select 10000 cells to calculate
sample_indices <- sample(nrow(clim_sampled), 10000)
sample <- clim_sampled[sample_indices,]
# Step 2: Find cells with no change in temp or rain (within +-5mm)
sample$distance <- ifelse((sample$T2_temp == (sample$T1_temp) &
                             sample$T2_rain >= (sample$T1_rain-5)&
                             sample$T2_rain<=(sample$T1_rain+5)), 0, "NA")
# Subset those which are not zero (NAs), ready to find distances
sample_match <- sample[sample$distance == 0, ]
sample_na <- sample[sample$distance == "NA", ]
# Append cells with 'zero climate distance' to the OUTPUT dataframe file
fwrite(sample_match, "OUTPUT_TR_1km_T1T2_slope_dist.csv", append = TRUE, row.names = FALSE, col.names = F, quote = FALSE)
# Step 3: For each cell with a climatic change, find analogues and calculate minimum distance to an analog
for(n in 1:nrow(sample_na)){
  focal<-sample_na[n,2:3]
  #search first remit for analogs to cell n
  remit<-clim_sampled[clim_sampled$x<as.numeric(focal[,1]+A) &
                        clim_sampled$x > as.numeric(focal[,1]-A) &
                        clim_sampled$y < as.numeric(focal[,2]+A) &
                        clim_sampled$y > as.numeric(focal[,2]-A),]
  #Find which cells within the remit are analogs at T2 to cell(n) at T1 in temp and rainfall +-5mm
  analogs<-remit[remit$T2_temp==(sample_na[n,T1_temp])&
                   remit$T2_rain >= (sample_na[n,T1_rain]-5)&
                   remit$T2_rain<=(sample_na[n,T1_rain]+5)]
  #If no analogs found, search the second remit  
  if(nrow(analogs)==0) {
    remit<-clim_sampled[clim_sampled$x<as.numeric(focal[,1]+B) &
                          clim_sampled$x > as.numeric(focal[,1]-B) &
                          clim_sampled$y < as.numeric(focal[,2]+B) &
                          clim_sampled$y > as.numeric(focal[,2]-B),]
    analogs<-remit[remit$T2_temp==(sample_na[n,T1_temp])&
                     remit$T2_rain >= (sample_na[n,T1_rain]-5)&
                     remit$T2_rain<=(sample_na[n,T1_rain]+5)]
    #If no analogs found, search the third remit
    if(nrow(analogs)==0) {
      remit<-clim_sampled[clim_sampled$x<as.numeric(focal[,1]+C) &
                            clim_sampled$x > as.numeric(focal[,1]-C) &
                            clim_sampled$y < as.numeric(focal[,2]+C) &
                            clim_sampled$y > as.numeric(focal[,2]-C),]
      analogs<-remit[remit$T2_temp==(sample_na[n,T1_temp])&
                       remit$T2_rain >= (sample_na[n,T1_rain]-5)&
                       remit$T2_rain<=(sample_na[n,T1_rain]+5)]
      #If still no analogs found, give climate distance NA
      if(nrow(analogs)==0){
        sample_na$distance[n]<-NA
        #Where analogs were found, calculate the haversine distance from cell(n) to each analog then record shortest distance as dist
      } else {
        n_analog<-nrow(analogs)
        dist_matrix<-distGeo(analogs[,2:3],focal)
        sample_na$distance[n]<-(min(dist_matrix[1:n_analog]))
      }
    } else {
      n_analog<-nrow(analogs)
      dist_matrix<-distGeo(analogs[,2:3],focal)
      sample_na$distance[n]<-(min(dist_matrix[1:n_analog]))
    }
  } else {
    n_analog<-nrow(analogs)
    dist_matrix<-distGeo(analogs[,2:3],focal)
    sample_na$distance[n]<-(min(dist_matrix[1:n_analog]))
  }}
#Step 4: Append cells with calculated climate distances to OUTPUT dataframe file
add <- sample_na
fwrite(add, "OUTPUT_TR_1km_T1T2_slope_dist.csv", append = TRUE, row.names = FALSE, col.names = FALSE, quote = FALSE)

###########################################################
