source("load_argos.R")

suppressPackageStartupMessages({
    library(tidyverse)
    library(htmlTable)
    library(kableExtra)
})

if(interactive() && exists("SOURCED") && SOURCED) halt(".INCLUDE")

geneAnnotation=readRDS("data/geneAnnotation.rds")

args=commandArgs(trailing=T)

aa=load_argos(args[1])
samp=names(aa)[1]

tbl01=read_csv("data/section01.csv")

tbl01$Value1=aa[[samp]][tbl01$Value1] %>% unlist
tbl01$Value2=aa[[samp]][tbl01$Value2] %>% unlist

tbl01$Value2['SAMPLE_ID']=gsub("s_","",tbl01$Value2['SAMPLE_ID']) %>% gsub("_","-",.)

css.cell=c("padding-left: .25em","padding-left: 1em; padding-right: 6em;","padding-left: .25em;","padding-left: 1em;")
tbl01 %>% addHtmlTableStyle(align = "llll",col.rgroup=c("#FBEEC7","#FFFFFF"),css.cell=css.cell) %>%
    htmlTable(rnames=F,cnames=F,header=rep("",4))

mafTbl=aa[[samp]]$MAF %>%
    filter(!grepl("=$",HGVSp_Short)) %>%
    mutate(`Additional Information`=paste0("MAF: ",round(100*t_var_freq,1),"%")) %>%
    mutate(Alteration=gsub("^p.","",HGVSp_Short)) %>%
    mutate(Alteration=paste0(Alteration," (",HGVSc,")")) %>%
    mutate(Location=paste("exon",gsub("/.*","",EXON))) %>%
    select(Gene=Hugo_Symbol,Type=Variant_Classification,Alteration,Location,`Additional Information`) %>%
    mutate_all(~replace(.,grepl("^NA|NA$",.) | is.na(.),""))

mafTbl %>% addHtmlTableStyle(align="lllll") %>% htmlTable(rnames=F)

mafTbl.html=mafTbl %>% addHtmlTableStyle(align="lllll",css.cell="padding-left: 1em;") %>% htmlTable(rnames=F,useViewer=F)

cnvTbl=aa[[samp]]$CNV %>%
    select(Gene=Hugo_Symbol,tcn,FACETS_CALL) %>%
    filter(tcn>5 | tcn<1) %>%
    left_join(geneAnnotation,by=c(Gene="hgnc.symbol")) %>%
    filter(gene_biotype=="protein_coding") %>%
    mutate(Type="Whole Gene",Alteration=FACETS_CALL) %>%
    mutate(Location=paste0(chrom,band)) %>%
    mutate(`Additional Information`=paste0("TCN: ",tcn)) %>%
    arrange(chrom) %>%
    select(Gene,Type,Alteration,Location,`Additional Information`)

cnvTbl.html=cnvTbl %>% addHtmlTableStyle(align="lllll",css.cell="padding-left: 1em;") %>% htmlTable(rnames=F,useViewer=F)


# cnvTbl=aa[[samp]]$CNV %>%
#     filter(abs(CNV)>1 & !grepl("^snp|^Tiling2|_Promoter_",Hugo_Symbol)) %>%
#     mutate(Alteration=ifelse(CNV>0,"Amplification","Deletion"),Type="Whole gene") %>%
#     select(Gene=Hugo_Symbol,Type,Alteration)

SOURCED=T

