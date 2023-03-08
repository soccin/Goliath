source("load_argos.R")

#################################################################

load_data<-function(argos_dir) {

    argos_data=load_argos(argos_dir)
    sampleID=names(argos_data)[1]

    summaryTbl=get_summary_table(argos_data,sampleID)

    tbl01=get_clinical_table(argos_data,sampleID)

    mafTbl=get_maf_table(argos_data,sampleID)

    cnvTbl=get_cnv_table(argos_data,sampleID)

    cnvTblFull=get_cnv_table_full(argos_data,sampleID)

    list(
        summaryTbl=summaryTbl,
        tbl01=tbl01,
        mafTbl=mafTbl,
        cnvTbl=cnvTbl,
        cnvTblFull=cnvTblFull
    )

}
