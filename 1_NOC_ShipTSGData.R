
library(ncdf4)
library(dplyr)
library(purrr)
library(lubridate)
library(readr)


################
##### TSG ######
################

# The TSG data from the DY216 mission can be found in the following formats:

# netCDF: \\ent.dfo-mpo.ca\ATLShares\Science\BIODataSvc\SRC\2020s\2026\DY216\Ship_Systems\Data_acquisition_systems\TechSAS\NetCDF\TSG
# csv: \\ent.dfo-mpo.ca\ATLShares\Science\BIODataSvc\SRC\2020s\2026\DY216\Ship_Systems\Data_acquisition_systems\TechSAS\NMEA\sbe45

# Let's work with the netcdf version.


# Test to look at attributes of first file:
nc1 <- nc_open("X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/TSG/20261007-000000-SBE45-SBE45.TSG") #note that the size for the time field is 0.
               #R:/SRC/2020s/2026/JC290/Ship_Systems/Data/TechSAS/NetCDF/TSG/20260421-213038-SBE45-SBE45.TSG") #note that the size for the time field is 0.
print(nc1)
names(nc1$var)

# Output Directory
data_dir <- "C:/codasshared/AtSea/TSG/DY216/Data"

# Collate all of them:
tsg_dir <- "X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/TSG"
  #"R:/SRC/2020s/2026/JC290/Ship_Systems/Data/TechSAS/NetCDF/TSG"


# Read in TSG files, which are netCDF files:
tsg_files <- list.files(path = tsg_dir, pattern = "\\.TSG$", full.names = TRUE)


# Create function to open files, read in data variables and time, and store in a dataframe
read_tsg <- function(file) {
  
  nc <- nc_open(file)
  on.exit(nc_close(nc))
  
  # Time is stored as a dimension in these files
  time_raw <- ncvar_get(nc, "time")
  time_units <- ncatt_get(nc, "time", "units")$value
  
  
  # Time = "days since 1899-12-30 00:00:00 UTC"
  time_origin <- sub(".*since ", "", time_units)
  time_origin <- sub(" UTC", "", time_origin)
  
  datetime <- as.POSIXct(time_raw * 86400, origin = time_origin, tz = "UTC")
  
  # Extract variables of interest and collate into data table:
  salin  <- ncvar_get(nc, "salin")
  temp_r  <- ncvar_get(nc, "temp_r")
  temp_h <- ncvar_get(nc, "temp_h")
  cond <- ncvar_get(nc, "cond")
  
  tibble(datetime = datetime,
         temp_SBE45 = as.numeric(temp_h),
         salinity = as.numeric(salin),
         temp_remote = as.numeric(temp_r),
         conductivity = as.numeric(cond),
         source_file = basename(file))
}

tsg_all <- map_dfr(tsg_files, read_tsg) %>%
  arrange(datetime)


# No time values were found in the following files:

# 20260421-213038-SBE45-SBE45.TSG
# 20260422-000000-SBE45-SBE45.TSG

# So these were skipped. The size is 4 KB, so I don't think these are valid files.



#### Store tsg_all as an RDA file:

#data_dir <- "C:/codasshared/AtSea/TSG/DY216/Data"
#C:/AZMP/6_REQUESTS/2026/JC290_ShipTSGData/Data" #Create a folder called Data within the data_dir

if(!dir.exists(data_dir)){
  dir.create(data_dir, recursive = TRUE)
}

save(tsg_all, file = paste(data_dir, 'tsg_all_DY216.rda', sep = '/'))


