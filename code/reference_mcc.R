# get the 0.03 or user defined line from a mothur-formatted list file and put
# each grouping of sequences (i.e. an OTU) into a different seat of the vector.
# we'll also trim off the OTU threshold label and number of OTUs

get_list_data <- function(list_file){
    file <- scan(list_file, what="", sep="\n", quiet=TRUE)

    otu_line <- file[grepl("^0\\.03", file)]
    if(length(otu_line) == 0){
        otu_line <- file[1]
    }

    split_data <- unlist(strsplit(otu_line, split="\\s"))
    otu_assignments <- split_data[-c(1,2)]

    return(otu_assignments)
}


# for each sequence in an OTU assign it the number of that OTU
map_reads <- function(otu_sequences, index){
    sequences <- unlist(strsplit(otu_sequences, split=","))

    otu_assignment <- rep(index, length(sequences))
    names(otu_assignment) <- sequences
    otu_assignment
}


# assign the appropriate OTU number to each sequence. returns it as a vector
get_map <- function(otu_assignments){
    n_otus <- length(otu_assignments)
    otu_map <- unlist(unname(mapply(map_reads, otu_assignments, 1:length(otu_assignments))))
    return(otu_map)
}


# read in a mothur-formatted names file and return the unique sequence names
# from the first column of the file
get_names <- function(names_file){
    file <- read.table(file=names_file, stringsAsFactors=FALSE)
    unique_names <- file$V1
    return(unique_names)
}


# given a list of sequence names and the OTU mapping to sequences, return the
# pruned OTU map that includes those OTUs that overlap with the provided list of
# sequence names
prune_map <- function(otu_map, seq_names){
    otu_map[names(otu_map) %in% seq_names]
}


# cpp_confusion_matrix should not be called outside of get_confusion_matrix
# function, which is below... this function takes all possible pairs of
# sequences from the test_map and sees whether they're in the same or different
# OTU as each other in the reference_map. based on these results, it counts the
# number of true positive, true negative, false positive, and false negative
# OTU assignments
library(Rcpp)
cppFunction('NumericVector cpp_confusion_matrix(NumericVector test_map, NumericVector reference_map) {

    int tp = 0;
    int tn = 0;
    int fp = 0;
    int fn = 0;

    NumericVector confusion(4);

    for(int i=0;i<test_map.size()-1;i++){

        int test_index = test_map[i];
        int ref_index = reference_map[i];

        for(int j=i+1;j<test_map.size();j++){

            if(test_index == test_map[j]){
                if(ref_index == reference_map[j]){
                    tp++;
                } else {
                    fp++;
                }
            } else {
                if(ref_index == reference_map[j]){
                    fn++;
                } else {
                    tn++;
                }
            }

        }
    }

    NumericVector out = NumericVector::create(tp, tn, fp, fn);
    out.names() = CharacterVector::create("tp", "tn", "fp", "fn");

    return out;
}')

# this is an R wrapper for the above cpp code. the first thing it does is to
# make sure that we have a list of sequences that are shared between the
# test and reference datasets. then it calls cpp_confusion_matrix to get back
# the confusion matrix data
get_confusion_matrix <- function(test_map, ref_map){
    intersecting_names <- intersect(names(test_map), names(ref_map))

    cpp_confusion_matrix(test_map[as.character(intersecting_names)],
                                    ref_map[as.character(intersecting_names)])
}


# this takes in the confusion matrix vector and calculates the Matthew's
# Correlation Coefficient. If the denominator is zero, we return an NA
mcc <- function(confusion){
    numerator <- confusion["tp"] * confusion["tn"] - confusion["fp"] * confusion["fn"]
    denominator <- (confusion["tp"] + confusion["fp"]) * (confusion["tp"] + confusion["fn"]) *
                    (confusion["tn"] + confusion["fp"]) * (confusion["tn"] + confusion["fn"])

    if(denominator != 0){
        mcc <- unname(numerator / sqrt(denominator))
    } else {
        mcc <- NA
    }

    mcc
}


# here we take in a list of test files which contains the names of the files
# that we want to calculate the MCC for. It also takes in the list of reference
# files, which is what all of the test list files will be compared against. the
# names file is used so that we are only working with the unique sequences. this
# assumes that the sequences are defined as "something_#.#_##.*list" where the
# #.# is the fraction of sequences in the test dataset relative to the reference
# dataset and the XX is the replicate being analyzed. it goes through all of the
# reference files and calculates the MCC for each test set relative to each
# reference set for each fraction value.
get_all_v_all_mcc <- function(test_files, reference_files, names_files){

    fractions <- unique(gsub(".*_(\\d\\.\\d)_\\d\\d.*", "\\1", test_files))
    n_fractions <- length(fractions)
    n_reps <- length(reference_files)

    stopifnot(n_reps * n_fractions == length(test_files))

    mcc_curve <- data.frame(matrix(rep(0, n_reps*n_reps*(n_fractions)), ncol=n_fractions))
    colnames(mcc_curve) <- fractions

    for(i in 1:length(reference_files)){
        print(i)
        ref_map_full <- get_map(get_list_data(reference_files[i]))

        for(j in 1:length(test_files)){
            test_names <- get_names(names_files[j])
            test_map_prune <- prune_map(get_map(get_list_data(test_files[j])), test_names)
            ref_map_prune <- prune_map(ref_map_full, test_names)

            confusion <- get_confusion_matrix(test_map_prune, ref_map_prune)
            f <- gsub(".*_(\\d\\.\\d)_\\d\\d.*", "\\1", test_files[j])
            r <- as.numeric(gsub(".*_\\d\\.\\d_(\\d\\d).*", "\\1", test_files[j]))
            mcc_curve[(i-1)*n_reps+r, f] <- mcc(confusion)
        }
    }
    colnames(mcc_curve) <- unique(fractions)
    mcc_curve$query <- rep(1:n_reps, n_reps)
    mcc_curve$reference <- rep(1:n_reps, each=n_reps)
    return(mcc_curve)
}


# this function drives the analysis and takes in a folder, output filename,
# and filename patterns that can be used to scrape up all of the list and names
# file names. it writes the output to the user defined output filename.
run_reference_mcc <- function(folder, test_pattern, reference_pattern, names_pattern, output_file_name){
    test_list_files <- list.files(path=folder, pattern=test_pattern, full.names=TRUE)
    reference_list_files <- list.files(path=folder, pattern=reference_pattern, full.names=TRUE)
    names_files <- list.files(path=folder, pattern=names_pattern, full.names=TRUE)

    mcc_data <- get_all_v_all_mcc(test_list_files, reference_list_files, names_files)
    write.table(file=output_file_name, x=mcc_data, sep="\t", row.names=F, quote=F)
}


# example code
#
#test_file <- "list_files/he_0.2_01.unique.an.list"
#test_list <- get_list_data(test_file)
#test_map <- get_map(test_list)
#
#ref_file <- "list_files/he_1.0_01.unique.an.list"
#ref_list <- get_list_data(ref_file)
#ref_map <- get_map(ref_list)
#
#names_file <- "list_files/he_0.2_01.names"
#test_names <- get_names(names_file)
#
#test_map_prune <- prune_map(test_map, test_names)
#ref_map_prune <- prune_map(ref_map, test_names)
#
#confusion <- get_confusion_matrix(test_map_prune, ref_map_prune)
#mcc(confusion)
#

