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


HE_DISTANCE = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP), $F_$R.unique.dist)))
HE_NAMES = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP), $F_$R.names)))
HE_AN_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.unique.an.list)))
HE_NN_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.unique.nn.list))) 
HE_FN_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.unique.fn.list))) 


.SECONDEXPANSION:
$(HE_NAMES) : $$(subst names,fasta, $$@)
	mothur "#unique.seqs(fasta=$<)"

.SECONDEXPANSION:
$(HE_DISTANCE) : $$(subst unique.dist,fasta, $$@) code/run_he_cluster.sh
	bash code/run_he_cluster.sh $<

.SECONDEXPANSION:
$(HE_AN_LIST) : $$(subst unique.an.list,fasta, $$@) $$(subst unique.an.list,names, $$@) code/run_he_cluster.sh
	bash code/run_he_cluster.sh $<

.SECONDEXPANSION:
$(HE_NN_LIST) : $$(subst unique.nn.list,fasta, $$@) $$(subst unique.nn.list,names, $$@) code/run_he_cluster.sh
	bash code/run_he_cluster.sh $<

.SECONDEXPANSION:
$(HE_FN_LIST) : $$(subst unique.fn.list,fasta, $$@) $$(subst unique.fn.list,names, $$@) code/run_he_cluster.sh
	bash code/run_he_cluster.sh $<

HE_DGC_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.dgc.list)))
.SECONDEXPANSION:
$(HE_DGC_LIST) : $$(subst dgc.list,fasta, $$@) code/run_dgc.sh code/dgc.params.txt
	bash code/run_dgc.sh $<

HE_AGC_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.agc.list)))
.SECONDEXPANSION:
$(HE_AGC_LIST) : $$(subst agc.list,fasta, $$@) code/run_agc.sh code/agc.params.txt
	bash code/run_agc.sh $<

HE_CLOSED_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.closed.list)))
$(HE_CLOSED_LIST) : $$(subst closed.list,fasta, $$@) code/run_closed.sh code/closedref.params.txt
	bash code/run_closed.sh $<

HE_OPEN_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.open.list)))
$(HE_OPEN_LIST) : $$(subst open.list,fasta, $$@) code/run_open.sh code/openref.params.txt
	bash code/run_open.sh $<


HE_NEIGHBOR_LIST = $(HE_AN_LIST) $(HE_NN_LIST) $(HE_FN_LIST) 
HE_NEIGHBOR_SENSSPEC = $(subst list,sensspec, $(HE_NEIGHBOR_LIST))

.SECONDEXPANSION:
$(HE_NEIGHBOR_SENSSPEC) : $$(addsuffix .dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@)
	$(eval LIST=$(word 2,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), label=0.03, outputdir=data/he)"

HE_QIIME_LIST = $(HE_AGC_LIST) $(HE_DGC_LIST) $(HE_OPEN_LIST) $(HE_CLOSED_LIST)
HE_QIIME_SENSSPEC = $(subst list,sensspec, $(HE_QIIME_LIST))

.SECONDEXPANSION:
$(HE_QIIME_SENSSPEC) : $$(addsuffix .unique.dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@)
	$(eval LIST=$(word 2,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), label=userLabel, cutoff=0.03, outputdir=data/he)"


HE_REF_MCC = data/he/he.fn.ref_mcc data/he/he.nn.ref_mcc data/he/he.an.ref_mcc data/he/he.agc.ref_mcc data/he/he.dgc.ref_mcc data/he/he.closed.ref_mcc data/he/he.open.ref_mcc
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

