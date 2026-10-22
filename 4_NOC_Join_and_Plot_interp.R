# Read in RRS James Cook TSG and NMEA data (netCDF files) from DY216

library(ncdf4)
library(dplyr)
library(purrr)
library(lubridate)
library(readr)
library(oce)
library(ocedata)


########################
##### JOIN & PLOT ######
########################

# Load RDA data:

data_dir <- "C:/codasshared/AtSea/TSG/DY216/Data"
  #"C:/AZMP/6_REQUESTS/2026/JC290_ShipTSGData/Data"

load(paste(data_dir, 'tsg_all_DY216.rda', sep = '/'))
load(paste(data_dir, 'surf_all_DY216.rda', sep = '/'))
load(paste(data_dir, 'gps_all_DY216.rda', sep = '/'))


nrow(tsg_all) 
nrow(surf_all) 
nrow(gps_all) 


# Check for duplicates in date_time field: 
tsg_all[duplicated(tsg_all$datetime), ]    
surf_all[duplicated(surf_all$datetime), ] 
gps_all[duplicated(gps_all$datetime), ]  


# Prepare data to join. Take average of variables in tsg_all, and select first source file of duplicate record:
tsg_all2 <- tsg_all %>%
  group_by(datetime) %>%
  dplyr::summarise(temp_SBE45 = mean(temp_SBE45, na.rm = TRUE), salinity = mean(salinity, na.rm = TRUE), 
                   temp_remote = mean(temp_remote, na.rm = TRUE), conductivity = mean(conductivity, na.rm = TRUE),
                   source_file = first(source_file), .groups = "drop")

nrow(tsg_all2) 

# Now join all 3 datasets:
tsg_surf_gps <- tsg_all2 %>%
  left_join(surf_all, by = "datetime") %>%
  left_join(gps_all, by = "datetime")

# surf and gps fields did not join to tsg data. Why?


# Investigate whether datetime fields have fractional seconds:
head(format(tsg_all2$datetime, "%Y-%m-%d %H:%M:%OS6"))
head(format(surf_all$datetime, "%Y-%m-%d %H:%M:%OS6"))
head(format(gps_all$datetime, "%Y-%m-%d %H:%M:%OS6"))


# All have fractional seconds, like 2026-04-22 12:18:05.984063. Round up to 2 digits for seconds. Since rounding up
# likely creates duplicates in the time field, take the average of the data variables for each unique time, while
# dropping the source_file field:

tsg_join <- tsg_all %>% #go back to original tsg_all, since the duplicate record above will be taken care of here:
  mutate(datetime = ymd_hms(datetime, tz = "UTC"), datetime_join = floor_date(datetime, "second")) %>%
  group_by(datetime_join) %>%
  dplyr::summarise(temp_SBE45 = mean(temp_SBE45, na.rm = TRUE), salinity = mean(salinity, na.rm = TRUE), 
                   temp_remote = mean(temp_remote, na.rm = TRUE), conductivity = mean(conductivity, na.rm = TRUE),
                   .groups = "drop")

surf_join <- surf_all %>%
  mutate(datetime = ymd_hms(datetime, tz = "UTC"), datetime_join = floor_date(datetime, "second")) %>%
  group_by(datetime_join) %>%
  dplyr::summarise(chl_fluo_V = mean(chl_fluo, na.rm = TRUE), chl_fluo_ug_L = mean(chl_fluo_ug_L, na.rm = TRUE),
                   transmiss_V = mean(transmissometer, na.rm = TRUE), beam_trans = mean(beam_trans, na.rm = TRUE),
                   beam_trans_percent = mean(beam_trans_percent, na.rm=TRUE), 
                   beam_atten = mean(beam_atten, na.rm = TRUE), flow_rate = mean(flow_rate, na.rm = TRUE), .groups = "drop")
                    
gps_join <- gps_all %>%
  mutate(datetime = ymd_hms(datetime, tz = "UTC"), datetime_join = floor_date(datetime, "second")) %>%
  group_by(datetime_join) %>%
  dplyr::summarise(lat = mean(lat, na.rm = TRUE), long = mean(long, na.rm = TRUE), 
                   gndspeed = mean(gndspeed, na.rm = TRUE), .groups = "drop")



##Then try join again. tsg data has lowest number of records, so we want this to be our anchor in the join:
tsg_surf_gps <- tsg_join %>%
  left_join(surf_join, by = "datetime_join") %>%
  left_join(gps_join, by = "datetime_join")

nrow(tsg_surf_gps)

# Export:
write.csv(tsg_surf_gps, file=file.path(data_dir, "DY216_CollatedUnderwayData.csv"), row.names=F)

#hourly interp the data
# check when flowrate is 0 and remove those rows from the tsg_surf_gps dataframe, since these are likely when the ship is in port and not underway:
tsg_surf_gps <- tsg_surf_gps[tsg_surf_gps$flow_rate > 0, ]
tsg_surf_gps=tsg_surf_gps[complete.cases(tsg_surf_gps),]

start_date <- tsg_surf_gps$datetime_join
end_date <- tsg_surf_gps$datetime_join[length(tsg_surf_gps$datetime_join)]

# vector of time by hour between start and end time determined above
hourrate <- seq(from = as.POSIXct(start_date,tz = 'UTC'), to = as.POSIXct(end_date,tz = 'UTC'), by = "hour")

colnames_tsg_surf_gps <- colnames(tsg_surf_gps)

interhourly <- approx(tsg_surf_gps$datetime_join,tsg_surf_gps[[colnames_tsg_surf_gps[2]]], xout=hourrate, method = "linear", na.rm = TRUE ) 
TSG_hour <- data.frame(interhourly[["x"]],interhourly[["y"]])
colnames(TSG_hour) <- c("datetime",colnames_tsg_surf_gps[2])
interhourly2 <- TSG_hour

for(i in 3:(length(colnames_tsg_surf_gps)-4)){
  interhourly <- approx(tsg_surf_gps$datetime_join,tsg_surf_gps[[colnames_tsg_surf_gps[i]]], xout=hourrate, method = "linear", na.rm = TRUE ) 
  TSG_hour <- data.frame(interhourly[["x"]],interhourly[["y"]])
  colnames(TSG_hour) <- c("datetime",colnames_tsg_surf_gps[i])
  #append a column to the interhourly2 dataframe for each variable
  interhourly2[[colnames_tsg_surf_gps[i]]] <- TSG_hour[[colnames_tsg_surf_gps[i]]] #  X['y'] = y.values
}

# add the last 4 columns (source_file, lat, long, gndspeed) to the interhourly2 dataframe
interhourly2$flow_rate <- tsg_surf_gps$flow_rate[match(interhourly2$datetime, tsg_surf_gps$datetime_join)]
interhourly2$lat <- tsg_surf_gps$lat[match(interhourly2$datetime, tsg_surf_gps$datetime_join)]
interhourly2$long <- tsg_surf_gps$long[match(interhourly2$datetime, tsg_surf_gps$datetime_join)]
interhourly2$gndspeed <- tsg_surf_gps$gndspeed[match(interhourly2$datetime, tsg_surf_gps$datetime_join)]

write.csv(interhourly2, file=file.path(data_dir, "DY216_CollatedUnderwayData_hourly.csv"), row.names=F)

### Plot the data time series:
#tsg_surf_gps <- read.csv(paste0(data_dir, "/DY216_CollatedUnderwayData.csv"))
conductivity <- "conductivity"
fluorescence <- "chl_fluo_ug_L"
temperature <- 'temp_SBE45'
salinity <- 'salinity'
temperatureSBE38 <- 'temp_remote'
flow_rate <- 'flow_rate'

variables <- c(conductivity, temperatureSBE38, temperature,
               fluorescence, salinity, flow_rate) #'PCO2 , pH, 

for (var in variables){
jpeg(paste0(data_dir,"/TSG_",var,"timeall2.jpeg"), width = 1150, height = 750)
x <- as.POSIXct(tsg_surf_gps$datetime_join, tz = 'UTC', format = "%Y-%m-%d %H:%M:%S")  
plot(x,tsg_surf_gps[[var]],  
     main= paste0("TSG ", var, " hourly"), ylab=var,xlab="Date time ",xaxt="n") #98164 is first row with flow rate [98164:length(x)]
axis.POSIXct(1, at = seq(as.POSIXct(tsg_surf_gps$datetime_join[98164], tz = 'UTC'),as.POSIXct(tsg_surf_gps$datetime_join[length(tsg_surf_gps$datetime_join)],tz = 'UTC'),by="min"), format = "%d-%H", las=2)
dev.off()
}


# 
# #Temperature:
# 
# # Variable to colour by
# z <- tsg_surf_gps$temp_SBE45   # change this to trans, temp, chlorophyll, etc.
# 
# # Make colour ramp
# n_col <- 100
# cols <- colorRampPalette(c("blue", "cyan", "yellow", "red"))(n_col)
# 
# # Convert z values to colour bins
# z_bin <- cut(z, breaks = seq(min(z, na.rm = TRUE), max(z, na.rm = TRUE),
#                length.out = n_col + 1), include.lowest = TRUE, labels = FALSE)
# 
# # Assign colours to each point
# point_cols <- cols[z_bin]
# 
# # Plot map
# mapPlot(coastlineWorldFine, 
#         projection = "+proj=merc",
#         col = "lightgray", 
#         longitudelim = lonlim, 
#         latitudelim = latlim, 
#         lonlabels = TRUE, 
#         latlabels = TRUE)
# 
# # Plot colour-coded points
# mapPoints(longitude = tsg_surf_gps$long,
#           latitude = tsg_surf_gps$lat, 
#           pch = 20,
#           cex = 0.2,
#           col = point_cols)
# 
# # Add colour scale
# drawPalette(zlim = range(z, na.rm = TRUE), col = cols, zlab = "Temperature")
# 

