#load packages
library(terra)
library(ggplot2)
library(ggpubr)
library(moranfast)
library(plyr)
library(dplyr)
library(forcats)
library(scales)

#set working directory
setwd("/Volumes/Kew Back Up 1/KEW/Cluster_Code/March_25_Run/June_Output/Processing")

#CROPLAND VS NON CROPLAND 
cropland_df<-read.csv("AGRO.csv")
cropland_df$Land_Type<-"Cropland"
colnames(cropland_df)<-c("X","Y","Climate_Distance","Land_Type")
noncropland_df<-read.csv("NONAGRO.csv")
noncropland_df$Land_Type<-"Non Cropland"
colnames(noncropland_df)<-c("X","Y","Climate_Distance","Land_Type")
#to deal with sample size difference
noncropland_df<-noncropland_df[sample(nrow(noncropland_df),503046),]
