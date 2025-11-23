#open r5r and other lib
options(java.parameters = "-Xmx16G")
library(tidyverse)
library(sf)
library(data.table)
library(ggplot2)
library(conflicted)
library(dplyr)
library(zeallot)
library(rJava)
library(r5r)
rJava::.jinit()
rJava::.jcall("java.lang.System", "S", "getProperty", "java.version")
path <- "/users/eleves-b/2023/wenrui.dai/Desktop/environment/Helsinki"
r5r_core <- setup_r5(data_path = path)

#read gpkg file (replace the file path)
origins <- st_read("/users/eleves-b/2023/wenrui.dai/Desktop/environment/Helsinki/TD_origins.gpkg")
destinations <- st_read("/users/eleves-b/2023/wenrui.dai/Desktop/environment/Helsinki/TD_destinations.gpkg")

#transport index
mode <- c("WALK", "TRANSIT")             
max_walk_time <- 30                      
max_trip_duration <- 120 

#selecting time
Datestr <- "14-04-2023"
Timestr <- "7:00:00"
departure_datetime_string <- paste(Datestr, Timestr, sep = " ")
departure_datetime <- as.POSIXct(departure_datetime_string, format = "%d-%m-%Y %H:%M:%S")

#set od pairs
origin_df <- origins
dest_df <- destinations

#export (replace the file path)
outFolder <- "/users/eleves-b/2023/wenrui.dai/Desktop/environment/Helsinki"
Batch_num <- 0414
outFile <- paste0(outFolder, "/Helsinki_H3_r5rDI_", Sys.Date(), "_TD_", Batch_num, ".csv")

#main computation
start.time <- Sys.time()
print("Starting Detailed Itineraries calculation using r5r, Now !")
det <- detailed_itineraries(
  r5r_core = r5r_core,
  origins = origin_df,
  destinations = dest_df,
  mode = mode,
  departure_datetime = departure_datetime,
  max_walk_time = max_walk_time,
  max_trip_duration = max_trip_duration,
  shortest_path = TRUE,
  drop_geometry = TRUE,
  time_window = 60,
  all_to_all = FALSE
)

end.time <- Sys.time()
time.taken <- round(end.time - start.time, 2)
print(time.taken)
write.csv(det, outFile, row.names=FALSE)