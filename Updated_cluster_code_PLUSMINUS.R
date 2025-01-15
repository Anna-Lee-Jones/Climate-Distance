setwd("~/KEW/Cluster_Code")

library(data.table)
library(foreach)
library(doParallel)
library(dplyr)
library(geosphere)

# Register parallel backend
num_cores <- detectCores() # GF Note: You can do this... 
#cl <- makeCluster(num_cores)
cl <- makeCluster(6) ## ...or assign the number of requested cores directly
registerDoParallel(cl)

# Read climate dataframe from CSV file (change filepath to where input CSV is stored)
clim_sampled <- fread("climate_input_rounded02.csv")
colnames(clim_sampled) <- c("cid","x","y","T1_temp","T2_temp","T1_rain","T2_rain")

#add empty distance column to for ouputs
clim_sampled$distance <- list()

# Split the data into chunks
chunk_size <- nrow(clim_sampled) %/% num_cores#AJ: can set chunk size to 10000 if it makes more sense?
data_chunks <- split(clim_sampled, ceiling(seq_along(clim_sampled$cid) / chunk_size))

# Preallocate memory for sample and sample_na
# GF Note: Initiating these may not be needed
sample <- data.frame()
sample_na <- data.frame()

#set climate analogue search radius options
A <- 0.5
B <- 1
C <- 100 #AJ increased max search remit to +-100 deg, now we are looking for more precise matches 

#write blank csv with correct col names to be populated with results
blank <- data_chunks[[1]]
blank <- blank[0,]
fwrite(blank, "OUTPUT_PLUSMINUS.csv", append = FALSE, row.names = FALSE, col.names = T, quote = FALSE)

# GF Note: To perform parallel computation, you need to iterate over chunks in the loop, not over cores,
# that's %dopar% work.I've done some editing here. I also added safeguards to prevent problems
# if empty lines are produced.Also, necessary packages can be loaded in the arguments of the loop.

#AJ note: need geosphere package in here to calculate Haversine distances (earth ≠ flat)
foreach(chunk = data_chunks, .packages = c("data.table", "dplyr", "geosphere")) %dopar% {
  
  # Step 1: Find cells with no change in temp or rain (within +-5mm)
  chunk$distance <- ifelse((chunk$T2_temp >= (chunk$T1_temp) &
                              chunk$T2_temp<=(chunk$T1_temp+0.5) &
                              chunk$T2_rain >= (chunk$T1_rain-5)&
                              chunk$T2_rain <= (chunk$T1_rain)), 0, NA)
  # Subset those which are not zero (NAs), ready to find distances
  sample_match <- chunk[chunk$distance == 0, ]
  sample_na <- chunk[is.na(chunk$distance), ]
  
  # Add 'zero distance' cells to the full dataframe file
  if (nrow(sample_match) > 0) {
    fwrite(sample_match, "OUTPUT_PLUSMINUS.csv", append = TRUE, row.names = FALSE, col.names = FALSE, quote = FALSE)
  }  
  
  # Step 2: Find cells within the first search remit (relative to focal cell n)
  for (n in seq_len(nrow(sample_na))) {
    
    focal <- sample_na[n, c("x", "y")]
    
    remit <- clim_sampled[clim_sampled$x < focal$x + A &
                            clim_sampled$x > focal$x - A &
                            clim_sampled$y < focal$y + A &
                            clim_sampled$y > focal$y - A, ]
    
    # Find which cells within the remit are analogs at T2 to cell(n) at T1 in temp and rainfall +-5mm
    analogs <- remit[remit$T2_temp >= (sample_na[n,T1_temp])&
                       remit$T2_temp <= (sample_na[n,T1_temp+0.5])&
                       remit$T2_rain >= (sample_na[n,T1_rain-5])&
                       remit$T2_rain <= (sample_na[n,T1_rain])]
    
    # If no analogs found, search the second remit
    if(nrow(analogs) == 0) {
      
      remit <- clim_sampled[clim_sampled$x < focal$x + B &
                              clim_sampled$x > focal$x - B &
                              clim_sampled$y < focal$y + B &
                              clim_sampled$y > focal$y - B, ]
      
      analogs <- remit[remit$T2_temp >= (sample_na[n,T1_temp])&
                         remit$T2_temp <= (sample_na[n,T1_temp+0.5])&
                         remit$T2_rain >= (sample_na[n,T1_rain-5])&
                         remit$T2_rain <= (sample_na[n,T1_rain])]
      
      # If no analogs found, search the third remit
      # GF Note: searching through remits could be done iteratively 
      if(nrow(analogs) == 0) {
        
        remit <- clim_sampled[clim_sampled$x < focal$x + C &
                                clim_sampled$x > focal$x - C &
                                clim_sampled$y < focal$y + C &
                                clim_sampled$y > focal$y - C, ]
        
        analogs <- remit[remit$T2_temp >= (sample_na[n,T1_temp])&
                           remit$T2_temp <= (sample_na[n,T1_temp+0.5])&
                           remit$T2_rain >= (sample_na[n,T1_rain-5])&
                           remit$T2_rain <= (sample_na[n,T1_rain])]
        
        # If still no analogs found, give climate distance NA
        if(nrow(analogs) == 0){
          
          sample_na$distance[n] <- NA
          
          # Where analogs were found, calculate the distance from cell(n) to each analog then record shortest distance as dist
          
        } else {
          
          n_analog <- nrow(analogs)
          dist_matrix <- distGeo(analogs[, c("x", "y")], focal)#AJ: must be distGeo for Haversine distance!
          sample_na$distance[n] <- (min(dist_matrix[1:n_analog]))
          
        }
      } else {
        
        n_analog <- nrow(analogs)
        dist_matrix <- distGeo(analogs[, c("x", "y")], focal)#AJ: must be distGeo for Haversine distance!
        sample_na$distance[n] <- (min(dist_matrix[1:n_analog]))
        
      }
    } else {
      
      n_analog <- nrow(analogs)
      dist_matrix <- distGeo(analogs[, c("x", "y")], focal)#AJ: must be distGeo for Haversine distance!
      sample_na$distance[n] <- (min(dist_matrix[1:n_analog]))
      
    }
  } 
  
  #add climate distances to result dataframe 
  if (nrow(sample_na) > 0) {
    fwrite(sample_na, "OUTPUT_PLUSMINUS.csv", append = TRUE, row.names = FALSE, col.names = FALSE, quote = FALSE)
  }
}

# Stop parallel processing and close cluster
stopCluster(cl)
