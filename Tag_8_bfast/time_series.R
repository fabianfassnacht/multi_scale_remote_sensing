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
m_ts <- as.vector(mod_ndvi[16,32])
m_ts[m_ts==0] <- NA

###
# create time series objects by merging the NDVI time series values with the corresponding dates
###

# prepare dataframe with NDVI values and dates
m.df <- data.frame(m_ts, m_dat_for)

mod_ts <- bfastts(as.vector(m_ts), m_dat_for, type = c("irregular"))

mod_ts_ip <- round(na.approx(mod_ts),0) 
plot(mod_ts_ip)


bfm <- bfast(mod_ts_ip, h = 10/length(mod_ts_ip), 
         season = "harmonic", breaks = 2, max.iter = 2)

bfm
plot(bfm)

pixels <- as.vector(tura[30,i])

# here we define the function that we will apply across the brick using the calc function:

tur_dat

s.f.periodic.window <- window(x = mod_ts_ip2, 
                              start = c(2000,1))

bfm <- bfast(s.f.periodic.window[,1], h = 10/length(s.f.periodic.window[,1]), 
             season = "harmonic", breaks = 2, max.iter = 2)

plot(bfm)


bfmRaster = function(pixels){
  
  pixels[pixels==0] <- NA

  m.df <- data.frame(pixels, tura_dat)
  
  mod_ts <- bfastts(as.vector(m_ts), tura_dat, type = c("irregular"))
  mod_ts_ip <- round(na.approx(mod_ts),0) 
  
  mod_ts_ip2 <- aggregate.daily.to.weekly(mod_ts_ip)
  
  
  bfm <- bfast(mod_ts_ip2[,1], h = 10/length(mod_ts_ip2), 
               season = "harmonic", breaks = 2, max.iter = 2)
  
  return(c(bfm$Magnitude, bfm$Time))

}






z <- extent(tura)

xm <-819105
xma <-819900
ym <-829045
yma <-829745

bla <- extent(xm, xma, ym, yma)

tura_cr <- crop(tura, bla)


pixels <- tura_cr[90]


bfmR <- calc(tura_cr, bfmRaster)


plot(bfmR)

mod_ndvi2 <- aggregate(mod_ndvi,8)

