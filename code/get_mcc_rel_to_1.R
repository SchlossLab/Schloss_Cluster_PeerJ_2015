map_reads <- function(otu_sequences, index){
    sequences <- unlist(strsplit(otu_sequences, split=","))

    otu_assignment <- rep(index, length(sequences))
    names(otu_assignment) <- sequences
    otu_assignment
}

get_map <- function(list_file){
    file <- scan(list_file, what="", sep="\n", quiet=TRUE)

    otu_line <- file[grepl("^0\\.03", file)]
    if(nchar(otu_line) == 0){
        otu_line <- file[1]
    }

    split_data <- unlist(strsplit(otu_line, split="\t"))
    n_otus <- as.numeric(split_data[2])

    otu_assignments <- split_data[-c(1,2)]

    otu_map <- unlist(unname(mapply(map_reads, otu_assignments, 1:length(otu_assignments))))

    return(otu_map)
}


prune_map <- function(names_file, otu_map){
    file <- read.table(file=names_file)
    unique_names <- file$V1

    otu_map[as.character(unique_names)]
}



mcc <- function(confusion){
    numerator <- confusion["tp"] * confusion["tn"] - confusion["fp"] * confusion["fn"]
    denominator <- (confusion["tp"] + confusion["fp"]) * (confusion["tp"] + confusion["fn"]) *
                    (confusion["tn"] + confusion["fp"]) * (confusion["tn"] + confusion["fn"])

    mcc <- numerator / sqrt(denominator)
    return(unname(mcc))
}


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



get_all_v_all_mcc <- function(method){
    n_reps <- 30
    n_fractions <- 5
    mcc_curve <- matrix(rep(0,n_reps * n_reps * n_fractions), ncol=n_fractions, nrow=n_reps * n_reps)
    colnames(mcc_curve) <- seq(0.2,1.0, 0.2)


#    for(ref in 1:n_reps){
    for(ref in 1:2){
        if(ref < 10){
            ref_names_file <- paste0("he_1.0_0", ref, ".names")
            ref_list_file <- paste0("he_1.0_0", ref, ".unique.", method, ".list")
        } else {
            ref_names_file <- paste0("he_1.0_", ref, ".names")
            ref_list_file <- paste0("he_1.0_", ref, ".unique.", method, ".list")
        }
        ref_map_full <- get_map(ref_list_file)


        for(f in colnames(mcc_curve)){

            for(r in 1:n_reps){
                list_file <- ""
                names_file <- ""

                if(r < 10){
                    list_file <- paste0("he_", format(as.numeric(f), digits=2, nsmall=1), "_0", r, ".unique.", method, ".list")
                    names_file <- paste0("he_", format(as.numeric(f), nsmall=1), "_0", r, ".names")
                } else {
                    list_file <- paste0("he_", format(as.numeric(f), nsmall=1), "_", r, ".unique.", method, ".list")
                    names_file <- paste0("he_", format(as.numeric(f), nsmall=1), "_", r, ".names")
                }

                test_map_prune <- prune_map(names_file, get_map(list_file))
                ref_map_prune <- prune_map(names_file, ref_map_full)

                confusion <- cpp_confusion_matrix(test_map_prune, ref_map_prune)
                mcc_curve[(ref-1)*30 + r, f] <- mcc(confusion)
            }
            print(f)
        }
    }
    return(mcc_curve)
}

mcc_fn <- get_all_v_all_mcc("fn")
mcc_nn <- get_all_v_all_mcc("nn")
mcc_an <- get_all_v_all_mcc("an")

stripchart(data.frame(mcc_fn[1:60,]), vertical=T)
stripchart(data.frame(mcc_an[1:60,]), vertical=T)
stripchart(data.frame(mcc_nn[1:60,]), vertical=T)

