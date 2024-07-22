source("load_argos.R")
source("utils.R")
source("version.R")
require(glue)

#################################################################

number_of_events <- function(table) {
    table %>% filter(Gene!="") %>% nrow
}

load_data<-function(tumor_id,normal_id,inputs) {

    str(tumor_id)
    str(normal_id)
    str(inputs)

    argos_data=load_argos(inputs)

    argos_dir=dirname(inputs$analysis_dir)

    if(is.null(argos_data[[tumor_id]])) {
        cat("\n\nFATAL ERROR: invalid sample",tumor_id,"\n")
        cat("argos_dir =",argos_dir,"\n\n\n")
        rlang::abort("FATAL ERROR: invalid sample")
    }

    isUnMatched=argos_data[[tumor_id]]$MATCH == "UnMatched"
    
    tbl01=get_clinical_table(argos_data,tumor_id)

    res=get_maf_tables(argos_data,tumor_id,isUnMatched)

    mafTbl=res$mafTbl
    mafTblFull=res$mafTblFull

    fusionTbl=get_fusion_table(argos_data,tumor_id)

    nMut=number_of_events(mafTbl)
    nFusion=number_of_events(fusionTbl)
    nMutFull=number_of_events(mafTblFull)

    if(!isUnMatched) {

        cnvTbl=get_cnv_table(argos_data,tumor_id)
        cnvTblFull=get_cnv_table_full(argos_data,tumor_id)
        nCNV=number_of_events(cnvTbl)
        nCNVFull=number_of_events(cnvTblFull)

        summaryTxt=glue("Number of mutations: {nMut}; high level copy number alterations: {nCNV}; structural variants: {nFusion}")

        if(! is.null(argos_data[[tumor_id]]$MSI_STATUS)){
            msiTxt=glue("MSI Status = {MSI_STATUS}, score = {MSI_SCORE}",.envir=argos_data[[tumor_id]])
        }
        else{
            msiTxt="Unknown, not calculated"
        }

        if(! is.null(argos_data[[tumor_id]]$CMO_TMB_SCORE)){
            tmbTxt=glue("The estimated tumor mutation burden (TMB) for this sample is {CMO_TMB_SCORE} mutations per megabase (mt/Mb).",.envir=argos_data[[tumor_id]])
        }
        else{
            tmbTxt="Unknown, not calculated"
        }

        if(! is.null(argos_data[[tumor_id]]$ASCN_PURITY)){
            cnvPurityTxt=glue("The CNV purity value is {ASCN_PURITY}",.envir=argos_data[[tumor_id]])
        }
        else{
            cnvPurityTxt="Unknown, not calculated"
        }

        summaryTbl=tribble(
            ~Section, ~Data,
           "Summary:", summaryTxt,
          #  "MSI Status:", msiTxt,## MSI temporarly turned off, until we make sure its accuracy
            "TMB Value:", tmbTxt,
            "CNV Purity:", cnvPurityTxt
        )

    } else {

        source("create_tables.R")
        cnvTbl=get_null_table("The copy number for the tumor samples with unmatched pooled normals are unreliable and should be ignored.")
        cnvTblFull=get_null_table("The copy number for the tumor samples with unmatched pooled normals are unreliable and should be ignored.")

        summaryTxt=glue("Number of mutations: {nMut}; structural variants: {nFusion}")

        summaryTbl=tribble(
            ~Section, ~Data,
            "Summary:", summaryTxt,
            "Comments:", "This sample was run un-matched (against a pooled normal) so the ExAC Germline Filter was applied and copy number alterations are not reported."
        )

    }

    runFolder=gsub(".*argos","",argos_dir) %>% gsub("/$","",.)

    reportTbl=tribble(
        ~key,~value,
        "Report:",sprintf("Argos Report (version %s)",VERSION),
        "Run Folder:", runFolder,
        "Data UUID:", digest::digest(argos_data[[tumor_id]])
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
