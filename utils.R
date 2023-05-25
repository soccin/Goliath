load_oncokb <- function() {

    oo=readRDS(inputs$oncokb_file)

    #
    # Need this for join, Our MAF's keep Position fields as numbers
    #
    oo$dat=oo$dat %>% mutate(Start_Position=as.numeric(Start_Position),End_Position=as.numeric(End_Position))
    oo

}

load_gene_annotations <- function() {
    readRDS("data/geneAnnotation.rds")
}

load_methods <- function() {
    readLines("data/methods.md")
}

load_glossary <- function() {
    read_csv("data/glossary.csv")
}
