split_line <- function(line){
	sub_vector_names <- sort(unlist(strsplit(line, ',')))
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

	clusters <- read.table(file=search_file, stringsAsFactors=F)
	clusters <- clusters[clusters$V1=='H',c(9,10)]
	obs_map <- as.character(clusters$V10)
	names(obs_map) <- gsub("-\\d*;size=.*;", "", clusters$V9)
	names(obs_map) <- gsub('-', "_", names(obs_map))
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

	names_file <- read.table(file="data/gg_13_8/gg_13_8_97.v4_ref.names", stringsAsFactors=F)
	redundant_ref_map <- split_duplicates(names_file$V2)

	true_mapping <- read.table(file="data/rand_ref/miseq.ref.mapping", row.names=1, header=T, stringsAsFactors=F)
	true_mapping$uniqued <- unique_mapping(true_mapping$references, redundant_ref_map)

	files <- list.files(path="./data/rand_ref", paste0("*.", method, "closed.", method, "c"), full.names=TRUE)
	results <- t(sapply(files, get_sens_spec_data, true_mapping, redundant_ref_map))

	write.table(results, paste0('data/rand_ref/closed_ref.', method, 'search.sensspec'), quote=F, sep='\t')

}


map_to_taxonomy <- function(line, taxonomy_data){
	otus <- unlist(strsplit(line, ','))
	length(unique(taxonomy_data[otus]))
}


run_redundancy_analysis <- function(){

	names_file <- read.table(file="data/gg_13_8/gg_13_8_97.v4_ref.names", stringsAsFactors=F)
	redundant_ref_map <- split_duplicates(names_file$V2)

	true_mapping <- read.table(file="data/rand_ref/miseq.ref.mapping", row.names=1, header=T, stringsAsFactors=F)
	true_mapping$uniqued <- unique_mapping(true_mapping$references, redundant_ref_map)

	taxonomy_file <- read.table(file="data/references/97_otus.taxonomy", row.names=1, stringsAsFactors=FALSE)
	taxonomy_map <- taxonomy_file$V2
	names(taxonomy_map) <- rownames(taxonomy_file)

	close_data <- true_mapping[true_mapping$distance <= 0.03,]
	n_taxa <- sapply(close_data$uniqued, map_to_taxonomy, taxonomy_data=taxonomy_map)
	n_dups <- nchar(gsub("[^,]", "", close_data$uniqued)) + 1

	write.table(table(n_taxa, n_dups), 'data/rand_ref/closed_ref.redundancy.analysis', quote=F, sep='\t')

}
