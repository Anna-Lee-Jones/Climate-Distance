library(terra)
library(tidyterra)
library(ggplot2)
library(tidyr)
library(dplyr)
library(forcats)

#set working directory
setwd("~/KEW/Cluster_Code")

#import tif of all the outputs from cluster
output_rast<-rast("ALL_OUTPUT.tif")#climate distances
field_size<-rast("~/KEW/Cluster_Code/Global Field Sizes/dominant_field_size_categories.tif")
plot(field_size)
field_size
#where 0= no field size, 1= very large, 2= large, 3= medium, 4=small, 5=very small
#match projections
field_size<-terra::project(x=field_size, y=output_rast, method="near")
#mask output CD rast to cells with field sizes
field_rast<-mask(output_rast, field_size)
field_1<-field_rast
field_2<-field_rast
field_3<-field_rast
field_4<-field_rast
field_5<-field_rast
#for field size 1, set the field sizes very large (1 or 3502) or NA
field_1$field_size <- app(field_size$OID, fun=function(OID){ OID[OID !=3502] <-  NA;return(OID)} )
#mask CD to field size 1 only, 
field_1$ALL_OUTPUT<-mask(output_rast$ALL_OUTPUT, field_1$field_size)
field_1
#for field size 2, set the field sizes to large (2 or 3503) or NA
field_2$field_size <- app(field_size$OID, fun=function(OID){ OID[OID !=3503] <-  NA;return(OID)} )
#mask CD to field size 2 only, 
field_2$ALL_OUTPUT<-mask(output_rast$ALL_OUTPUT, field_2$field_size)
field_2
#for field size 3, set the field sizes to medium (3 or 3504) or NA
field_3$field_size <- app(field_size$OID, fun=function(OID){ OID[OID !=3504] <-  NA;return(OID)} )
#mask CD to field size 1 only, 
field_3$ALL_OUTPUT<-mask(output_rast$ALL_OUTPUT, field_3$field_size)
field_3
#for field size 4, set the field sizes to small (4 or 3505) or NA
field_4$field_size <- app(field_size$OID, fun=function(OID){ OID[OID !=3505] <-  NA;return(OID)} )
#mask CD to field size 4 only, 
field_4$ALL_OUTPUT<-mask(output_rast$ALL_OUTPUT, field_4$field_size)
field_4
#for field size 5, set the field sizes to very small (5 or 3506) or NA
field_5$field_size <- app(field_size$OID, fun=function(OID){ OID[OID !=3506] <-  NA;return(OID)} )
#mask CD to field size 1 only, 
field_5$ALL_OUTPUT<-mask(output_rast$ALL_OUTPUT, field_5$field_size)
field_5

#stack field size climate distance rasters
field_size_stack<-rast()
field_size_stack$vlarge<-field_1
field_size_stack$large<-field_2
field_size_stack$medium<-field_3
field_size_stack$small<-field_4
field_size_stack$vsmall<-field_5
writeRaster(field_size_stack,"field_size_stack.tif")
field_size_stack
#SKIP TO HERE ONCE NEW TIF MADE 
field_size_stack<-rast("field_size_stack.tif")
global(field_size_stack, c("sum", "mean", "sd","notNA"), na.rm=TRUE)
#convert to csv on david's laptop

#boxplot for average climate distance per field size category
x <- boxplot(field_size_stack)
str(x)
D<-density(field_size_stack, plot=TRUE)
barplot(field_size_stack)
hist(field_size_stack)
library(tidyterra)
library(ggplot2)

# A faceted SpatRaster

ggplot() +
  geom_spatraster(data = field_size_stack) +
  facet_wrap(~lyr) +
  scale_fill_whitebox_c(
    palette = "muted",
    na.value = "white"
  )
ggplot(field_size_stack)
#stats on stack
global(field_size_stack, c("sum", "mean", "sd","notNA"), na.rm=TRUE)

#from David's laptop, csv analysis SKIP HERE

df_vlarge<-read.csv("/Users/user/KEW/Cluster_Code/field_vlarge.csv")
df_vlarge<-drop_na(as.data.frame(df_vlarge))
colnames(df_vlarge)<-c("CID","Climate_Distance","Field_Size")

df_large<-read.csv("/Users/user/KEW/Cluster_Code/field_large.csv")
df_large<-drop_na(as.data.frame(df_large))
colnames(df_large)<-c("CID","Climate_Distance","Field_Size")

df_medium<-read.csv("/Users/user/KEW/Cluster_Code/field_medium.csv")
df_medium<-drop_na(as.data.frame(df_medium))
colnames(df_medium)<-c("CID","Climate_Distance","Field_Size")

df_small<-read.csv("/Users/user/KEW/Cluster_Code/field_small.csv")
df_small<-drop_na(as.data.frame(df_small))
colnames(df_small)<-c("CID","Climate_Distance","Field_Size")

df_vsmall<-read.csv("/Users/user/KEW/Cluster_Code/field_vsmall.csv")
df_vsmall<-drop_na(as.data.frame(df_vsmall))
colnames(df_vsmall)<-c("CID","Climate_Distance","Field_Size")

df_all<-rbind(df_vlarge,df_large,df_medium,df_small,df_vsmall)
factor(df_all$Field_Size, levels = c("vlarge","large","medium","small","vsmall"))

# Basic violin plot
p <- ggplot(df_all, aes(x=fct_inorder(Field_Size), y=log(Climate_Distance))) + 
  geom_density()
p

#stats: 