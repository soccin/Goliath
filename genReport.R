args=commandArgs(trailing=T)
if(len(args)!=2) {
    cat("\n   usage: genReport.R REPORT.Rmd argosFolder\n\n")
    quit()
}

params=list(
    argosDir=args[2]
)

rmarkdown::render(
    args[1],
    params=params,
    output_format="html_document"
)
