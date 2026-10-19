#' @title read ctd ODF data and match to TSG data and create a table
#' 
#' @description  read ctd ODF data and match to TSG data and create a table.  
#' CTD pressure for comparison with TSG intake dept is typically between 4 - 8 m 
#' is set as CTDpres in 4TSGcompare_ctd_samples.R
#'
#' @param  ctd ODF data (pathctd) and  CTD pressure for comparison with TSG intake depth (CTDpres)
#' 
#' @output is in the \4comparesamples folder and includes:
#' CTD_table3.csv-  table:CTD data at a certain depth near surface per event with time and position 
#'
#' @author Diana Cardoso
# Oct 2021
# Fisheries and Oceans Canada,Bedford Institute of Oceanography, Dartmouth, N.S. Canada B2Y 4A2

read.tsg_ctd<- function(pathctd,CTDpres){ 
  
files <- list.files(path = pathctd, 
                    pattern = 'D.*\\.ODF',
                    full.names = TRUE)
ctd <- lapply(files, read.ctd.odf)

lon <- unlist(lapply(ctd, function(k) k[['longitude']][1]))
lat <- unlist(lapply(ctd, function(k) k[['latitude']][1]))

startTime <- as.POSIXct(unlist(lapply(ctd, function(k) k[['startTime']])), origin = '1970-01-01', tz = 'UTC')
fakeStartTime <- as.POSIXct(paste("2026", format(startTime, '%m-%d %H:%M:%S'), sep = '-'), origin = '1970-01-01', tz = 'UTC')
eventnum <- (unlist(lapply(ctd, function(k) k[['eventNumber']])))

CTD_table <- data.frame(timectd = "NA",
                              ctdpres= 0,
                              ctdtemp1 = 0,
                              ctdsal1 = 0,
                              ctdoxy1 = 0,
                              ctdChl = 0,
                              ctdcon = 0,
                              ctdUV = 0,
                              ctdpH = 0,
                              lat = 0,
                              lon = 0,
                        startTime="NA",
                        event= "NA",
                        ctdtimeposix= "NA"
) 
CTDpres <- 7
x <- 1
for (i in 1:length(ctd)) {
  
pres <- unlist(lapply(ctd[i], function(k) k[['pressure']]==CTDpres))
pres65 <- unlist(lapply(ctd[i], function(k) k[['pressure']][pres]))
temp65 <- unlist(lapply(ctd[i], function(k) k[['temperature']][pres]))
sal65 <- unlist(lapply(ctd[i], function(k) k[['salinity']][pres]))
oxy65 <- unlist(lapply(ctd[i], function(k) k[['oxygen']][pres]))
time65 <- unlist(lapply(ctd[i], function(k) k[['time']][pres]))
chl65 <- unlist(lapply(ctd[i], function(k) k[['fluorescence']][pres]))
ph65 <- unlist(lapply(ctd[i], function(k) k[['pH']][pres]))
con65 <- unlist(lapply(ctd[i], function(k) k[['conductivity']][pres]))
uv65 <- unlist(lapply(ctd[i], function(k) k[['fluorescence2']][pres]))
lat65 <- unlist(lapply(ctd[i], function(k) k[['latitude']][pres]))
lon65 <- unlist(lapply(ctd[i], function(k) k[['longitude']][pres]))

timectd65=as.POSIXct(time65, origin = '1970-01-01', tz = 'UTC')
faketime65 <- as.POSIXct(paste("2026", format(timectd65, '%m-%d %H:%M:%S'), sep = '-'), origin = '1970-01-01', tz = 'UTC')

CTD_table[x,1] <- as.character(faketime65)
CTD_table[x,2] <- pres65
CTD_table[x,3] <- temp65
CTD_table[x,4] <- sal65
CTD_table[x,5] <- oxy65
CTD_table[x,6] <- chl65
CTD_table[x,7] <- con65
CTD_table[x,8] <- uv65
CTD_table[x,9] <- ph65
CTD_table[x,10] <- lat[i]
CTD_table[x,11] <- lon[i ]
CTD_table[x,12] <-as.character(fakeStartTime[x])
CTD_table[x,13] <- eventnum[x]
CTD_table[x,14] <- time65

print(x)
print(i)
x <-x+1
}

#write a csv with data
filename2 <- "CTD_table3.csv"
pathprocessed2 <- paste0("4comparesamples/", filename2)
write.csv(CTD_table,file =pathprocessed2)

}

