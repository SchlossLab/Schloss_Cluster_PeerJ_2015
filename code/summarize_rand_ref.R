summary_stats <- function(x){
	min <- min(x)
	max <- max(x)
	median <- median(x)
	mean <- mean(x)
	sd <- sd(x)

	c(min=min, max=max, median=median, mean=mean, sd=sd)
}


get_hits <- function(cluster_file){
	cluster_data <- read.table(file=cluster_file, stringsAsFactors=FALSE)
	cluster_data[cluster_data$V1 == "H", 10]
}


get_hits_summary <- function(rand_hits, orig_hits, method){
	rand_n_hits <- sapply(rand_hits, length)
	orig_n_hits <- length(orig_hits)

	output_data <- c(summary_stats(rand_n_hits), original=orig_n_hits)
	output_filename <- paste0("data/rand_ref/hits.", method, "closed.summary")
	write.table(file=output_filename, x=output_data, row.names=TRUE, col.names=FALSE, quote=FALSE, sep="\t")
}


get_overlap_summary <- function(rand_hits, orig_hits, method){
	counter <- 1
	overlap <- numeric()

	for(i in 1:length(rand_hits)){
		A <- unique(rand_hits[[i]])
		n_A <- length(A)

		for(j in 1:i){
			if(j < i){
				B <- unique(rand_hits[[j]])
				n_B <- length(B)
				n_AB <- length(intersect(A, B))
				overlap[counter] <- n_AB / (n_A + n_B - n_AB)
				counter <- counter + 1
			}
		}
	}

	rand_orig <- rep("rand", counter-1)

	A <- unique(orig_hits)
	n_A <- length(A)	#[1] 1307

	for(i in 1:length(rand_hits)){
		B <- unique(rand_hits[[i]])
		n_B <- length(B)

		n_AB <- length(intersect(A, B))

		overlap[counter] <- n_AB / (n_A + n_B - n_AB)
		counter <- counter + 1
	}

	rand_orig <- c(rand_orig, rep("orig", length(rand_hits)))

	describe_overlap <- aggregate(overlap, by=list(rand_orig), summary_stats)
	summarize_overlap <- describe_overlap$x
	rownames(summarize_overlap) <- describe_overlap$Group.1 

	output_filename <- paste0("data/rand_ref/overlap.", method, "closed.summary")
	write.table(file=output_filename, x=summarize_overlap, row.names=TRUE, col.names=TRUE, quote=FALSE, sep="\t")
}


summarize_rand_ref <- function(method){
	rand_cluster_pattern <- paste0("rand_ref.*", method, "c")

	rand_cluster_files <- list.files(path="data/rand_ref", pattern=rand_cluster_pattern, full.names=TRUE)
	original_cluster_file <- paste0("data/rand_ref/original.", method, "closed.", method, "c")

	rand_hits <- lapply(rand_cluster_files, get_hits)
	orig_hits <- get_hits(original_cluster_file)

	get_hits_summary(rand_hits, orig_hits, method)
	get_overlap_summary(rand_hits, orig_hits, method)
}

