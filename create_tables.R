suppressPackageStartupMessages({
    library(tidyverse)
    library(htmlTable)
    library(kableExtra)
})

source("filter_exac.R")

get_null_table <- function(msg) {
    tribble(
        ~Gene,~Type,~Alteration,~Location,~`Additional Information`,
        "","",msg,"",""
        )
}

get_clinical_table <- function(argosDb,sid) {

    clinTbl=tribble(

        ~Key1,~Value1,~Key2,~Value2,
        "Project ID  ","REQUEST_ID","StudyID  ","PROJECT_PI",
        "Sample ID  ","COLLAB_ID","CMO ID  ","SAMPLE_ID",
        "Patient ID  ","PATIENT_ID","Sex  ","SEX",
        "Tumor Type  ","ONCOTREE_CODE","Sample Type  ","SAMPLE_TYPE",
        "Pair Status  ","MATCHED","NormalID  ","NORMAL_ID"

    )

    clinTbl$Value1=argosDb[[sid]][clinTbl$Value1] %>% unlist
    clinTbl$Value2=argosDb[[sid]][clinTbl$Value2] %>% unlist
    clinTbl$Value2['SAMPLE_ID']=gsub("s_","",clinTbl$Value2['SAMPLE_ID']) %>% gsub("_","-",.)

    clinTbl

}

format_maf_table <- function(mm) {
    mm %>%
        mutate(`Additional Information`=paste0("MAF: ",round(100*t_var_freq,1),"%")) %>%
        mutate(Alteration=gsub("^p.","",HGVSp_Short)) %>%
        mutate(Alteration=paste0(Alteration," (",HGVSc,")")) %>%
        mutate(Location=paste("exon",gsub("/.*","",EXON))) %>%
        select(Gene=Hugo_Symbol,Type=Variant_Classification,Alteration,Location,`Additional Information`) %>%
        mutate_all(~replace(.,grepl("^NA|NA$",.) | is.na(.),""))
}

get_maf_tables <- function(argosDb,sid,unmatched) {

    nullResult=list(
                mafTbl=get_null_table("No filtered mutations"),
                mafTblFull=get_null_tabl("No mutations (unfiltered)")
                )

    if(is.null(argosDb[[sid]]$MAF)) {
        return(nullResult)
    }

    #mafFull=argosDb[[sid]]$MAF %>% filter(!grepl("=$",HGVSp_Short))
    mafFull=argosDb[[sid]]$MAF %>% filter(grepl("=$",HGVSp_Short))

    if(nrow(mafFull)==0){
        return(nullResult)
    }

    if(!unmatched) {
        maf=mafFull
    } else {
        maf=filter_exac(mafFull)
    }

    if(!is.null(maf)) {

        list(
            mafTbl=format_maf_table(maf),
            mafTblFull=format_maf_table(mafFull)
        )

    } else {

        list(
            mafTbl=get_null_table("No filtered mutations"),
            mafTblFull=format_maf_table(mafFull)
        )

    }

}

get_cnv_table <- function(argosDb,sid) {
    geneAnnotation=load_gene_annotations()
    if(!is.null(argosDb[[sid]]$CNV)) {
        tbl=argosDb[[sid]]$CNV %>%
                select(Gene=Hugo_Symbol,tcn,FACETS_CALL) %>%
                filter(tcn>5 | tcn<1) %>%
                left_join(geneAnnotation,by=c(Gene="hgnc.symbol")) %>%
                filter(gene_biotype=="protein_coding") %>%
                mutate(Type="Whole Gene",Alteration=FACETS_CALL) %>%
                mutate(Location=paste0(chrom,band)) %>%
                mutate(`Additional Information`=paste0("TCN: ",tcn)) %>%
                arrange(chrom) %>%
                select(Gene,Type,Alteration,Location,`Additional Information`)

        if(nrow(tbl)>0) {
            tbl
        } else {
            get_null_table("No AMP or HOMODEL events")
        }

    } else {
        get_null_table("No AMP or HOMODEL events")
    }

}

get_cnv_table_full <- function(argosDb,sid) {
    geneAnnotation=load_gene_annotations()
    if(!is.null(argosDb[[sid]]$CNV)) {
        argosDb[[sid]]$CNV %>%
            select(Gene=Hugo_Symbol,tcn,FACETS_CALL) %>%
            filter(tcn!=2) %>%
            left_join(geneAnnotation,by=c(Gene="hgnc.symbol")) %>%
            filter(gene_biotype=="protein_coding") %>%
            mutate(Type="Whole Gene",Alteration=FACETS_CALL) %>%
            mutate(Location=paste0(chrom,band)) %>%
            mutate(`Additional Information`=paste0("TCN: ",tcn)) %>%
            arrange(chrom) %>%
            select(Gene,Type,Alteration,Location,`Additional Information`)
    } else {
        get_null_table("No copy number events")
    }
}

get_fusion_table <- function(argosDb,sid) {
    if(!is.null(argosDb[[sid]]$Fusions)) {
        argosDb[[sid]]$Fusions %>%
            mutate(`Additional Information`=paste0("Frame: ",Frame,"; Support: DNA=",DNA_support,",RNA=",RNA_support)) %>%
            separate(Fusion,c("Alteration","Type"),sep=" ") %>%
            mutate(Location="") %>%
            select(Gene=Hugo_Symbol,Type,Alteration,Location,`Additional Information`)
    } else {
        get_null_table("No fusion events")
    }

}
