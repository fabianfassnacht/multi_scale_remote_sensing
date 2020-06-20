# load required packages
require(raster)
require(xts)
require(zoo)

###
# load raster-stacks exported from the Google Earth Engine
###

# set working directory
setwd("D:/Multiskalige_FE/5_Practicals/1_GEE_basics_v2")
# load Landsat time series with images from 1986-2020
ls_ndvi <- brick("LS_NDVI_all_86_20.tif")
nlayers(ls_ndvi)
# load MODIS time series with images from 2000-2020
mod_ndvi <- brick("MODIS_all_00_20_sm.tif")
nlayers(mod_ndvi)

###
# load corresponding dates of the time series
###

# Landsat
ls_dat <- read.table("dates_ls.txt")
ls_dat_fin <- ls_dat[seq(2, nrow(ls_dat),2),]
ls_dat_fin2 <- as.character(ls_dat_fin)
ls_dat_for <- as.Date(ls_dat_fin2, format = c("%Y%m%d"))

# MODIS
m_dat <- read.table("dates_mod.txt")
m_dat_fin <- m_dat[seq(2, nrow(m_dat),2),]
m_dat_fin2 <- as.character(m_dat_fin)
m_dat_for <- as.Date(m_dat_fin2, format = c("%Y%m%d"))

###
# have a brief look on the data by plotting the individual time series
# raster of MODIS and some selected scenes of Landsat
###

# plot selected Landsat NDVI rasters

for(i in 420:430){
  
  plot(ls_ndvi[[i]], main=ls_dat_for[i], zlim=c(-0.5,1))
  
}

# plot MODIS NDVI rasters

for(i in 1:40){
  
  plot(mod_ndvi[[i]], main=m_dat_for[i], zlim=c(-5000,10000))
  
}


###
# extract NDVI time series for individual pixels
###

# extract Landsat pixel (here row 45, column 56)
ls_ts <- as.vector(ls_ndvi[45,56])

# MODIS (here, row 1, column 1)
m_ts <- as.vector(mod_ndvi[1,1])
m_ts[m_ts==0] <- NA

###
# create time series objects by merging the NDVI time series values with the corresponding dates
###

# prepare dataframe with NDVI values and dates
ls.df <- data.frame(ls_ts, ls_dat_for)
m.df <- data.frame(m_ts, m_dat_for)

# create time series object
ls.NDVI.ts <- xts(ls.df$ls_ts, order.by=ls.df$ls_dat_for)
mod.NDVI.ts <- xts(m.df$m_ts, order.by=m.df$m_dat_for)

# plot the time series
plot(ls.NDVI.ts)
plot(mod.NDVI.ts)


###
# work with time-series object
###

# interpolate missing values

ls.NDVI.ts.ip <- na.approx(ls.NDVI.ts)
plot(ls.NDVI.ts.ip)

mod.NDVI.ts.ip <- na.approx(mod.NDVI.ts)
plot(mod.NDVI.ts.ip)



# convert time series to yearly values
ls.NDVI.ts.y <- to.yearly(ls.NDVI.ts)
mod.NDVI.ts.y <- to.yearly(mod.NDVI.ts)

# plot yearly time series

plot(ls.NDVI.ts.y)
plot(ls.NDVI.ts.y$ls.NDVI.ts.High)

plot(mod.NDVI.ts.y)
plot(mod.NDVI.ts.y$mod.NDVI.ts.High)




