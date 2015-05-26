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
HE_AN_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.unique.an.list)))
HE_NN_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.unique.nn.list))) 
HE_FN_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.unique.fn.list))) 
HE_NEIGHBOR_LIST = $(HE_AN_LIST) $(HE_NN_LIST) $(HE_FN_LIST)


.SECONDEXPANSION:
$(HE_DISTANCE) : $$(subst unique.dist,fasta, $$@) code/run_he_cluster.sh
	bash code/run_he_cluster.sh $<

.SECONDEXPANSION:
$(HE_LIST) : $$(addsuffix .dist $$(basename $$(basename $$@)))



HE_NEIGHBOR_SENSSPEC = $(subst list,sensspec, $(HE_NEIGHBOR_LIST))

.SECONDEXPANSION:
$(HE_NEIGHBOR_SENSSPEC) : $$(addsuffix .dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@)
	$(eval LIST=$(word 2,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), label=0.03, outputdir=data/he)"
