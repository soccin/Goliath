args=commandArgs(trailing=T)
if(length(args)!=3) {
    cat("\n   usage: genReport.R REPORT.Rmd argosFolder sampleID\n\n")
    quit()
}

params=list(
    argosDir=args[2],
    sampleID=args[3]
)

VERSION="0.2.1"

projectNo=stringi::stri_match(params$argosDir,regex="argos/([^/]+)/")[2]

rmarkdown::render(
    args[1],
    params=params,
    output_format="html_document",
    output_file=paste0("rpt_",projectNo,"-",params$sampleID,"__",VERSION,".html"),
    clean=T
)
