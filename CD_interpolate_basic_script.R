#load libraries
library(data.table)
library(akima)
library(beepr)
#set working directory
setwd("/Users/user/KEW/Cluster_Code")
#load csv of cells with latitude, longitude and climate distance (not temp and rainfall data)
dt<- fread("Climate_Distance_only_KM.csv", header = TRUE, na.strings = c(NA_character_,""))
#remove NA (no analog found), add to plot seperately 
dt<-na.omit(dt)
#bilinear interpolation
start.time <- Sys.time()
val_interpol <- with(dt, akima::interp(X, Y, distance, xo = seq(min(-180), max(180), length =1441),
                                       yo = seq(min(-90), max(90), length =721), duplicate="mean"))
beep(2)
end.time <- Sys.time()
time.taken <- round(end.time - start.time,2)
time.taken

#length is double the number of degrees in each dimension (+1 for 0)
#resolutions: 361 and 181 --> 1 degree (~110km)
#             721 and 361 --> 0.5 degree (~55km)
#             1441 and 721 --> 0.25 degree (~27.5km)
d1 <- expand.grid(x = 1:1441, y = 1:721) #same length as interpolation, positive values only
out <- transform(d1, z = val_interpol$z[as.matrix(d1)])#expand out interpolation Z matrix
out$x <- (out$x-721)/4#transform x and y coordinates back to lat long (-half length/factor of res)
out$y <- (out$y-361)/4
#save the interpolated data frame 
write.csv(out,"10mill_CD_interpolated_degree.csv", row.names = TRUE)


       