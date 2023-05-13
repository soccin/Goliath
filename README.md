# Argos-Report

## Version v1.0-RC1

Scripts to load data from Argos output folders and process into tables to facilitate the creation of RMarkdown reports.

## Usage:

In your `R` or `RMarkdown` source the `load_data.R` file and call the `load_data` function. Example:

```
source("load_data.R")
data=load_data(argosDir,sampleID)
```

`argosDir` is the path to an Argos output folder and `sampleID` is one of the samples from that run. The return values is a list with the following elements:

- `tbl01` - Sample metadata (id's, type, matched normal, ...)
- `summaryTbl` - Summary of alterations
- `mafTbl` - Mutation Table. Will be filtered with `ExAC`-filter if unmatched
- `cnvTbl` - Filtered Copy Number Table, DMP convention of only HOMODEL & AMP
- `cnvTblFull` - Full Copy Number Table
- `fusionTbl` - Fusion Events
- `reportTbl` - Report info (version, input directory)

## Notes:

The `rda` for the oncoKb annotations are located here:
```
/home/socci/Work/CI/Reports/Goliath/data/oncoAnnotations_v230330.rda
```





