data/raw/canada_soil.fasta : code/get_roesch_data.R
	R -e "source(code/get_roesch_data.R)"

data/he/canada_soil.good.unique.pick.redundant.fasta : code/get_he_data.batch data/raw/canada_soil.fasta
	mothur code/get_he_data.batch

data/he/he.generate_samples : code/generate_samples.R data/he/canada_soil.good.unique.pick.redundant.fasta
	R -e "source(code/generate_samples.R); generate_samples("data/he/canada_soil.good.unique.pick.redundant.fasta", "data/he/he")

