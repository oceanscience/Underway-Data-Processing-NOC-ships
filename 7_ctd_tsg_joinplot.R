#read table created by function tsg_ctd.R and 
#read the file created by 4_xxxx_Join_and_Plot_interp.R "xxxxxx_CollatedUnderwayData.csv" in the \Data folder 
#and join the two tables by time rounded to the minute and plot the TSG vs CTD data per variable per event


#***INPUT:
#** The CTD_table3.csv file created by the function tsg_ctd.R in the \4comparesamples folder 
#** The CollatedUnderwayData.csv file created by the function 4_xxxx_Join_and_Plot_interp.R in the \Data folder

# OUTPUT is in the \4comparesamples folder and includes:
# - CTD_TSG_QAT.csv-  table:CTD data at a certain depth near surface per event with time and position matched with TSG data 
# - TSG_ctdtable.RData
# - XXX_TSGCTDplot.jpeg - plots TSG vs CTD data for each variable per event and per day

# author Diana Cardoso
# Oct 2026
# Fisheries and Oceans Canada,Bedford Institute of Oceanography, Dartmouth, N.S. Canada B2Y 4A2

# read in the CTD and TSG data files
ctdall <- data.frame(read.csv("4comparesamples/CTD_table3.csv", header = TRUE))
tsgall <- data.frame(read.csv("C:/codasshared/AtSea/TSG/DY216/Data/DY216_CollatedUnderwayData.csv", header = TRUE))  

library(lubridate)
library(dplyr)

# 1. Round timestamps to the minute in both data frames
ctdallmin <- ctdall %>% mutate(match_time = floor_date(as.POSIXct(timectd, tz = "UTC"), "minute"))
tsgall$match_time <- floor_date(ymd_hms(tsgall$datetime_join, tz = "UTC"), unit = "minute")

# 2. Join them using the new minute-level key
join_tsgctd <- inner_join(ctdallmin, tsgall, by = "match_time")

write.csv(join_tsgctd, file = "4comparesamples/CTD_TSG_QAT.csv")
save(join_tsgctd, file = "4comparesamples/TSG_ctdtable.RData")
TSG_ctdtable <- join_tsgctd

jpeg(paste0(getwd(),"/4comparesamples/salevent_TSGCTDplot.jpeg"), width = 1150, height = 750)
# 2. Create a plot
plot(TSG_ctdtable$event,TSG_ctdtable$ctdsal1, col = "green", pch = 19, bg="green", cex=4, 
     ylim=c(round(min(TSG_ctdtable$ctdsal1 )),round(max(TSG_ctdtable$ctdsal1) )),
     #xlim=c(min(TSG_ctdtable$timeTSG ),max(TSG_ctdtable$timeTSG) ),
     main="salinity, green=CTD, red=TSG", ylab="salinity",xlab="event",xaxt="n")
points(TSG_ctdtable$event,TSG_ctdtable$salinity, col = "dark red", pch = 19, bg="red", cex=2)
text(TSG_ctdtable$event[seq(1, length(TSG_ctdtable$salinity), by=11)]+0.25,
     TSG_ctdtable$ctdsal1[seq(1, length(TSG_ctdtable$salinity), by=11)], 
     labels = as.character(TSG_ctdtable$event[seq(1, length(TSG_ctdtable$salinity), by=11)]), 
     offset = 100, cex = 1, col = NULL,font = 20)
axis(side = 1, at = round(min(as.numeric(TSG_ctdtable$event),na.rm = TRUE )):round(max(as.numeric(TSG_ctdtable$event),na.rm = TRUE )))
# Close the pdf file
dev.off()

jpeg(paste0(getwd(),"/4comparesamples/chlevent_TSGCTDplot.jpeg"), width = 1150, height = 750)
# 2. Create a plot
plot(TSG_ctdtable$event,TSG_ctdtable$ctdChl, col = "green", pch = 19, bg="green", cex=4, 
     ylim=c(round(min(TSG_ctdtable$ctdChl ))-1,round(max(TSG_ctdtable$chl_fluo_ug_L) )),
     #xlim=c(min(TSG_ctdtable$timeTSG ),max(TSG_ctdtable$timeTSG) ),
     main="Chlorophyl, green=CTD, red=TSG", ylab="Chlorophyl",xlab="event",xaxt="n")
points(TSG_ctdtable$event,TSG_ctdtable$chl_fluo_ug_L, col = "dark red", pch = 19, bg="red", cex=2)
text(TSG_ctdtable$event[seq(1, length(TSG_ctdtable$salinity), by=11)]+0.25,
     TSG_ctdtable$ctdChl[seq(1, length(TSG_ctdtable$salinity), by=11)], 
     labels = as.character(TSG_ctdtable$event[seq(1, length(TSG_ctdtable$salinity), by=11)]), 
     offset = 100, cex = 1, col = NULL,font = 20)
axis(side = 1, at = round(min(as.numeric(TSG_ctdtable$event),na.rm = TRUE )):round(max(as.numeric(TSG_ctdtable$event),na.rm = TRUE )))
# Close the pdf file
dev.off()

jpeg(paste0(getwd(),"/4comparesamples/tempevent_TSGCTDplot.jpeg"), width = 1150, height = 750)
# 2. Create a plot
plot(TSG_ctdtable$event,TSG_ctdtable$ctdtemp1, col = "green", pch = 19, bg="green", cex=4, 
     ylim=c(round(min(TSG_ctdtable$ctdtemp1 ))-1,round(max(TSG_ctdtable$temp_SBE45) )),
     #xlim=c(min(TSG_ctdtable$timeTSG ),max(TSG_ctdtable$timeTSG) ),
     main="Temperature SBE45, green=CTD, red=TSG", ylab="Temperature",xlab="event",xaxt="n")
points(TSG_ctdtable$event,TSG_ctdtable$temp_SBE45, col = "dark red", pch = 19, bg="red", cex=2)
text(TSG_ctdtable$event[seq(1, length(TSG_ctdtable$salinity), by=11)]+0.25,
     TSG_ctdtable$ctdtemp1[seq(1, length(TSG_ctdtable$salinity), by=11)], 
     labels = as.character(TSG_ctdtable$event[seq(1, length(TSG_ctdtable$salinity), by=11)]), 
     offset = 100, cex = 1, col = NULL,font = 20)
axis(side = 1, at = round(min(as.numeric(TSG_ctdtable$event),na.rm = TRUE )):round(max(as.numeric(TSG_ctdtable$event),na.rm = TRUE )))
# Close the pdf file
dev.off()

jpeg(paste0(getwd(),"/4comparesamples/conevent_TSGCTDplot.jpeg"), width = 1150, height = 750)
# 2. Create a plot
plot(TSG_ctdtable$event,TSG_ctdtable$ctdcon, col = "green", pch = 19, bg="green", cex=4, 
     ylim=c(round(min(TSG_ctdtable$ctdcon ))-1,round(max(TSG_ctdtable$conductivity) )),
     #xlim=c(min(TSG_ctdtable$timeTSG ),max(TSG_ctdtable$timeTSG) ),
     main="Conductivity, green=CTD, red=TSG", ylab="Conductivity",xlab="event",xaxt="n")
points(TSG_ctdtable$event,TSG_ctdtable$conductivity, col = "dark red", pch = 19, bg="red", cex=2)
text(TSG_ctdtable$event[seq(1, length(TSG_ctdtable$salinity), by=11)]+0.25,
     TSG_ctdtable$ctdcon[seq(1, length(TSG_ctdtable$salinity), by=11)], 
     labels = as.character(TSG_ctdtable$event[seq(1, length(TSG_ctdtable$salinity), by=11)]), 
     offset = 100, cex = 1, col = NULL,font = 20)
axis(side = 1, at = round(min(as.numeric(TSG_ctdtable$event),na.rm = TRUE )):round(max(as.numeric(TSG_ctdtable$event),na.rm = TRUE )))
# Close the pdf file
dev.off()

