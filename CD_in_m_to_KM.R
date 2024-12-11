#load libraries
library(data.table)
library(dplyr)
#set working directory
setwd("~/OneDrive - Nexus365/Cluster_Code")
output<-fread("NEW_OUTPUT_climatedist.csv")
output$distance<-output$distance/1000
fwrite(output, "KM_NEW_OUTPUT_climatedist.csv", append = FALSE, row.names = FALSE, col.names = FALSE, quote = FALSE)
dist_only<-output[,c("X","Y","distance")]  # returns a data.frame
fwrite(dist_only, "Climate_Distance_only_KM.csv")
