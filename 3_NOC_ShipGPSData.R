
library(ncdf4)
library(dplyr)
library(purrr)
library(lubridate)
library(readr)


################
##### GPS ######
################

# The James Cook's primary GNSS positioning system and the NOC recommends to use is posMV. The posMV files can be 
# found in the two following formats:

# netCDF: \\ent.dfo-mpo.ca\ATLShares\Science\BIODataSvc\SRC\2020s\2026\JC290\Ship_Systems\Data\TechSAS\NetCDF\GPS
# csv: \\ent.dfo-mpo.ca\ATLShares\Science\BIODataSvc\SRC\2020s\2026\JC290\Ship_Systems\Data\TechSAS\NMEA\mvpos

# The netCDF file naming convention you want to pull is 20260421-213038-position-POSMV_GPS.
# Let's work with the netcdf version.


# Test to look at attributes of first file:
nc3 <- nc_open("X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/GPS/20261007-000000-position-POSMV_GPS.gps")
               #"R:/SRC/2020s/2026/JC290/Ship_Systems/Data/TechSAS/NetCDF/GPS/20260421-213038-position-POSMV_GPS.gps") 
print(nc3)
names(nc3$var)


gps_dir <- "X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/GPS"
  #"R:/SRC/2020s/2026/JC290/Ship_Systems/Data/TechSAS/NetCDF/GPS"

# Read in GPS files, which are ASCII CSV-style text, not netCDF files:
gps_files <- list.files(path = gps_dir, pattern = "position-POSMV_GPS.gps$", full.names = TRUE, ignore.case = TRUE)


# Create function to open files, read in data variables and time, and store in dataframe
read_gps <- function(file) {
  
  nc <- nc_open(file)
  on.exit(nc_close(nc))
  
  # Time is stored as a dimension in these files
  time_raw <- ncvar_get(nc, "time")
  time_units <- ncatt_get(nc, "time", "units")$value
  
  # "days since 1899-12-30 00:00:00 UTC"
  time_origin <- sub(".*since ", "", time_units)
  time_origin <- sub(" UTC", "", time_origin)
  
  datetime <- as.POSIXct(time_raw * 86400, origin = time_origin, tz = "UTC")
  
  # Extract variables of interest and collate into data table:
  lat  <- ncvar_get(nc, "lat")
  long  <- ncvar_get(nc, "long")
  gndspeed <- ncvar_get(nc, "gndspeed")
  
  tibble(datetime = datetime,
         lat = as.numeric(lat),
         long = as.numeric(long),
         gndspeed = as.numeric(gndspeed),
         source_file = basename(file))
}

gps_all <- map_dfr(gps_files, read_gps) %>%
  arrange(datetime)



#### Store gps_all as an RDA file:

data_dir <- "C:/codasshared/AtSea/TSG/DY216/Data"
  #"C:/AZMP/6_REQUESTS/2026/JC290_ShipTSGData/Data" #Create a folder called Data within the data_dir

if(!dir.exists(data_dir)){
  dir.create(data_dir, recursive = TRUE)
}

save(gps_all, file = paste(data_dir, 'gps_all_DY216.rda', sep = '/'))


