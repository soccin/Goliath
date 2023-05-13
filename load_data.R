source("load_argos.R")
source("utils.R")
source("version.R")
require(glue)

#################################################################

number_of_events <- function(table) {
    table %>% filter(Gene!="") %>% nrow
}

load_data<-function(sample_id,inputs) {

    str(sample_id)
    str(inputs)

    argos_data=load_argos(inputs)

    argos_dir=dirname(inputs$analysis_dir)

    if(is.null(argos_data[[sample_id]])) {
        cat("\n\nFATAL ERROR: invalid sample",sample_id,"\n")
        cat("argos_dir =",argos_dir,"\n\n\n")
        rlang::abort("FATAL ERROR")
    }

    isUnMatched=argos_data[[sample_id]]$MATCH == "UnMatched"

    tbl01=get_clinical_table(argos_data,sample_id)

    res=get_maf_tables(argos_data,sample_id,isUnMatched)

    mafTbl=res$mafTbl
    mafTblFull=res$mafTblFull

    cnvTbl=get_cnv_table(argos_data,sample_id)

    cnvTblFull=get_cnv_table_full(argos_data,sample_id)

    fusionTbl=get_fusion_table(argos_data,sample_id)

    nMut=number_of_events(mafTbl)
    nCNV=number_of_events(cnvTblFull)
    nFusion=number_of_events(fusionTbl)

    summaryTxt=glue("{nMut} mutations, {nCNV} copy number alterations, {nFusion} structural variant dectected")

    if(!isUnMatched) {

        if(! is.null(argos_data[[sample_id]]$MSI_STATUS)){
            msiTxt=glue("MSI Status = {MSI_STATUS}, score = {MSI_SCORE}",.envir=argos_data[[sample_id]])
        }
        else{
            msiTxt="Unkown, not calculated"
        }

        if(! is.null(argos_data[[sample_id]]$CMO_TMB_SCORE)){
            tmbTxt=glue("The estimated tumor mutation burden (TMB) for this sample is {CMO_TMB_SCORE} mutations per megabase (mt/Mb).",.envir=argos_data[[sample_id]])
        }
        else{
            tmbTxt="Unkown, not calculated"
        }
        summaryTbl=tribble(
            ~Section, ~Data,
            "Summary:", summaryTxt,
            "MSI Status:", msiTxt,
            "TMB Value:", tmbTxt
        )

    } else {

        summaryTbl=tribble(
            ~Section, ~Data,
            "Summary:", summaryTxt,
            "Comments:", "This sample was run un-matched (against a pooled normal) so the ExAC Germline Filter was applied"
        )

    }

    runFolder=gsub(".*argos","",argos_dir) %>% gsub("/$","",.)

    reportTbl=tribble(
        ~key,~value,
        "Report:",sprintf("Argos Report (version %s)",VERSION),
        "Run Folder:", runFolder,
        "Data UUID:", digest::digest(argos_data[[sample_id]])
        )

    list(
        summaryTbl=summaryTbl,
        tbl01=tbl01,
        mafTbl=mafTbl,
        mafTblFull=mafTblFull,
        cnvTbl=cnvTbl,
        cnvTblFull=cnvTblFull,
        fusionTbl=fusionTbl,
        reportTbl=reportTbl,
        methods=load_methods(),
        glossaryTbl=load_glossary()
    )

}
