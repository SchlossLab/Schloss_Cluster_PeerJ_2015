# something is weird about the indices that NINJA-OPS is returning in the log
# file. taxonomically they're way off and I can't get them to match with what is
# in the alignments file. going to have to go this alone...

fix_ninja_indexing <- function(cluster_folder, db_folder){

	# get the mapping coordinate for each read. they're out of order in the
	# alignments.txt file, so we need to sort the coordinates according to the
	# sequence index.
	alignment_file <- paste0(cluster_folder, "/alignments.txt")
	alignments <- scan(file=alignment_file, what=character(), sep='\n', quiet=T)
	reads <- as.numeric(gsub("^([^\t]*).*", "\\1", alignments))
	coordinates <- gsub("^[^\t]*\t[^\t]*\t[^\t]*\t([^\t]*).*", "\\1", alignments)
	ordered_coords <- as.numeric(coordinates[order(reads)])
	ordered_coords[ordered_coords == 0] <- NA #these sequences didn't map

	# get the startign coordinate (V1) for each reference sequence (V2)
	coord_map_file <- paste0(db_folder, "/original.ninja_db.db")
	coord_map <- read.table(coord_map_file, sep=',')

	# map the coordinate for each sequence to a reference sequence
	index <- sapply(ordered_coords, function(x)sum(coord_map$V1 < x))
	reference <- coord_map[index,2]

	# get sequence names
	seq_name_file <- paste0(cluster_folder, "/ninja_dupes.txt")
	seq_names <- scan(seq_name_file, what=character(), quiet=TRUE)

	# combine data and output
	combined_data <- cbind(seq_names, reference)
	combined_data <- combined_data[complete.cases(combined_data),]

	output_file <- gsub("ninja", "nclosed.nc", cluster_folder)
	write.table(combined_data, output_file, row.names=F, col.names=F, quote=F, sep='\t')
}
