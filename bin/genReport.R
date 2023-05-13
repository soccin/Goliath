get_input_dirs<-function(root_dir) {

    analysis_dir=fs::dir_ls(root_dir) %>% grep("analysis$",.,value=T) %>% unname()
    portal_dir=fs::dir_ls(root_dir) %>% grep("portal$",.,value=T) %>% unname()

    list(
        analysis_dir=analysis_dir,
        portal_dir=portal_dir
    )

}

args=commandArgs(trailing=T)
if(length(args)!=3) {
    cat("\n   usage: genReport.R REPORT.Rmd argosFolder sample_id\n\n")
    quit()
}

params=list(
    inputs=get_input_dirs(args[2]),
    sample_id=args[3]
)

VERSION="0.2.1"

projectNo=stringi::stri_match(params$argosDir,regex="argos/([^/]+)/")[2]

rmarkdown::render(
    args[1],
    params=params,
    output_format="html_document",
    output_file=paste0("rpt_",projectNo,"-",params$sample_id,"__",VERSION,".html"),
    intermediates_dir=tempdir(),
    clean=T
)
