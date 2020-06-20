## Preparing time series data stacks with Google Earth Engine ##


### Overview ###

In this lecture you will learn how to use the Google Earth Engine (GEE) to extract time series of all available Landsat and MODIS data for a study area defined in a Polygon shapefile. Before we work with the actual code, I will provide some links to the official documentation of the Google Earth Engine, which you should read carefully. I decided to not reproduce all of this information in this tutorial as many of the contents on the official page are very well described and easy to understand.

One important aspect of today's tutorial is that we will not use R to work within the GEE but java-script. However, there is no need for you to learn a new programming language from scratch. One efficient way to use the GEE is to simply copy & paste code snippets that can be found on the official GEE page and in online forums and then only adapt some smaller parts of the code to make them run with your data. Most of the basic processing chains in the GEE which are required to prepare datasets for further processing in R have been already implemented and are well documented in the internet. 

### Learning objectives ###

Besides getting familiar with the Google Earth Engine itself, we will also learn some concrete processing steps within the GEE: 

- how to upload a Shapefile to the Google Earth Engine and use it as region of interest / study area
- load Landsat and MODIS image collections in the GEE
- select certain time-windows in the image collection
- perform cloud-masking on the image collection in the GEE
- calculate NDVI within Landsat image collections
- store the prepared NDVI time-series to a Google Drive

In the later parts of the tutorial we will load the time series raster stacks exported from the GEE to R and convert the raster-data to time-series objects and we apply some basic tools on them.


### Datasets used in this Tutorial ###

The only dataset used in this Tutorial is a shapefile defining the boundary of the examined study area which is the city Xining, in the Qinghai province in China. Xining is the province capital of Qinghai and has been rapidly expaning its area over the last few years. The Shapefile can be downloaded here:

[https://drive.google.com/drive/folders/16OjLRl2HPM3_eiBklzRoHwDU3NQihpcS?usp=sharing](https://drive.google.com/drive/folders/16OjLRl2HPM3_eiBklzRoHwDU3NQihpcS?usp=sharing)

### Short Overview of the Google Earth Engine ###

First of all: What is the Google Earth Engine (GEE)? The GEE is an online platform developed and hosted by Google which provides several very interesting opportunities for conducting geospatial analyses using remote sensing and other geodata. The idea of the platform is that most of the data (particularly data with large file sizes) is already available directly on the platform and that the user does not have to download the files before processing. Furthermore, the GEE also provides processing power directly in the online platform. That means, it is not only possible to access large amounts of geodata online but it is also possible to directly work with the data in the google cloud. The big advantage of this is, is quite obvious. This constellation allows users such as scientists to process huge amounts of data with a super-computer which may not be available at their university and for sure not at their institute. The only thing that is required to access the GEE is a computer with internet access.

While this sounds great at the beginning, there are also some shortcomings to this system. At the moment the GEE is by far not offering as many algorithms as for example R. However, Google offers an interface to Python which provides a similar amount of algorithms as R with direct access to the GEE and a lot of opportunities to work with the data. A second problem is that even though the service is free at the moment, this philosophy could change any moment- in case Google simply decides to not longer provide the GEE services for free. Another small issue is, that for downloading the processed data, it is required to have a Google Drive which in the cost-free version has limited storage space. Hence for processing large dataset, it might be necessary to sign-up for plans with extended data volume to download the results and hence some costs will be created by processing within the GEE. However, for the exercises we will conduct in this course, a normal google account should be sufficient to download the results.

### Dataset in the GEE ###

An overview over the geo-datasets that are directly available in the GEE can be found here:

[https://developers.google.com/earth-engine/datasets](https://developers.google.com/earth-engine/datasets)

This should lead you to a webpage hat looks like this:

![](gee_1.png)


Take some time to browse the data catalogue! It is quite impressive how many of the typical remote sensing datasets are directly available in the GEE. Amongst others, the GEE hosts the complete Landsat archive of Landsat 4, 5, 7 and 8 as well as the Sentinel-2 archive and most parts of the Sentinel-1 data. You can also find MODIS data. Most of the data are not only available as raw data but also as higher-level data. That is, the images have already been pre-processed with the standard processing chains of the original data providers. This can save a lot of time, as most of the tiring, repetitive tasks have already been completed and the user can directly focus on analyzing the data.

For accessing the individual datasets (called "collections") in the GEE code editor (will be explained below), it is necessary to know the exact name and access-link of each image collection. You can find the corresponding values when you select one of the datasets under the link provided above. For example if we want to access the Landsat 8 surface reflectance data (that is, an atmospheric correction has already been applied to the raw satellite data), we would find the correponding name/link here:

[https://developers.google.com/earth-engine/datasets/catalog/LANDSAT_LC08_C01_T1_SR](https://developers.google.com/earth-engine/datasets/catalog/LANDSAT_LC08_C01_T1_SR)

The entry "Earth Engine Snippet" is the access-link/name under which we can access the LS 8 data within the GEE:

**ee.ImageCollection("LANDSAT/LC08/C01/T1_SR")**

As a first small exercise, try to find out what the corresponding Snippets are for Landsat 5 Surface Reflectance Data and one of the MODIS products in which NDVI is included and at a spatial resolution of 250 m. Please provide the answers in ILIAS (Aufgabe 9 - Code Snippets).

### Step 1: Registering for the Google Earth Engine ###

If you don't have a Google Earth Engine account yet, you can sign-up here:

[https://developers.google.com/earth-engine](https://developers.google.com/earth-engine)

Simply press on the marked link and follow the instructions:

![](gee_2.png)

### Step 2: The Google Earth Documentation ###

The official GEE documentation provides a rich amount of tutorials explaining the functionalities of the GEE from scratch. It is highly recommended to read some of the materials provided here to gather a first understanding how the GEE works and to develop a basic understanding of the java-script language being used in the GEE code editor. However, please be aware that many things can also be accomplished without understanding the java-script syntax completely but rather by modifying code-snippets as mentioned already above. The GEE documentation can be accessed here:

[https://developers.google.com/earth-engine/tutorials](https://developers.google.com/earth-engine/tutorials)

Some recommendable tutorials to play around with and get acquainted with the way the GEE works are linked below. Take some time and explore some of the tutorials - you will see it is quite interesting how fast data can be accessed and visualized. If you participated in the remote sensing course in the winter semester you will quickly understand how much more comfortable the data access in the GEE is, in comparison to downloading individual satellite images, pre-processing them and then loading them in R or another programming environment. Before starting with the Tutorials below, it might be worthwhile to have a quick look at Step 3 first were the GEE code editor is briefly introduced.

Some recommended Tutorials:

[https://developers.google.com/earth-engine/image_visualization](https://developers.google.com/earth-engine/image_visualization)

[https://developers.google.com/earth-engine/image_info](https://developers.google.com/earth-engine/image_info)

[https://developers.google.com/earth-engine/image_math](https://developers.google.com/earth-engine/image_math)

[https://developers.google.com/earth-engine/image_relational](https://developers.google.com/earth-engine/image_relational)

[https://developers.google.com/earth-engine/ic_filtering](https://developers.google.com/earth-engine/ic_filtering)

These are just some recommended tutorials to get started with remote sensing data, but you will see that in the same documentation page, there will be loads of additional examples to also conduct more complex analyses directly within the GEE environment.

### Step 3:  The GEE code Editor ###

After registering for the GEE you can access code editor (the main interface we will be using for working in the GEE) here:

[https://code.earthengine.google.com/](https://code.earthengine.google.com/)

This will lead to an interactive web-page which looks like this:

![](gee_3.png)

The code editor window is separated into four major sections. In section 1 you can find all the Scripts, documentations and Assets (basically, data that the user uploads) connected to your user account. In section 2 the code you are currently working on will be displayed and in section 3 you wil be informed about the processing progress of your code (Console) and you can for example start the export of files (Tasks). Finally, in section 4, a world map is displayed and you will later on also learn how to display the data you have processed in the GEE on this map.


### Step 4: Exporting a complete time series of MODIS NDVI data ###

In this first hands-on part of the tutorial, we will export a complete time series of MODIS NDVI products for a small area located at the border of the Qinghai Tibetan Plateau. The area covers parts of the city Xining in China. At this point, I am assuming that you have already played around with the Google Earth Engine by exploring some of the tutorials mentioned in Step 2.

As first step to perpare our work-flow we will upload the Shapefile provided in the "Datasets used in this Tutorial section". For this, we will select the tab Assets in section 1 of the code editor:

![](gee_4.png)

Then we will click the red NEW button and select "Shape files":

![](gee_5.png)

In the appearing window, we have to first select all the supported Shapefile sub-files (marked with 1) and then assign a name to the uploaded files, for example "Xining" (marked with 2). Then we can upload the files by pressing "UPLOAD" in the bottom right part of the window.

![](gee_6.png)

The files will then be uploaded to the Google Earth engine and saved in your list of asstes. You might have to press the "refresh" button next to the red "NEW" button to make the new asset named "Xining" appear in your list. We can now use the uploaded Shapefile for working with the GEE.

In order to this, we have to import the asset into the script we are currently working on. We can do this by selecting the "arrow" button marked with 1 in the screenshot below.

![](gee_7.png)

After clicking the "arrow" button, the asset/Shapefile will be imported to t he current script and a new line will appear on the top of the script. We can define a name for the imported Shapefile by changing the default name "table" to some other term. In the given example, I changed the name to "AOI" - area of interest.


In the following I will now provide the complete code for exporting MODIS NDVI data from the GEE - you can simply copy & paste this code to the code editor window and you should be ready to run it. More detailed explanations can be found directly in the code and further below:

	// Filter a MODIS image collection by date and region 
	// Calculate an NDVI
	// Export the NDVI time series to Google Drive
	
	
	// Step 1: Define the time period to be considered 
	var sdate = '2000-01-01'
	var edate = '2020-05-25'
	
	// Step 2: define functions requires for processing

	// ###################################
	// functions to perform cloud masking
	// ###################################
	
	var maskQA = function(image) {
	      return image.updateMask(image.select("SummaryQA").eq(0));
	    };
	
	// Step 3: Process the data

	// Load the MODIS collection and filter the collection for the
	// considered time period and the area of interest

	// ##############################################################
	// Load MODIS product MOD13Q1 (please check the specifications
	// in the GEE data catalogue)
	// ##############################################################
	var MODIS_VI = ee.ImageCollection("MODIS/006/MOD13Q1")
	    .filterDate(sdate, edate)
	    .filterBounds(AOI);
	
	// ##############################################################
	// Apply cloud masks to image collections
	// ##############################################################
	
	var MODIS_best = MODIS_VI.map(maskQA)
	print(MODIS_best)
	
	// ##############################################################
	// Select the NDVI band from the MODIS product 
	// ##############################################################
	
	var MODIS_ndvi = MODIS_best.select('NDVI');
	print(MODIS_ndvi)

	// ##############################################################
	// transform the NDVI image collection to a stack of bands so that they can
	// be exported to the Google Drive
	// ##############################################################
	var MODIS_ndvi_fin = MODIS_ndvi.toBands();
	
	// ##############################################################
	// Apply a work-around to access the image dates (see further instructions below)
	// ##############################################################
	
	function ymdList(imgcol){
	    var iter_func = function(image, newlist){
	        var date = ee.Number.parse(image.date().format("YYYYMMdd"));
	        newlist = ee.List(newlist);
	        return ee.List(newlist.add(date))
	    };
	    return imgcol.iterate(iter_func, ee.List([]));
	}
	var dates = ymdList(MODIS_ndvi);
	
	print(dates);
	
	
	// ##############################################################
	// Export Landsat time series to GeoTiff (see further instructions below)
	// ##############################################################
	
	
	// Export a cloud-optimized GeoTIFF.
	Export.image.toDrive({
	  image: MODIS_ndvi_fin,
	  description: 'MODIS_all_00_20_sm',
	  scale: 250,
	  maxPixels: 5937315072,
	  region: AOI,
	  fileFormat: 'GeoTIFF',
	  formatOptions: {
	    cloudOptimized: true
	  }
	});



To successfully run this code, copy & paste the complete code to the code editor window. Then click save or save as and the current script will be saved and appear in your list of scripts in section 1 of the code editor. After saving the script, you should be able to run the code by clicking Run.

Once you pressed Run, new information will appear in the Console in section 3. 

![](gee_8.png)

In the console, we can mostly find some information that was printed to the Console by the code-lines that start with the "print()" command. In this example, the two upper entries of the console simply allow us to see how many images have been processed/selected based on our definition: 465 images were available for the selected product and time-window. The last entry, is in our case the most important one, as this entry contains all the dates at which the satellite images were acquired. In this tutorial we will simply copy and paste the dates to a text-file by opening the list (click on the text marked with 1) and then mark all the entries and copy them

![](gee_9.png)

Then open the Windows Editor program:

![](gee_10.png)

And paste the entries to the text file:

![](gee_11.png)

And finally save this text-file to a folder in which we can find it again. Let's name it for example "dates_mod.txt". This is not a very elegant wy of exporting the acquisition dates but while preparing this Tutorial, I had troubles finding a straightforward solution directly in the GEE and as this workflow works, we will stick with it for now and I hope that by next year, I will have found a smoother option to accomplish this.

With this step, we have saved the acquisition dates, but we did not yet export the corresponding images. We will now do this by selecting the "Tasks" tab in section 3 of the code editor (marked with 2):

![](gee_8.png)

We will then see a list of tasks that wait for being executed. In my case, there are several tasks from earlier scripts in the list, in your case there might only be on task which is named as the one in the top of my list - MODIS_all_00_20_sm:

![](gee_12.png)

We can now start the export of the raster stack to our Google Drive by clicking the "RUN" button (marked with 1). This will open a new window in which we can define the spatial resolutiojn with which we want to export the images and a folder in our google drive in which the data shall be stored. We can also not define a folder, then the image will simply be exported to the parent folder of the Google Drive. Once you are happy with your settings click "RUN" and then you will have to wait a few minutes or up to a few hours (if the data is large) until the data appears in your Google Drive. If you are not sure how to access your Google drive, please google it. Should be very easy to find.

![](gee_13.png)



### Step 5: Exporting a complete time series of Landsat 5, 7 and 8 data ###

After we managed to export all available NDVI MODIS images of the MODIS product MOD13Q1 for our area of interest, we will now try to accomplish the same but for the complete Landsat archive of the satellites Landsat 5, 7 and 8. The basic processing steps are the same, but the code itself is a bit more complex as we have to merge data from several image collections and also have to first calculate the NDVI from the original images.

We will also again have to apply the work-around described for MODIS to export the image acquisition dates manually by copy and pasting the dates to a text-file.