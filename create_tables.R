suppressPackageStartupMessages({
    library(tidyverse)
    library(htmlTable)
    library(kableExtra)
})

get_clinical_table <- function(argosDb,sid) {

    clinTbl=read_csv("data/section01.csv")
    clinTbl$Value1=argosDb[[sid]][clinTbl$Value1] %>% unlist
    clinTbl$Value2=argosDb[[sid]][clinTbl$Value2] %>% unlist
    clinTbl$Value2['SAMPLE_ID']=gsub("s_","",clinTbl$Value2['SAMPLE_ID']) %>% gsub("_","-",.)

    clinTbl

}

get_summary_table <- function(argosDb,sid) {
    tribble(
        ~Section, ~Data,
        "Summary:", stringi::stri_rand_lipsum(1),
        "MSI Status:", stringi::stri_rand_lipsum(1),
        "Tumor Mutations Burden:", stringi::stri_rand_lipsum(1),
        "Comments:", stringi::stri_rand_lipsum(1)
    )
}

get_maf_table <- function(argosDb,sid) {
    argosDb[[sid]]$MAF %>%
        filter(!grepl("=$",HGVSp_Short)) %>%
        mutate(`Additional Information`=paste0("MAF: ",round(100*t_var_freq,1),"%")) %>%
        mutate(Alteration=gsub("^p.","",HGVSp_Short)) %>%
        mutate(Alteration=paste0(Alteration," (",HGVSc,")")) %>%
        mutate(Location=paste("exon",gsub("/.*","",EXON))) %>%
        select(Gene=Hugo_Symbol,Type=Variant_Classification,Alteration,Location,`Additional Information`) %>%
        mutate_all(~replace(.,grepl("^NA|NA$",.) | is.na(.),""))
}

get_cnv_table <- function(argosDb,sid) {
    geneAnnotation=load_gene_annotations()
    argosDb[[sid]]$CNV %>%
        select(Gene=Hugo_Symbol,tcn,FACETS_CALL) %>%
        filter(tcn>5 | tcn<1) %>%
        left_join(geneAnnotation,by=c(Gene="hgnc.symbol")) %>%
        filter(gene_biotype=="protein_coding") %>%
        mutate(Type="Whole Gene",Alteration=FACETS_CALL) %>%
        mutate(Location=paste0(chrom,band)) %>%
        mutate(`Additional Information`=paste0("TCN: ",tcn)) %>%
        arrange(chrom) %>%
        select(Gene,Type,Alteration,Location,`Additional Information`)
}

get_cnv_table_full <- function(argosDb,sid) {
    geneAnnotation=load_gene_annotations()
    argosDb[[sid]]$CNV %>%
        select(Gene=Hugo_Symbol,tcn,FACETS_CALL) %>%
        left_join(geneAnnotation,by=c(Gene="hgnc.symbol")) %>%
        filter(gene_biotype=="protein_coding") %>%
        mutate(Type="Whole Gene",Alteration=FACETS_CALL) %>%
        mutate(Location=paste0(chrom,band)) %>%
        mutate(`Additional Information`=paste0("TCN: ",tcn)) %>%
        arrange(chrom) %>%
        select(Gene,Type,Alteration,Location,`Additional Information`)
}
