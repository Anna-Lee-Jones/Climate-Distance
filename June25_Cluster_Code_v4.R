setwd('/data/scratch/mpx585/X_Analyses/D_Jones/B6_code')

library(data.table)
library(foreach)
library(doParallel)
library(dplyr)
library(geosphere)

# Register parallel backend
num_cores <- as.integer(Sys.getenv('NSLOTS', '1'))
cl <- makeCluster(num_cores)
registerDoParallel(cl)

# Read climate dataframe from CSV file (change filepath to where input CSV is stored)
clim_sampled <- fread("climate_input.csv")
colnames(clim_sampled) <- c("cid","x","y","T1_temp","T2_temp","T1_rain","T2_rain")

# Add empty distance column
clim_sampled$distance <- vector("list", nrow(clim_sampled))

# Set climate analogue search radius options
A <- 1
B <- 3
C <- 10

# Identify perfect matches BEFORE parallel execution (done only once)
clim_sampled$distance <- ifelse(clim_sampled$T2_temp == clim_sampled$T1_temp &
                                clim_sampled$T2_rain == clim_sampled$T1_rain, 0, NA)

# Write these perfect matches ONCE ONLY
sample_match <- clim_sampled[clim_sampled$distance == 0, ]
if (nrow(sample_match) > 0) {
  fwrite(sample_match, "OUTPUT_revised.csv", append = FALSE, row.names = FALSE, col.names = TRUE, quote = FALSE)
}

# Rows needing analogue search
sample_na <- clim_sampled[is.na(clim_sampled$distance), ]

# Split the data into chunks for parallel processing
chunk_size <- nrow(sample_na) %/% num_cores
data_chunks <- split(sample_na, ceiling(seq_len(nrow(sample_na)) / chunk_size))

# Parallel analogue search
foreach(i = seq_along(data_chunks), .packages = c("data.table", "dplyr", "geosphere")) %dopar% {
  chunk <- data_chunks[[i]]

  for (n in seq_len(nrow(chunk))) {
    focal <- chunk[n, c("x", "y")]
    found_analogs <- FALSE

    # Search remits A → B → C
    for (radius in c(A, B, C)) {
      remit <- clim_sampled[
        clim_sampled$x < focal$x + radius &
        clim_sampled$x > focal$x - radius &
        clim_sampled$y < focal$y + radius &
        clim_sampled$y > focal$y - radius, ]

      analogs <- remit[
        remit$T2_temp == (chunk[n, T1_temp]) &
        remit$T2_rain >= (chunk[n, T1_rain] - 5) &
        remit$T2_rain <= (chunk[n, T1_rain] + 5), ]

      if (nrow(analogs) > 0 || radius == C) {
        if (nrow(analogs) > 0) {
          dist_matrix <- distGeo(analogs[, c("x", "y")], focal)
          lowest_20 <- round(head(sort(dist_matrix), 20), 0)
          chunk$distance[n] <- list(lowest_20)
        } else {
          chunk$distance[n] <- NA
        }
        found_analogs <- TRUE
        break
      }
    }

    # Simple tracker written to a log file (every 100 iterations)
    if (n %% 100 == 0 || n == nrow(chunk)) {
      cat(sprintf("Chunk %d progress: %d / %d\n", i, n, nrow(chunk)),
          file = paste0("chunk_log_", i, ".txt"), append = TRUE)
    }
  }

  # Write chunk results ONCE PER CHUNK
  if (nrow(chunk) > 0) {
    fwrite(chunk, paste0("OUTPUT_revised_chunk_", i, ".csv"), append = FALSE, row.names = FALSE, col.names = FALSE, quote = FALSE)
  }
}

# Stop parallel processing and close cluster
stopCluster(cl)
