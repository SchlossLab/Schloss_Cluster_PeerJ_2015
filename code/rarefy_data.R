summary_single <- function(list_file, label){
	command_string <- paste0('mothur "#summary.single(list=', list_file, ', label=', label, ', calc=nseqs-sobs)"')
	system(command_string)
	
	summary_string <- gsub("list$", "summary", list_file)
	read.table(file=summary_string, header=T)[,c(2,3)]
}


rarefy_single <- function(list_file, nseqs, label){
	fraction <- gsub(".*(\\d\\.\\d{1,2}).*", "\\1", list_file)
	rep <- gsub(".*(\\d\\d).*", "\\1", list_file)

	subsample_size <- nseqs[fraction]
	
	reference_list_file <- gsub(fraction, "1.0", list_file)
	
	command_string <- paste0('mothur "#summary.single(list=', reference_list_file, ', label=', label, ', calc=sobs-nseqs, subsample=', subsample_size, ')"')
	system(command_string)

	summary_string <- gsub("list$", "ave-std.summary", reference_list_file)
	read.table(file=summary_string, header=T)[1,3]
}

rarefy_sobs <- function(cluster_method, path, fraction=c("0.2", "0.4", "0.6", "0.8", "1.0")){
	label <- ifelse(grepl("unique", cluster_method), "0.03", "userLabel")

	path <- gsub("([^/])$", "\\1/", path)
	write(fraction, "")    
	reps <- c(paste0("0", 1:9), 10:30)
	method <- gsub(".*/(.*)/", "\\1_", path)
	file_names <- paste0(path, method, as.vector(outer(fraction, reps, paste, sep="_")), ".", cluster_method, ".list")

	observed <- data.frame(t(sapply(file_names, summary_single, label)))
	rownames(observed) <- gsub(path, "", rownames(observed))

	sample_size <- aggregate(unlist(observed$nseqs), by=list(gsub(".*(\\d\\.\\d{1,2}).*", "\\1", rownames(observed))), min)$x
	names(sample_size) <- fraction

	rarefied <- data.frame(t(sapply(file_names, rarefy_single, sample_size, label)))
	names(rarefied) <- gsub(gsub("/", ".", path), "", names(rarefied))

	observed$rarefied <- t(rarefied[rownames(observed)])
	observed$replicate <- gsub(".*(\\d\\d).*", "\\1", names(rarefied))
	observed$fraction <- gsub(".*(\\d\\.\\d{1,2}).*", "\\1", names(rarefied))

	cluster_method <- gsub("unique.", "", cluster_method)	
	method <- gsub("_", ".", method)	

	write.table(as.matrix(observed), file=paste0(path, "/", method, cluster_method, ".rarefaction"), quote=FALSE, row.names=FALSE, sep="\t")
	
	unlink(gsub("list$", "summary", file_names))
	unlink(gsub("list$", "ave-std.summary", file_names))
	unlink("mothur*logfile")
}

