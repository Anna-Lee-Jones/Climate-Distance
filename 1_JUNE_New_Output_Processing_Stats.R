# Load libraries
library(data.table)
library(dplyr)

# Set working directory
setwd("/Volumes/Kew Back Up 1/KEW/Cluster_Code/March_25_Run/June_Output/Processing")

# Get a list of all .csv files starting with "OUTPUT"
files <- list.files(pattern = "^OUTPUT.*\\.csv$")

# Read in the first output csv
output <- fread(files[1])

# Select only the "x", "y", and "distance" columns
output <- output %>% select(x, y, distance)

# Replace blank rows in "distance" column with NA
#output$distance <- ifelse(output$distance == "", NA, output$distance)

# Split "distance" column into a list of numeric values
output$distance <- strsplit(as.character(output$distance), "\\|") # Split by "|"
output$distance <- lapply(output$distance, function(x) as.numeric(trimws(x))) # Convert to numeric, trim whitespace
# Convert distances from metres to KM
output$distance <- lapply(output$distance, function(x) x / 1000)

# Create new columns for statistics
output$num_distances <- sapply(output$distance, function(x) sum(!is.na(x))) # Total count of distances per row
output$min_distance <- sapply(output$distance, function(x) min(x, na.rm = TRUE)) # min per row
output$min_distance[is.infinite(output$min_distance)] <- NA
output$median_distance <- sapply(output$distance, function(x) median(x, na.rm = TRUE)) # Median per row
output$mean_distance <- sapply(output$distance, function(x) mean(x, na.rm = TRUE)) # Mean per row
output$std_dev_distance <- sapply(output$distance, function(x) sd(x, na.rm = TRUE)) # Standard deviation per row
output$coeff_var_distance <- output$std_dev_distance / output$mean_distance # Coefficient of variation per row

# View the result
head(output)

#save processed output file
fwrite(output, "Processed_Output.csv")

# Read the processed output and extract selected columns
processed_subset <- fread("Processed_Output.csv") %>%
  select(x, y, min_distance, num_distances)

#set missing climate distances (no analog found) to NA
processed_subset$min_distance[processed_subset$num_distances == 0] <- NA

# Filter rows with any NA values
na_rows <- processed_subset %>% filter(if_any(everything(), is.na))
# Print them
print(na_rows)
#150k cells with no analog found.


# View the subset
head(processed_subset)

# save the subset to a new file
fwrite(processed_subset, "Processed_Output_minCD_numanalog.csv")
