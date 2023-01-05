source("load_argos.R")

if(exists("SOURCED") && SOURCED) halt(".INCLUDE")

suppressPackageStartupMessages(require(tidyverse))
args=commandArgs(trailing=T)

aa=load_argos(args[1])
samp="s_C_VXXWFY_G007_d06"




SOURCED=T
