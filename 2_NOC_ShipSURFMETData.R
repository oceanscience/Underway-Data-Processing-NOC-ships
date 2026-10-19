
library(ncdf4)
library(dplyr)
library(purrr)
library(lubridate)
library(readr)


####################
##### SURFMET ######
####################

# The SURFMET data from the JC290 mission can be found in the following formats:

# netCDF: \\ent.dfo-mpo.ca\ATLShares\Science\BIODataSvc\SRC\2020s\2026\JC290\Ship_Systems\Data\TechSAS\NetCDF\SURFMETV3
# csv: \\ent.dfo-mpo.ca\ATLShares\Science\BIODataSvc\SRC\2020s\2026\JC290\Ship_Systems\Data\TechSAS\NMEA\surfm

# Let's work with the netcdf version.


# Test to look at attributes of first file:
nc2 <- nc_open("X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/SURFMETV3/20261007-000000-Surf-SURFMET.SURFMETv3")
  #"R:/SRC/2020s/2026/JC290/Ship_Systems/Data/TechSAS/NetCDF/SURFMETV3/20260421-213038-Surf-SURFMETv3.SURFMETv3") #Surf has the chl fluorescence, flow rate, and transmissometer
print(nc2)
names(nc2$var)


surf_dir <- "X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/SURFMETV3"
  #"R:/SRC/2020s/2026/JC290/Ship_Systems/Data/TechSAS/NetCDF/SURFMETV3"


# Create function to open files, read in data variables and time, and store in dataframe
surf_files <- list.files(path = surf_dir, pattern = "Surf-SURFMET\\.SURFMETv3$", full.names = TRUE)  

read_surf <- function(file) {
  
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
  fluo  <- ncvar_get(nc, "fluo")
  flow  <- ncvar_get(nc, "flow")
  trans <- ncvar_get(nc, "trans")
  
  tibble(datetime = datetime,
    chl_fluo = as.numeric(fluo),
    transmissometer = as.numeric(trans),
    flow_rate = as.numeric(flow),
    source_file = basename(file))
}

surf_all <- map_dfr(surf_files, read_surf) %>%
  arrange(datetime)



### Checking the netCDF metadata, you can see that the units of fluo and transmissometer data are in Volts. 
# Convert to engineering units:

# Chlorophyll

# Chl (μg/L) = Scale Factor × (Output in Volts − Dark Output or Blank):

# Scale factor of WetStar Chl sensor 1526 is 16.1 μg/L/V. Apply equation:
surf_all$chl_fluo_ug_L <- 16.1 * (surf_all$chl_fluo - 0.061)


# Beam Transmittance:

# Tr = (Vsig - Vdark) / (Vref - Vdark)

# Calibration sheet coefficients:
Vdark = 0.004 #Volts
Vref = 4.699  #Volts
pathlength = 0.25 #metres

surf_all$beam_trans <- (surf_all$transmissometer - Vdark) / (Vref - Vdark)
surf_all$beam_trans_percent <- surf_all$beam_trans * 100


# Beam Attenuation: 

# c = -1/x * ln (Tr)

surf_all$beam_atten <- -(1/pathlength) * log(surf_all$beam_trans)  #log = ln




#### Store surf_all as an RDA file:

data_dir <- "C:/codasshared/AtSea/TSG/DY216/Data"
  #"C:/AZMP/6_REQUESTS/2026/JC290_ShipTSGData/Data" #Create a folder called Data within the data_dir

if(!dir.exists(data_dir)){
  dir.create(data_dir, recursive = TRUE)
}

save(surf_all, file = paste(data_dir, 'surf_all_DY216.rda', sep = '/'))

