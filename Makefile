print-%:
	@echo '$*=$($*)'

data/raw/canada_soil.fasta : code/get_roesch_data.R
	R -e "source('code/get_roesch_data.R')"

data/he/canada_soil.good.unique.pick.redundant.fasta : code/get_he_data.batch data/raw/canada_soil.fasta
	mothur code/get_he_data.batch



NEIGHBOR = an nn fn
FRACTION = 0.2 0.4 0.6 0.8 1.0
REP = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30

HE_BOOTSTRAP_FASTA = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP), $F_$R.fasta))))
#data/he/he_0.2_02.fasta

$(HE_BOOTSTRAP_FASTA) : code/generate_samples.R data/he/canada_soil.good.unique.pick.redundant.fasta
	$(eval BASE=$(patsubst data/he/he_%.fasta,%,$@))
	$(eval R=$(lastword $(subst _, ,$(BASE))))
	$(eval F=$(firstword $(subst _, ,$(BASE))))
	R -e "source('code/generate_samples.R'); generate_indiv_samples('data/he/canada_soil.good.unique.pick.redundant.fasta', 'data/he/he', $F, '$R')"



HE_UNIQUE_FASTA = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP), $F_$R.unique.fasta)))
.SECONDEXPANSION:
$(HE_UNIQUE_FASTA) : $$(subst unique.fasta,fasta, $$@)
	mothur "#unique.seqs(fasta=$<)"

HE_NAMES = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP), $F_$R.names)))
.SECONDEXPANSION:
$(HE_NAMES) : $$(subst names,unique.fasta, $$@)

HE_DISTANCE = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP), $F_$R.unique.dist)))
.SECONDEXPANSION:
$(HE_DISTANCE) : $$(subst dist,fasta, $$@)
	mothur "#pairwise.seqs(fasta=$<, processors=8, cutoff=0.20)"




HE_AN_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.unique.an.list)))
.SECONDEXPANSION:
$(HE_AN_LIST) : $$(subst .an.list,.dist, $$@) $$(subst unique.an.list,names, $$@) code/run_an.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_an.sh $(DIST) $(NAMES)

HE_NN_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.unique.nn.list))) 
.SECONDEXPANSION:
$(HE_NN_LIST) : $$(subst .nn.list,.dist, $$@) $$(subst unique.nn.list,names, $$@) code/run_nn.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_nn.sh $(DIST) $(NAMES)

HE_FN_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.unique.fn.list))) 
.SECONDEXPANSION:
$(HE_FN_LIST) : $$(subst .fn.list,.dist, $$@) $$(subst unique.fn.list,names, $$@) code/run_fn.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_fn.sh $(DIST) $(NAMES)

HE_NEIGHBOR_LIST = $(HE_AN_LIST) $(HE_NN_LIST) $(HE_FN_LIST) 


HE_DGC_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.dgc.list)))
.SECONDEXPANSION:
$(HE_DGC_LIST) : $$(subst dgc.list,fasta, $$@) code/run_dgc.sh code/dgc.params.txt
	bash code/run_dgc.sh $<

HE_AGC_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.agc.list)))
.SECONDEXPANSION:
$(HE_AGC_LIST) : $$(subst agc.list,fasta, $$@) code/run_agc.sh code/agc.params.txt
	bash code/run_agc.sh $<

HE_CLOSED_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.closed.list)))
.SECONDEXPANSION:
$(HE_CLOSED_LIST) : $$(subst closed.list,fasta, $$@) code/run_closed.sh code/closedref.params.txt
	bash code/run_closed.sh $<

HE_OPEN_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.open.list)))
.SECONDEXPANSION:
$(HE_OPEN_LIST) : $$(subst open.list,fasta, $$@) code/run_open.sh code/openref.params.txt
	bash code/run_open.sh $<

HE_SWARM_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.swarm.list)))
.SECONDEXPANSION:
$(HE_SWARM_LIST) : $$(subst swarm.list,unique.fasta, $$@) $$(subst swarm.list,names, $$@) code/cluster_swarm.R
	$(eval FASTA=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	R -e 'source("code/cluster_swarm.R"); get_mothur_list("$(FASTA)", "$(NAMES)")'

HE_GREEDY_LIST = $(HE_DGC_LIST) $(HE_AGC_LIST) $(HE_OPEN_LIST) $(HE_CLOSED_LIST) $(HE_SWARM_LIST)


HE_NEIGHBOR_SENSSPEC = $(subst list,sensspec, $(HE_NEIGHBOR_LIST))
.SECONDEXPANSION:
$(HE_NEIGHBOR_SENSSPEC) : $$(addsuffix .dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@)
	$(eval LIST=$(word 2,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), label=0.03, outputdir=data/he)"

HE_GREEDY_SENSSPEC = $(subst list,sensspec, $(HE_GREEDY_LIST))
.SECONDEXPANSION:
$(HE_GREEDY_SENSSPEC) : $$(addsuffix .unique.dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@)
	$(eval LIST=$(word 2,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), label=userLabel, cutoff=0.03, outputdir=data/he)"


HE_REF_MCC = data/he/he.fn.ref_mcc data/he/he.nn.ref_mcc data/he/he.an.ref_mcc data/he/he.agc.ref_mcc data/he/he.dgc.ref_mcc data/he/he.closed.ref_mcc data/he/he.open.ref_mcc data/he/he.swarm.ref_mcc
data/he/he.an.ref_mcc : code/reference_mcc.R $(HE_AN_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*unique.an.list', 'he_1.0.*unique.an.list', 'he.*names', 'data/he/he.an.ref_mcc')"

data/he/he.fn.ref_mcc : code/reference_mcc.R $(HE_FN_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*unique.fn.list', 'he_1.0.*unique.fn.list', 'he.*names', 'data/he/he.fn.ref_mcc')"

data/he/he.nn.ref_mcc : code/reference_mcc.R $(HE_NN_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*unique.nn.list', 'he_1.0.*unique.nn.list', 'he.*names', 'data/he/he.nn.ref_mcc')"

data/he/he.closed.ref_mcc : code/reference_mcc.R $(HE_CLOSED_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*closed.list', 'he_1.0.*closed.list', 'he.*names', 'data/he/he.closed.ref_mcc')"

data/he/he.open.ref_mcc : code/reference_mcc.R $(HE_OPEN_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*open.list', 'he_1.0.*open.list', 'he.*names', 'data/he/he.open.ref_mcc')"

data/he/he.agc.ref_mcc : code/reference_mcc.R $(HE_AGC_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*agc.list', 'he_1.0.*agc.list', 'he.*names', 'data/he/he.agc.ref_mcc')"

data/he/he.dgc.ref_mcc : code/reference_mcc.R $(HE_DGC_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*dgc.list', 'he_1.0.*dgc.list', 'he.*names', 'data/he/he.dgc.ref_mcc')"

data/he/he.swarm.ref_mcc : code/reference_mcc.R $(HE_SWARM_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*swarm.list', 'he_1.0.*swarm.list', 'he.*names', 'data/he/he.swarm.ref_mcc')"


data/he/he.an.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_AN_LIST)) 
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*an.sensspec', 'data/he/he.an.pool_sensspec')"

data/he/he.fn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_FN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*Fn.sensspec', 'data/he/he.fn.pool_sensspec')"

data/he/he.nn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_NN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*nn.sensspec', 'data/he/he.nn.pool_sensspec')"

data/he/he.dgc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_DGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*dgc.sensspec', 'data/he/he.dgc.pool_sensspec')"

data/he/he.agc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_AGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*agc.sensspec', 'data/he/he.agc.pool_sensspec')"

data/he/he.open.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_OPEN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*open.sensspec', 'data/he/he.open.pool_sensspec')"

data/he/he.closed.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_CLOSED_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*closed.sensspec', 'data/he/he.closed.pool_sensspec')"

data/he/he.swarm.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_SWARM_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*swarm.sensspec', 'data/he/he.swarm.pool_sensspec')"


HE_RAREFACTION = data/he/he.an.rarefaction data/he/he.nn.rarefaction data/he/he.fn.rarefaction data/he/he.agc.rarefaction data/he/he.dgc.rarefaction data/he/he.closed.rarefaction data/he/he.open.rarefaction data/he/he.swarm.rarefaction

data/he/he.an.rarefaction : $(HE_AN_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('unique.an', 'data/he')"

data/he/he.nn.rarefaction : $(HE_NN_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('unique.nn', 'data/he')"

data/he/he.fn.rarefaction : $(HE_FN_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('unique.fn', 'data/he')"

data/he/he.agc.rarefaction : $(HE_AGC_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('agc', 'data/he')"

data/he/he.dgc.rarefaction : $(HE_DGC_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('dgc', 'data/he')"

data/he/he.closed.rarefaction : $(HE_CLOSED_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('closed', 'data/he')"

data/he/he.open.rarefaction : $(HE_OPEN_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('open', 'data/he')"

data/he/he.swarm.rarefaction : $(HE_SWARM_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('swarm', 'data/he')"

