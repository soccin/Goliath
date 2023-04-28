args=commandArgs(trailing=T)
if(length(args)!=2) {
    cat("\n   usage: test01 REPORT.Rmd argosFolder\n\n")
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

source("load_data.R")
data=load_data(params$argosDir,params$sampleID)
