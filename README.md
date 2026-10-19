# Underway-Data-Processing-NOC-ships
Underway Data Processing for NOC ships RRS James Cook and RRS Discovery using the NMEA data files

update the folder locations in the beginning of the files:

** 1_NOC_ShipTSGData.R:
* nc1 <- nc_open("X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/TSG/20261007-000000-SBE45-SBE45.TSG") #note that the 
* data_dir <- "C:/codasshared/AtSea/TSG/DY216/Data"
* tsg_dir <- "X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/TSG"

** 2_NOC_ShipSURFMETData.R
* nc2 <- nc_open("X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/SURFMETV3/20261007-000000-Surf-SURFMET.SURFMETv3")
* surf_dir <- "X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/SURFMETV3"
* data_dir <- "C:/codasshared/AtSea/TSG/DY216/Data"

** 3_NOC_ShipGPSData.R
* nc3 <- nc_open("X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/GPS/20261007-000000-position-POSMV_GPS.gps")
* gps_dir <- "X:/Ship_Systems/Data_acquisition_systems/TechSAS/NetCDF/GPS"
* data_dir <- "C:/codasshared/AtSea/TSG/DY216/Data"

** 4_NOC_Join_and_Plot_interp.R
* data_dir <- "C:/codasshared/AtSea/TSG/DY216/Data"

** 5_TSGcontourplotall.R

* setwd("C:/codasshared/AtSea/TSG/DY216")
* hourly_processed_data <- file.path("C:/codasshared/AtSea/TSG/DY216", "Data")

** 6_TSGcompare_ctd_samples.R
* setwd("C:/codasshared/AtSea/TSG/DY216")
* pathout = "C:/codasshared/AtSea/TSG/DY216/4comparesamples"
* pathelog<- "C:/codasshared/AtSea/TSG/DY216/elog"
* pathctd <- "C:/codasshared/AtSea/TSG/DY216/ctd"
* samples_directory <- "C:/codasshared/AtSea/TSG/DY216/bottle"

** 7_ctd_tsg_joinplot.R
* ctdall <- data.frame(read.csv("4comparesamples/CTD_table3.csv", header = TRUE))
* tsgall <- data.frame(read.csv("C:/codasshared/AtSea/TSG/DY216/Data/DY216_CollatedUnderwayData.csv", header = TRUE))  

Input Data:

* Copy the elog files for TSG sampling into the elog folder
* Copy the oxy, salts, Chl bottle data into the bottle folder
* Copy the ODF ctd downward data into the ctd folder
* Copy the TSG data csv logs into the Raw folder
* delete the first lines of the TSG file when the flow rate was zero, also the TSG water can be turned off for cleaning, maintenance or while in port, but logging continues confirm in ELOG or other logs when there is a data spike or missing data.

Bottle data: In read_elog_tsg3.R edit the number of lines to skip in the header of each file and the pattern to search for files

oxygen:
• save the oxy file as csv, delete a bunch of sample data that is not from the TSG for the script to run faster. • The calibration coefficients may have changed ask OETS for the coefficients and place them in the code TSG_optode_SatO2_4.R. This was never done in the past so you have to go back and rerun the code with the correct coefficients for each mission.

salts: • concatenate the salts data into on csv files, delete a bunch of sample data that is not from the TSG for the script to run faster.

chlorophyl:
• concatenate the chl into one xls file, delete a bunch of sample data that is not from the TSG for the script to run faster. • Chl data has 2 sheets in the excel file delete the first sheet “”rawValues” • Remove the _1a, _1, _2 and _2a from the sample IDs • Remove the sample IDs that have no Chl and Phaeo values ie the sample ID with “a”
