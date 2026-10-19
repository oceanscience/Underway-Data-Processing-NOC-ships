# Underway-Data-Processing-NOC-ships
Underway Data Processing for NOC ships RRS James Cook and RRS Discovery using the NMEA data files

update the folder locations in the beginning of the files:

** 1_NOC_ShipTSGData.R:

nc1 <- nc_open("X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/TSG/20261007-000000-SBE45-SBE45.TSG") #note that the 
Output Directory
data_dir <- "C:/codasshared/AtSea/TSG/DY216/Data"
Collate all of them:
tsg_dir <- "X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/TSG"

** 2_NOC_ShipSURFMETData.R
nc2 <- nc_open("X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/SURFMETV3/20261007-000000-Surf-SURFMET.SURFMETv3")
surf_dir <- "X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/SURFMETV3"
Output Directory
data_dir <- "C:/codasshared/AtSea/TSG/DY216/Data"

** 3_NOC_ShipGPSData.R
nc3 <- nc_open("X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/GPS/20261007-000000-position-POSMV_GPS.gps")

gps_dir <- "X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/GPS"

Output Directory
data_dir <- "C:/codasshared/AtSea/TSG/DY216/Data"

** 4_NOC_Join_and_Plot_interp.R

data_dir <- "C:/codasshared/AtSea/TSG/DY216/Data"

** 5_TSGcontourplotall.R

setwd("C:/codasshared/AtSea/TSG/DY216")
hourly_processed_data <- file.path("C:/codasshared/AtSea/TSG/DY216", "Data")

** 6_TSGcompare_ctd_samples.R
setwd("C:/codasshared/AtSea/TSG/DY216")

pathout = "C:/codasshared/AtSea/TSG/DY216/4comparesamples"
pathelog<- "C:/codasshared/AtSea/TSG/DY216/elog"
pathctd <- "C:/codasshared/AtSea/TSG/DY216/ctd"
samples_directory <- "C:/codasshared/AtSea/TSG/DY216/bottle"

** 7_ctd_tsg_joinplot.R
ctdall <- data.frame(read.csv("4comparesamples/CTD_table3.csv", header = TRUE))
tsgall <- data.frame(read.csv("C:/codasshared/AtSea/TSG/DY216/Data/DY216_CollatedUnderwayData.csv", header = TRUE))  

