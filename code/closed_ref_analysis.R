parse_sc_line <- function(line){
	split_line <- unlist(strsplit(line, "\t"))
	refrence <- split_line[1]
	split_line <- split_line[-1]
	n_repeats <- length(split_line)
	references <- rep(refrence, n_repeats)
	names(references) <- split_line
	return(references)
}

split_line <- function(line){
	sub_vector_names <- unlist(strsplit(line, ','))
	sub_vector <- rep(sub_vector_names[1], length(sub_vector_names))
	names(sub_vector) <- sub_vector_names
	return(sub_vector)
}

split_duplicates <- function(duplicates){
	unlist(unname(lapply(duplicates, split_line)))
}


unique_mapping <- function(mappings, redundant_ref_map){
	unlist(lapply(mappings, function(x){paste(sort(unique(redundant_ref_map[unlist(strsplit(x, ','))])), collapse=',')}))
}


get_sens_spec_data <- function(search_file, true_mapping, duplicate_lookup){

	small_dists <- true_mapping[true_mapping$distance <= 0.03,]
	true_map <- small_dists$uniqued
	names(true_map) <- gsub('-', '_', rownames(small_dists))

	tag <- gsub(".*(.c)$", "\\1", search_file)

	obs_map <- character()

	if(tag == "uc" || tag == "vc"){
		clusters <- read.table(file=search_file, stringsAsFactors=F)
		clusters <- clusters[clusters$V1=='H',c(9,10)]
		obs_map <- as.character(clusters$V10)
		names(obs_map) <- gsub("-\\d*;size=.*;", "", clusters$V9)
		names(obs_map) <- gsub('-', "_", names(obs_map))
	} else if(tag == "sc" || tag == "nc") {
		clusters <- scan(file=search_file, what=character(), sep='\n', quiet=T)
		listing <- lapply(clusters, parse_sc_line)
		obs_map <- unlist(listing)
		names(obs_map) <- gsub('-', "_", names(obs_map))
		names(obs_map) <- gsub('_[^_]*$', "", names(obs_map))
	}

	obs_map_unique <- duplicate_lookup[obs_map]
	names(obs_map_unique) <- names(obs_map)

	tp <- 0
	fp <- 0
	tn <- 0
	fn <- 0

	total <- nrow(true_mapping)

	seq_overlap <- intersect(names(true_map), names(obs_map_unique))
	real_overlap <- true_map[seq_overlap]
	obs_overlap <- obs_map_unique[seq_overlap]

	tp <- sum(real_overlap == obs_overlap)

	real_diff <- real_overlap[real_overlap != obs_overlap]
	obs_diff <- obs_overlap[real_overlap != obs_overlap]
	found <- sapply(1:length(real_diff), function(x){grepl(obs_diff[x], real_diff[x])})
	tp <- tp+sum(found)
	fp <- sum(!found)

	fn <- fn + sum(!names(true_map) %in% seq_overlap)
	fp <- fp + sum(!names(obs_map_unique) %in% seq_overlap)
	tn <- total - length(union(names(obs_map_unique), names(true_map)))

	sensitivity <- tp / (tp + fn)
	specificity <- tn / (tn + fp)
	accuracy <- (tp + tn) / total
	mcc <- (tp * tn - fp * fn) / sqrt((tp + fp)*(tp + fn)*(tn+fp)*(tn+fn))

	return(c(sensitivity=sensitivity, specificity=specificity, mcc=mcc, accuracy=accuracy))
}

run_sens_spec_analysis <- function(method){

	tag <- substr(method, 1, 1)

	names_file <- read.table(file="data/gg_13_8/gg_13_8_97.v4_ref.names", stringsAsFactors=F)
	redundant_ref_map <- split_duplicates(names_file$V2)

	true_mapping <- read.table(file="data/rand_ref/miseq.ref.mapping", row.names=1, header=T, stringsAsFactors=F)
	true_mapping$uniqued <- unique_mapping(true_mapping$references, redundant_ref_map)

	files <- list.files(path="./data/rand_ref", paste0("*.", tag, "closed.", tag, "c"), full.names=TRUE)
	results <- t(sapply(files, get_sens_spec_data, true_mapping, redundant_ref_map))

	write.table(results, paste0('data/rand_ref/closed_ref.', method, '.sensspec'), quote=F, sep='\t')
}


map_to_taxonomy <- function(line, taxonomy_data){
	otus <- unlist(strsplit(line, ','))
	length(unique(taxonomy_data[otus]))
}

expand_names <- function(line, names_data){
	otus <- unlist(strsplit(line, ','))
	paste(unique(names_data[otus,1]), collapse=',')
}

run_redundancy_analysis <- function(){

	names_file_map <- read.table(file="data/gg_13_8/gg_13_8_97.v4_ref.names", stringsAsFactors=F, row.names=1)
	redundant_ref_map <- split_duplicates(names_file_map$V2)

	true_mapping <- read.table(file="data/rand_ref/miseq.ref.mapping", row.names=1, header=T, stringsAsFactors=F)
	true_mapping$uniqued <- unique_mapping(true_mapping$references, redundant_ref_map)

	taxonomy_file <- read.table(file="data/references/97_otus.taxonomy", row.names=1, stringsAsFactors=FALSE)
	taxonomy_map <- taxonomy_file$V2
	names(taxonomy_map) <- rownames(taxonomy_file)

	close_data <- true_mapping[true_mapping$distance <= 0.03,]
	n_taxa_uniqued <- sapply(close_data$uniqued, map_to_taxonomy, taxonomy_data=taxonomy_map)
	n_dups_uniqued <- nchar(gsub("[^,]", "", close_data$uniqued)) + 1

	close_data$expanded <- sapply(close_data$uniqued, expand_names, names_file_map)
	n_taxa_expanded <- sapply(close_data$expanded, map_to_taxonomy, taxonomy_data=taxonomy_map)
	n_dups_expanded <- nchar(gsub("[^,]", "", close_data$expanded)) + 1

	write.table(cbind(n_dups_expanded, n_taxa_expanded, n_dups_uniqued, n_taxa_uniqued), row.names=rownames(close_data), 'data/rand_ref/closed_ref.redundancy.analysis', quote=F, sep='\t')
}

#sequence name / n_total_matches / n_total_taxa / n_close_matches / n_close_taxa
