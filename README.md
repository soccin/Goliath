# Argos-Report

## Version v1.0-RC1

Scripts to load data from Argos output folders and process into tables to facilitate the creation of RMarkdown reports.

## Usage:

In your `R` or `RMarkdown` source the `load_data.R` file and call the `load_data` function. Example:

```
source("load_data.R")
data=load_data(sample_id,inputs)
```

## Inputs 

- `sample_id` is one of the samples from that run. No checking is done so a fatal error will occur if the `sample_id` is not in the following `inputs` folders. (_FIX THIS_)

- `inputs` is a list with two (2) elements:
    - analysis_dir = the path to the ARGOS/HELIX analysis directory. It is the folder that contains the `.muts.maf$` file.
    - portal_dir = the path to the ARGOS/HELIX portal directory. It folder that contains the `data_clinical_sample.txt` file.

## Outputs

The return value is a list with the following elements:

- `tbl01` - Sample metadata (id's, type, matched normal, ...)
- `summaryTbl` - Summary of alterations
- `mafTbl` - Mutation Table. Will be filtered with `ExAC`-filter if unmatched
- `mafTblFull` - Unfiltered Mutation Table for case of unmatched normal (same as mafTbl for matched case)
- `cnvTbl` - Filtered Copy Number Table, DMP convention of only HOMODEL & AMP
- `cnvTblFull` - Full Copy Number Table
- `fusionTbl` - Fusion Events
- `reportTbl` - Report info (version, input directory)
- `methods` - Methods paragraph
- `glossaryTbl` - Glossary table with various definitions

