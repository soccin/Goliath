source("load_argos.R")

#################################################################

argos_dir="data/argos/11704_Y/1.1.2/20221102_20_40_060423"

#
#
#

argos_data=load_argos(argos_dir)
sampleID=names(argos_data)[1]

#################################################################
#################################################################

summaryTbl=get_summary_table(argos_data,sampleID)

tbl01=get_clinical_table(argos_data,sampleID)

mafTbl=get_maf_table(argos_data,sampleID)

cnvTbl=get_cnv_table(argos_data,sampleID)

cnvTblFull=get_cnv_table_full(argos_data,sampleID)

#################################################################
#################################################################

