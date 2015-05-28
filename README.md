Re-analysis of He et al. (2015) Microbiome study
=======

I think their analysis was crap


Overview
--------

    project
    |- README          # the top level description of content
    |
    |- doc/            # documentation for the study
    |  |- notebook/    # preliminary analyses (dead branches of analysis)
    |  +- paper/       # manuscript(s), whether generated or not
    |
    |- data            # raw and primary data, are not changed once created
    |  |- references/  # reference files to be used in analysis
    |  |- raw/         # raw data, will not be altered
    |  |- mothur/      # mothur processed data
    |  |- he/	       # direct replication of He et al. analyis
    |  +- process/     # cleaned data, will not be altered once created;
    |                  # will be committed to repo
    |
    |- code/           # any programmatic code
    |- results         # all output from workflows and analyses
    |  |- tables/      # text version of tables to be rendered with kable in R
    |  |- figures/     # graphs, likely designated for manuscript figures
    |  +- pictures/    # diagrams, images, and other non-graph graphics
    |
    |- scratch/        # temporary files that can be safely deleted or lost
    |
    |- study.Rmd       # executable Rmarkdown for this study, if applicable
    |- study.md        # Markdown (GitHub) version of the *Rmd file
    |- study.html      # HTML version of *.Rmd file
    |
    +- Makefile        # executable Makefile for this study, if applicable



Dependencies
------------
The following need to be installed and in the path...
* mothur (v.1.36.0)
* QIIME (v.1.9.1)
* UCLUST (v.1.6.XXX)
* R

