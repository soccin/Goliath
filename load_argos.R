load_argos<-function(odir) {

    pdir=file.path(odir,"portal")
    dpt=read_tsv(file.path(pdir,"data_clinical_patient.txt"),comment="#")
    sampleData=read_tsv(file.path(pdir,"data_clinical_sample.txt"),comment="#") %>%
        left_join(dpt,by="PATIENT_ID")
    maf=read_tsv(file.path(pdir,"data_mutations_extended.txt"),comment="#")
    fusions=read_tsv(file.path(pdir,"data_fusions.txt"),comment="#")
    cnv=read_tsv(file.path(pdir,"data_CNA.txt"),comment="#") %>%
        gather(Sample,CNV,-Hugo_Symbol) %>% filter(CNV!=0 & !is.na(CNV))

    list(sampleData=sampleData,maf=maf,cnv=cnv,fusions=fusions)

}