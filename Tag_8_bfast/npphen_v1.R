aggregate.daily.to.weekly <- function(daily.ts) {
  
  dates      <- as.Date(date_decimal(as.numeric(time(daily.ts))))
  
  xts.daily  <- xts(daily.ts, order.by = dates)
  
  xts.weekly <- round(xts::apply.weekly(xts.daily, median),0)  # xts
  
  start(xts.weekly)
  ts.weekly <- ts(data = xts.weekly, 
                  # define the start and end (Year, Week)    
                  start = c(as.numeric(format(start(xts.weekly), "%Y")),
                            as.numeric(format(start(xts.weekly), "%W"))), 
                  end   = c(as.numeric(format(end(xts.weekly), "%Y")), 
                            as.numeric(format(end(xts.weekly), "%W"))), 
                  frequency = 52)
  
  return(ts.weekly)
}

# load required packages
require(raster)
require(xts)
require(zoo)
require(bfastSpatial)
#require(bfast)
library(rgdal)
library(npphen)
library(rts)
library(lubridate)


###
# load raster-stacks exported from the Google Earth Engine
###

# set working directory
setwd("D:/Multiskalige_FE/5_Practicals/Tag_8_bfast")

# load MODIS time series with images from 2000-2020
mod_ndvi <- brick("MODIS_all_00_20_sm.tif")

###
# load corresponding dates of the time series
###

# MODIS
m_dat <- read.table("dates_mod.txt")
m_dat_fin <- m_dat[seq(2, nrow(m_dat),2),]
m_dat_fin2 <- as.character(m_dat_fin)
m_dat_for <- as.Date(m_dat_fin2, format = c("%Y%m%d"))



# MODIS (here, row 1, column 1)
m_ts <- as.vector(mod_ndvi[3,32])
m_ts[m_ts==0] <- NA

###
# create time series objects by merging the NDVI time series values with the corresponding dates
###

# prepare dataframe with NDVI values and dates
m.df <- data.frame(m_ts, m_dat_for)

mod_ts <- bfastts(as.vector(m_ts), m_dat_for, type = c("irregular"))

mod_ts_ip <- round(na.approx(mod_ts),0) 
plot(mod_ts_ip)

mod_ts_ip2 <- aggregate.daily.to.weekly(mod_ts_ip)

#mod_ts_ip3 <- window(mod_ts_ip2, start=2001, end=2019)



# prepare dates in format required by npphen

mts <- as.numeric(time(mod_ts_ip2))
## 'POSIXct, POSIXt' object
tms <- date_decimal(mts)


# extract index values
ndvi.num <- as.vector(mod_ts_ip2[,1])

#-------------------------------------------------------------------------
# A. Phen function for phenological reconstruction (for a numerical vector)
phen_1pix <- Phen(ndvi.num, tms, h=1, rge=c(0,10000), nGS = 46)
plot(phen_1pix)

#-------------------------------------------------------------------------
# B. PhenKplot to see the kernel density of the reconstructed phenology (for a numerical vector)
PhenKplot(ndvi.num, tms,h=1,nGS=46, xlab="Day of the growing season",ylab="EVI", rge=c(0,10000))



#-------------------------------------------------------------------------
# C. EVI anomalies calculation for the growing season 2015-2016 (for a numerical vector)
ano_GS16_1pix <- PhenAnoma(ndvi.num, tms,h=1,refp=c(1:824), anop=c(825:1048), rge=c(0,10000)) # To check the reference period and the anomaly calculation period, check the dates table



tms[824]
tms[825]


#-------------------------------------------------------------------------
# D. Making the LSP raster for a raster stack, output raster has 23 bands
# Define the number of cores to be use. In this example we use 1
nc1<-1
PhenMap(mod_ndvi,m_dat_for,h=2,nGS=23, nCluster=nc1,
        outname="phen_trapa.tif", format="GTiff", datatype="FLT4S",rge=c(0,10000))

#-------------------------------------------------------------------------
# E. Making the anomaly raster stack, output raster has same n.bands as the anomaly period (in this example, 1 growing season = 23 bands)
# Define the number of cores to be use. In this example we use 1
nc1<-1

PhenAnoMap(evi.stack,dates,h=2,refp=c(1:354), anop=c(355:377), nCluster=nc1,
           outname="ano_trapa.tif", format="GTiff", datatype="FLT4S",rge=c(0,10000))




