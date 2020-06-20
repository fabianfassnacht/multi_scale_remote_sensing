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
require(lubridate)
require(zoo)
require(bfastSpatial)
require(bfast)

#library(forecast)
#library(seas)
#require(lubridate)
#require(openair)


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
# create time series objects 
###

# create daily time series object
mod_ts <- bfastts(as.vector(m_ts), m_dat_for, type = c("irregular"))
mod_ts

# interpolate time series
mod_ts_ip <- round(na.approx(mod_ts),0) 

# plot the resulting time series
plot(mod_ts_ip)

mod_ts_ip2 <- aggregate.daily.to.weekly(mod_ts_ip)


bfm2 <- bfast(mod_ts_ip2[,1], h = 10/length(mod_ts_ip2[,1]), 
         season = "harmonic", breaks = 2, max.iter = 2)

plot(bfm2)

bfm2$Magnitude
bfm2$Time


as.yearmon(time(mod_ts_ip2)[bfm2$Time])

# here we define the function that we will apply across the brick using the calc function:

bfmRaster = function(pixels){
  
  pixels[pixels==0] <- NA

  day_ts <- bfastts(as.vector(pixels), dat_hard, type = c("irregular"))
  day_ts_ip <- round(na.approx(day_ts),0) 
  
  week_ts_ip <- aggregate.daily.to.weekly(day_ts_ip)
  
  
  bfm_f <- bfast(week_ts_ip[,1], h = 10/length(week_ts_ip[,1]), 
               season = "harmonic", breaks = 2, max.iter = 2)
  
  return(c(bfm_f$Magnitude, bfm_f$Time))

}

rasterOptions(maxmemory=1e+06, chunksize=1e+07, progress = 'text')



plot(mod_ndvi[[5]], zlim=c(0,3000))
mod_ndvi2 <- aggregate(mod_ndvi,10)
plot(mod_ndvi2[[5]], zlim=c(0,3000))



dat_hard <- m_dat_for

test <- calc(mod_ndvi2, bfmRaster)

plot(test)



# MODIS (here, row 1, column 1)
m_ts <- as.vector(mod_ndvi2[3,5])
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


bfm2 <- bfast(mod_ts_ip2[,1], h = 10/length(mod_ts_ip2[,1]), 
              season = "harmonic", breaks = 2, max.iter = 2)

plot(bfm2)
bfm2$Magnitude
bfm2$Time








bfmRaster2 = function(pixels, dat_hard){
  
  pixels[pixels==0] <- NA
  
  day_ts <- bfastts(as.vector(pixels), dat_hard, type = c("irregular"))
  day_ts_ip <- round(na.approx(day_ts),0) 
  
  week_ts_ip <- aggregate.daily.to.weekly(day_ts_ip)
  
  
  bfm_f <- bfast(week_ts_ip[,1], h = 10/length(week_ts_ip[,1]), 
                 season = "harmonic", breaks = 2, max.iter = 2)
  
  return(c(bfm_f$Magnitude, bfm_f$Time))
  
}


bfras <- calc(mod_ndvi2, function(x){bfmRaster2(x, dat_hard = m_dat_for)})
names(bfras) <- c("Magnitude", "Timepoints")
plot(bfras)
