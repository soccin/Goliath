source("load_argos.R")
source("create_tables.R")

suppressPackageStartupMessages({
    library(tidyverse)
    library(htmlTable)
    library(kableExtra)
})

if(interactive() && exists("SOURCED") && SOURCED) halt(".INCLUDE")


argos_dir="data/argos/11704_Y/1.1.2/20221102_20_40_060423"
argos_data=load_argos(argos_dir)
sampleID=names(argos_data)[1]

geneAnnotation=load_gene_annotations()

tbl01=get_clinical_table(argos_data,sampleID)

mafTbl=get_maf_table(argos_data,sampleID)

cnvTbl=get_cnv_table(argos_data,sampleID)

SOURCED=T

