##4TSGcompare_ctd_samples.R

#**NOTE  processed TSGdata files can not start with a time of 00:00:00

#***Desciption: Script to read processed and bottle (Chl, Oxy, Salts) data from underway system and read CTD and ELOG files
# to match the sample, CTD and TSG data creating tables and plots.  

#***INPUT: 
# 1- pathelog - directory of ELOG .log Flow-Through files 
# 2- pathbottle - directory of analysed Sample data taken from the TSG
# file names start with the variable type:     
    # - 'Oxy.*\\.csv  (convert .dat file to csv, 8 header lines)
    # - 'Chl.*\\.xlsx' (excel, 18 header lines)
    # - 'Salts.*\\.csv' (csv, 4 header lines)
#Note: salts data is generated as 1 files per run these need to be compiled into 1 file, use the file 
#with 1 calculated value per sample ID and not the multiple readings per run or multiple run values
# and a 4 line header is added: 
#   ShipsName=Teleost
#   CruiseNumber=TEL2024880
#   Analyst=Diana Cardoso
#   SalinometerSerialNumber=71418
  
# 3- pathctd - directory of CTD processed ODF files 
# 4- pathprocessed - directory of TSG processed files
# 5- CTDpres - CTD pressure for comparison with TSG intake depth, typically between 4 - 8 m

# OUTPUT is in the \4comparesamples folder and includes:
#read_elog_tsg3.R
# - Bottle_TSG_QAT.csv - table: TSG data average of a minute (12 values) matched with sample data 
# - TSG_bottletable2.csv - table: TSG data when the sample was taken, 12 readings for the minute time of sample 
# - TSG_samples.csv -  table: time, date, lat, lon, ID of each sample taken from TSG
# - chl2tsgplot.jpeg, oxy2tsgplot.jpeg, salt2sgplot.jpeg - plots of TSG vs sample data
# tsg_ctd.R
# - CTD_table3.csv-  table:CTD data at a certain depth near surface per event with time and position 

#**Folder structure:
#C:\TSG_process - working dir
#\1code_readTSGdata - dir for script "1readTSGdata.R" to read all log files and process
#\2code_interp_plot_TSGdata - interpolate the processed data over time
#\3code_plot_TSGdata - plot the interpolated data
#\4comparesamples -  compare TSG water samples with TSG data and compare CTD and TSG data
#\processed - formatted log files from TSG with corrupted data removed
#\raw - log files from TSG
#\bottle - water sample data from the TSG analysed on the ship typically salts, Chlorophyll and oxygen 
#\ctd- ctd files in ODF format processed on the ship
#\elog - TSG log files from ELOG


#** FUNCTIONS:

# read_elog_tsg4.R - read elog and processed tsg files, match the samples to the TSG data and create tables and plots
# tsg_ctd.R - read ctd ODF data and match to TSG data and create a table 

# author Diana Cardoso
# Oct 2021
# Fisheries and Oceans Canada,Bedford Institute of Oceanography, Dartmouth, N.S. Canada B2Y 4A2

rm(list=ls()) #remove everything in the working environment.

#Install and load specific package versions
#install.packages("stringr", "lubridate","readxl", "readr", oce")
library(stringr)
library(lubridate)
library(readxl)
library(readr)
library(oce)

#CTD pressure for comparison with TSG intake depth, typically between 4 - 8 m
CTDpres <- 7

# this is the directory where R expects to find the local code
setwd("C:/codasshared/AtSea/TSG/DY216")

pathout = "C:/codasshared/AtSea/TSG/DY216/4comparesamples"
pathelog<- "C:/codasshared/AtSea/TSG/DY216/elog"
pathctd <- "C:/codasshared/AtSea/TSG/DY216/ctd"
samples_directory <- "C:/codasshared/AtSea/TSG/DY216/bottle"

#List of Functions
source("4comparesamples/read_elog_tsg4.R")
source("4comparesamples/tsg_ctd.R")

# read and process data
read.elog_tsg(pathout, pathelog, samples_directory)
read.tsg_ctd(pathctd, CTDpres)

# Record session information
sink("session_info.txt")
sessionInfo()
sink()

output_dir <-pathout
pathrawdata <- pathelog
pathbottle <- samples_directory
