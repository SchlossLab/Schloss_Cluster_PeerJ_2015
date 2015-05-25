canada_soil.fasta : get_roesch_data.R
	R CMD BATCH get_roesch_data.R
     
canada_soil.good.unique.pick.fasta canada_soil.good.pick.names : get_he_data.batch canada_soil.fasta
	mothur get_he_data.batch

