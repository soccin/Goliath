source("load_argos.R")
require(glue)

#################################################################

number_of_events <- function(table) {
    table %>% filter(Gene!="") %>% nrow
}

load_data<-function(argos_dir,sampleID) {

    argos_data=load_argos(argos_dir)

    tbl01=get_clinical_table(argos_data,sampleID)

    mafTbl=get_maf_table(argos_data,sampleID)

    cnvTbl=get_cnv_table(argos_data,sampleID)

    cnvTblFull=get_cnv_table_full(argos_data,sampleID)

    fusionTbl=get_fusion_table(argos_data,sampleID)

    nMut=number_of_events(mafTbl)
    nCNV=number_of_events(cnvTblFull)
    nFusion=number_of_events(fusionTbl)

    summaryTxt=glue("{nMut} mutations, {nCNV} copy number alterations, {nFusion} structural variant dectected")
    msiTxt=glue("MSI Status = {MSI_STATUS}, score = {MSI_SCORE}",.envir=argos_data[[sampleID]])
    tmbTxt=glue("The estimated tumor mutation burden (TMB) for this sample is {CMO_TMB_SCORE} mutations per megabase (mt/Mb).",.envir=argos_data[[sampleID]])

    summaryTbl=tribble(
        ~Section, ~Data,
        "Summary:", summaryTxt,
        "MSI Status:", msiTxt,
        "Tumor Mutations Burden:", tmbTxt
    )

    list(
        summaryTbl=summaryTbl,
        tbl01=tbl01,
        mafTbl=mafTbl,
        cnvTbl=cnvTbl,
        cnvTblFull=cnvTblFull,
        fusionTbl=fusionTbl
    )

}
