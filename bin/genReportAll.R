get_input_dirs<-function(root_dir) {

    analysis_dir=fs::dir_ls(root_dir) %>% grep("analysis$",.,value=T) %>% unname()
    portal_dir=fs::dir_ls(root_dir) %>% grep("portal$",.,value=T) %>% unname()

    list(
        analysis_dir=analysis_dir,
        portal_dir=portal_dir
    )

}

args=commandArgs(trailing=T)
if(length(args)!=2) {
    cat("\n   usage: genReport.R REPORT.Rmd argosFolder\n\n")
    quit()
}


source("load_argos.R")

argos=load_argos(get_input_dirs(args[2]))


VERSION="0.2.1"
projectNo=stringi::stri_match(args[2],regex="argos/([^/]+)/")[2]


for(si in unique(names(argos))) {

    params=list(
        inputs=get_input_dirs(args[2]),
        sample_id=si
    )

    dir.create(file.path("rpt_",projectNo,params$sample_id),recur=T)

    rmarkdown::render(
        args[1],
        params=params,
        output_format="html_document",
        output_dir=file.path("rpt_",projectNo,params$sample_id),
        output_file=paste0("rpt_",projectNo,"-",params$sample_id,"__",VERSION,".html"),
        intermediates_dir=tempdir(),
        clean=T
    )

}