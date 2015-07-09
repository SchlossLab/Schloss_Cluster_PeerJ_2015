get_contigsfile <- function(p){
        p <- gsub("\\/$", "", p)
        f <- list.files(p)
		f <- f[!grepl("Mock", f)] #let's ignore the mock community data
		
        r1 <- f[grep("_R1_", f)]
        r1.group <- sub("_S.*", "", r1)

        r2 <- f[grep("_R2_", f)]
        r2.group <- sub("_S.*", "", r2)

        stopifnot(r1.group == r2.group)

        files.file <- paste0(gsub(".*\\/(.*)", "\\1", p), ".files")
        p.files.file <- paste0(p, "/", files.file)

        write.table(file=p.files.file, cbind(r1.group, r1, r2), sep="\t", quote=F, row.names=F, col.names=F)
}





