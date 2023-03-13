# Argos-Report

## Version 0.9.5

Scripts to load data from Argos output folders and process into tables to facilitate the creation of RMarkdown reports.

## Usage:

In your `R` or `RMarkdown` source the `load_data.R` file and call the `load_data` function. Example:

```
source("load_data.R")
data=load_data(argosDir,sampleID)
```

`argosDir` is the path to an Argos output folder and `sampleID` is one of the samples from that run.





