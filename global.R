try(detach("package:SpaDES.core", unload = TRUE)); devtools::load_all("~/Documents/GitHub/SpaDES.tools"); devtools::load_all("~/Documents/GitHub/SpaDES.core")

workDirectory <- getwd()

paths <- list(
  # cachePath = file.path(workDirectory, "cache"),
  cachePath = file.path(workDirectory, "cache"),
  modulePath = file.path(workDirectory, "modules"),
  inputPath = file.path(workDirectory, "inputs"),
  outputPath = file.path(workDirectory, "outputs")
)

setPaths(modulePath = paths$modulePath, inputPath = paths$inputPath, outputPath = paths$outputPath, cachePath = paths$cachePath)

modules <- list("testModule")

times <- list(start = 1985, end = 1985, timeunit = "year")
parameters <- list()
birdSpecies <- c("BBWA", "YRWA")
objects <- list(birdSpecies = birdSpecies)

mySim <- simInit(times = times, params = parameters, modules = modules, paths =  paths, objects = objects)
insideModule <- spades(mySim, debug = TRUE)

# prepInputs outside module

outsideModule <- lapply(X = birdSpecies, FUN = function(x){
  ras <- prepInputs(targetFile = paste0(x, "_currmean.asc"),
                    archive = paste0(x, "_current.zip"),
                    url = paste0("https://s3-us-west-2.amazonaws.com/bam-databasin-climatechangepredictions/climatepredictions-ascii/",
                                 x, "_current.zip"),
                    destinationPath = paths$outputPath,
                    overwrite = TRUE)
})

# No prepInputs
tempDir1 <- tmpDir()
lapply(X = birdSpecies, FUN = function(x){
  download.file(url = paste0("https://s3-us-west-2.amazonaws.com/bam-databasin-climatechangepredictions/climatepredictions-ascii/",
                             x, "_current.zip"),
                destfile = file.path(tempDir1, paste0(x, "_currmean.zip")))
  unzip(file.path(tempDir1, paste0(x, "_currmean.zip")), exdir = tempDir1)
})


# Compare results
insideModule@.envir$birdDensityRasters
outsideModule
BBWA1 <- raster::raster("/home/tmichele/Documents/GitHub/testModule/modules/testModule/data/BBWA_currmean.asc")
YRWA1 <- raster::raster("/home/tmichele/Documents/GitHub/testModule/modules/testModule/data/YRWA_currmean.asc")
BBWA2 <- raster::raster("/home/tmichele/Documents/GitHub/testModule/outputs/BBWA_currmean.asc")
YRWA2 <- raster::raster("/home/tmichele/Documents/GitHub/testModule/outputs/YRWA_currmean.asc")
BBWA3 <- raster::raster(file.path(tempDir1, "BBWA_currmean.asc"))
YRWA3 <- raster::raster(file.path(tempDir1, "YRWA_currmean.asc"))

