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
require(bfast)

#library(forecast)
#library(seas)
#require(lubridate)
#require(openair)


# load example dataset
data(tura)

# get dates of example dataset
tura_dat <- getZ(tura)

# take pixel with break points

tura_pix <- tura[90]

# build time series object (this will create a daily time series
# which will be a very long vector from 166 to 10402 values!!)
tura_ts <- bfastts(as.vector(tura_pix), tura_dat, type = c("irregular"))
# interpolate missing values in time series
tura_ts_ip <- round(na.approx(tura_ts),0) 
# plot interpolated time series
plot(tura_ts_ip, main="daily")

# to reduce the number of values, we aggregate the time series 
# to a weekly time series which looks more or less the same
tura_ts_ip2 <- aggregate.daily.to.weekly(tura_ts_ip)
plot(tura_ts_ip2, main="weekly")

# at the beginning of the time series, we hardly have any values
# hence we select only the part of the time series after 2000
tura_ts_ip2.win <- window(x = tura_ts_ip2, start = c(2000,1))
plot(tura_ts_ip2.win)

bfm <- bfast(tura_ts_ip2.win[,1], h = 10/length(tura_ts_ip2.win[,1]), 
             season = "harmonic", breaks = 2, max.iter = 2)

plot(bfm)




###
# load raster-stacks exported from the Google Earth Engine
###

# set working directory
setwd("D:/Multiskalige_FE/5_Practicals/1_GEE_basics_v2")

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


bfm2 <- bfast(mod_ts_ip2[,1], h = 10/length(mod_ts_ip2[,1]), 
         season = "harmonic", breaks = 2, max.iter = 2)

plot(bfm2)

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



mod_ndvi2 <- aggregate(mod_ndvi,10)
plot(mod_ndvi2)

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


test2 <- calc(mod_ndvi2, function(x){bfmRaster2(x, dat_hard = m_dat_for)})
plot(test2)
