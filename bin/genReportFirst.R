args=commandArgs(trailing=T)
if(length(args)!=2) {
    cat("\n   usage: genReport.R REPORT.Rmd argosFolder\n\n")
    quit()
}


source("load_argos.R")
argos=load_argos(args[2])


VERSION="0.2.1"
projectNo=stringi::stri_match(args[2],regex="argos/([^/]+)/")[2]

si=unique(names(argos))[1]

cat("ARGS:",args[2],si,"\n")

params=list(
    argosDir=args[2],
    sampleID=si
)

rmarkdown::render(
    args[1],
    params=params,
    output_format="html_document",
    intermediates_dir=tempdir(),
    output_file=paste0("rpt_",projectNo,"-",params$sampleID,"__",VERSION,".html"),
    clean=T
)
