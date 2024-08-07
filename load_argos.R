suppressPackageStartupMessages({
    library(readr)
    library(dplyr)
    library(purrr)
    library(jsonlite)
})

source("create_tables.R")

tibble_to_named_list<-function(tbl,col) {
    nl=transpose(tbl)
    names(nl)=map(nl,col) %>% unlist
    nl
}

get_with_default<-function(ll,key) {
    if(key %in% names(ll)) {
        return(ll[[key]])
    } else {
        return(NULL)
    }
}

get_sample_list<-function(odir) {

    read_tsv(
            file.path(pdir,"data_clinical_sample.txt"),
            comment="#",
            col_types = cols(.default = "c"),
            progress=F
            ) %>%
        distinct(SAMPLE_ID) %>%
        pull(SAMPLE_ID)

}

load_argos<-function(inputs) {

    #
    # inputs must be a list (or any object)
    # with two properties
    # - portal_dir => Path to argos/helix portal directory
    # - analysis_dir => Path to argos/helix analysis directory
    #
    
    pdir=inputs$portal_dir
    adir=inputs$analysis_dir

    dpt=read_tsv(file.path(pdir,"data_clinical_patient.txt"),comment="#",col_types = cols(.default = "?", SEX = "character"),show_col_types = TRUE)

    maf=read_tsv(fs::dir_ls(adir,regex=".muts.maf$"),comment="#",col_types = cols(.default = "?", Chromosome = "character"))

    if(!"t_var_freq" %in% names(maf)) {
	    if("t_depth" %in% names(maf)) {
            maf$t_var_freq=maf$t_alt_count/maf$t_depth
        } else {
            maf$t_var_freq=maf$t_alt_count/(maf$t_alt_count+maf$t_ref_count)
        }
    }
    
    normal_id=gsub("_","-",inputs$normal_id) %>% gsub("^s-","",.)
    
    # pairingTable= maf %>%
    #     distinct(SAMPLE_ID=Tumor_Sample_Barcode,NORMAL_ID=Matched_Norm_Sample_Barcode) %>%
    #     mutate(NORMAL_ID=gsub("_","-",NORMAL_ID) %>% gsub("^s-","",.))
    #if the output has 0 mutations, above doesn't work
    
    pairingTable <- tribble(
        ~SAMPLE_ID,~NORMAL_ID,
        inputs$tumor_id, normal_id
    )
    
    maf=maf %>% group_split(Tumor_Sample_Barcode)
    names(maf)=map(maf,\(x){x$Tumor_Sample_Barcode[1]}) %>% unlist

    sampleTbl=read_tsv(file.path(pdir,"data_clinical_sample.txt"),comment="#") %>%
        left_join(dpt,by="PATIENT_ID")

    sampleTbl=left_join(sampleTbl,pairingTable) %>%
        rowwise %>%
        mutate(MATCHED=ifelse(grepl("POOLED",NORMAL_ID),"UnMatched","Matched")) %>%
        ungroup

    sampleData=tibble_to_named_list(sampleTbl,"SAMPLE_ID")

    fusions=read_tsv(file.path(pdir,"data_fusions.txt"),comment="#") %>%
        group_split(Tumor_Sample_Barcode)
    names(fusions)=map(fusions,\(x){x$Tumor_Sample_Barcode[1]}) %>% unlist

    cnv=read_tsv(fs::dir_ls(adir,regex=".gene.cna.txt"),comment="#") %>%
        mutate(Tumor_Sample_Barcode=gsub("_[^_]*$","",Tumor_Sample_Barcode)) %>%
        group_split(Tumor_Sample_Barcode)
    names(cnv)=map(cnv,\(x){x$Tumor_Sample_Barcode[1]}) %>% unlist

    for(si in names(sampleData)) {
#        sampleData[[si]]$pMAF=get_with_default(pmaf,si)
        sampleData[[si]]$MAF=get_with_default(maf,si)
        sampleData[[si]]$CNV=get_with_default(cnv,si)
        sampleData[[si]]$Fusions=get_with_default(fusions,si)
    }

    sampleData

}
