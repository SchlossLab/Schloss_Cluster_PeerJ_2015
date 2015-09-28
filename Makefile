print-%:
	@echo '$*=$($*)'

RAW = data/raw/
$(RAW)canada_soil.fasta : code/get_roesch_data.R
	R -e "source('code/get_roesch_data.R')"

data/he/canada_soil.good.unique.pick.redundant.fasta : code/get_he_data.batch $(RAW)canada_soil.fasta
	mothur code/get_he_data.batch



NEIGHBOR = an nn fn
FRACTION = 0.2 0.4 0.6 0.8 1.0
REP = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30

HE_BOOTSTRAP_FASTA = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP), $F_$R.fasta)))

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
$(HE_DGC_LIST) : $$(subst dgc.list,fasta, $$@) code/run_dgc.sh code/dgc.params.txt code/biom_to_list.R
	bash code/run_dgc.sh $<

HE_AGC_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.agc.list)))
.SECONDEXPANSION:
$(HE_AGC_LIST) : $$(subst agc.list,fasta, $$@) code/run_agc.sh code/agc.params.txt code/biom_to_list.R
	bash code/run_agc.sh $<

HE_CLOSED_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.closed.list)))
.SECONDEXPANSION:
$(HE_CLOSED_LIST) : $$(subst closed.list,fasta, $$@) code/run_closed.sh code/closedref.params.txt code/biom_to_list.R
	bash code/run_closed.sh $<

HE_OPEN_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.open.list)))
.SECONDEXPANSION:
$(HE_OPEN_LIST) : $$(subst open.list,fasta, $$@) code/run_open.sh code/openref.params.txt code/biom_to_list.R
	bash code/run_open.sh $<

HE_SWARM_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.swarm.list)))
.SECONDEXPANSION:
$(HE_SWARM_LIST) : $$(subst swarm.list,unique.fasta, $$@) $$(subst swarm.list,names, $$@) code/cluster_swarm.R
	$(eval FASTA=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	R -e 'source("code/cluster_swarm.R"); get_mothur_list("$(FASTA)", "$(NAMES)")'

HE_VDGC_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.vdgc.list)))
.SECONDEXPANSION:
$(HE_VDGC_LIST) : $$(subst vdgc.list,fasta, $$@) code/run_vdgc_clust.sh code/uc_to_list.R
	bash code/run_vdgc_clust.sh $<

HE_VAGC_LIST = $(addprefix data/he/he_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.vagc.list)))
.SECONDEXPANSION:
$(HE_VAGC_LIST) : $$(subst vagc.list,fasta, $$@) code/run_vagc_clust.sh code/uc_to_list.R
	bash code/run_vagc_clust.sh $<


HE_GREEDY_LIST = $(HE_DGC_LIST) $(HE_AGC_LIST) $(HE_OPEN_LIST) $(HE_CLOSED_LIST) $(HE_SWARM_LIST) $(HE_VDGC_LIST) $(HE_VAGC_LIST)


HE_NEIGHBOR_SENSSPEC = $(subst list,sensspec, $(HE_NEIGHBOR_LIST))
.SECONDEXPANSION:
$(HE_NEIGHBOR_SENSSPEC) : $$(addsuffix .dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@) $$(addsuffix .names,$$(basename $$(basename $$(basename $$@))))
	$(eval LIST=$(word 2,$^))
	$(eval NAMES=$(word 3,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), name=$(NAMES), label=0.03, outputdir=data/he)"

HE_GREEDY_SENSSPEC = $(subst list,sensspec, $(HE_GREEDY_LIST))
.SECONDEXPANSION:
$(HE_GREEDY_SENSSPEC) : $$(addsuffix .unique.dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@) $$(addsuffix .names,$$(basename $$(basename $$@)))
	$(eval LIST=$(word 2,$^))
	$(eval NAMES=$(word 3,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), name=$(NAMES), label=userLabel, cutoff=0.03, outputdir=data/he)"


HE_REF_MCC = data/he/he.fn.ref_mcc data/he/he.nn.ref_mcc data/he/he.an.ref_mcc data/he/he.agc.ref_mcc data/he/he.dgc.ref_mcc data/he/he.closed.ref_mcc data/he/he.open.ref_mcc data/he/he.swarm.ref_mcc data/he/he.vdgc.ref_mcc data/he/he.vagc.ref_mcc
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

data/he/he.vdgc.ref_mcc : code/reference_mcc.R $(HE_VDGC_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*vdgc.list', 'he_1.0.*vdgc.list', 'he.*names', 'data/he/he.vdgc.ref_mcc')"

data/he/he.vagc.ref_mcc : code/reference_mcc.R $(HE_VAGC_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*vagc.list', 'he_1.0.*vagc.list', 'he.*names', 'data/he/he.vagc.ref_mcc')"




HE_POOL_SENSSPEC = data/he/he.an.pool_sensspec data/he/he.fn.pool_sensspec data/he/he.nn.pool_sensspec data/he/he.dgc.pool_sensspec data/he/he.agc.pool_sensspec data/he/he.open.pool_sensspec data/he/he.closed.pool_sensspec data/he/he.swarm.pool_sensspec data/he/he.vdgc.pool_sensspec data/he/he.vagc.pool_sensspec
data/he/he.an.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_AN_LIST)) 
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*an.sensspec', 'data/he/he.an.pool_sensspec')"

data/he/he.fn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_FN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*fn.sensspec', 'data/he/he.fn.pool_sensspec')"

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

data/he/he.vdgc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_VDGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*vdgc.sensspec', 'data/he/he.vdgc.pool_sensspec')"

data/he/he.vagc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_VAGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*vagc.sensspec', 'data/he/he.vagc.pool_sensspec')"


HE_RAREFACTION = data/he/he.an.rarefaction data/he/he.nn.rarefaction data/he/he.fn.rarefaction data/he/he.agc.rarefaction data/he/he.dgc.rarefaction data/he/he.closed.rarefaction data/he/he.open.rarefaction data/he/he.swarm.rarefaction data/he/he.vdgc.rarefaction data/he/he.vagc.rarefaction

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

data/he/he.vdgc.rarefaction : $(HE_VDGC_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('vdgc', 'data/he')"

data/he/he.vagc.rarefaction : $(HE_VAGC_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('vagc', 'data/he')"



#get the silva reference alignment
REFS = data/references/
$(REFS)silva.bacteria.align :
	wget -N -P $(REFS) http:/www.mothur.org/w/images/2/27/Silva.nr_v119.tgz; \
	tar xvzf $(REFS)Silva.nr_v119.tgz -C $(REFS);
	mothur "#get.lineage(fasta=$(REFS)silva.nr_v119.align, taxonomy=$(REFS)silva.nr_v119.tax, taxon=Bacteria)";
	mv $(REFS)silva.nr_v119.pick.align $(REFS)silva.bacteria.align; \
	rm $(REFS)README.html; \
	rm $(REFS)README.Rmd; \
	rm $(REFS)silva.nr_v119.*

$(REFS)silva.bact_archaea.align : $(REFS)silva.bacteria.align
	wget -N -P $(REFS) http:/www.mothur.org/w/images/2/27/Silva.nr_v119.tgz; \
	tar xvzf $(REFS)Silva.nr_v119.tgz -C $(REFS); 
	mothur "#get.lineage(fasta=$(REFS)silva.nr_v119.align, taxonomy=$(REFS)silva.nr_v119.tax, taxon=Archaea)";
	cp $(REFS)silva.bacteria.align $(REFS)silva.bact_archaea.align;
	cat $(REFS)silva.nr_v119.pick.align >> $(REFS)silva.bact_archaea.align; \
	rm $(REFS)README.html; \
	rm $(REFS)README.Rmd; \
	rm $(REFS)silva.nr_v119.*


data/schloss/canada_soil.good.unique.pick.redundant.fasta : data/he/canada_soil.good.unique.pick.redundant.fasta
	cp $< $@

data/schloss/canada_soil.good.unique.pick.redundant.good.filter.fasta : code/get_schloss_data.batch data/schloss/canada_soil.good.unique.pick.redundant.fasta
	mothur code/get_schloss_data.batch
	rm data/schloss/canada_soil.filter
	rm data/schloss/canada_soil.good.unique.pick.redundant.bad.accnos
	rm data/schloss/canada_soil.good.unique.pick.redundant.good.align
	rm data/schloss/canada_soil.good.unique.pick.redundant.flip.accnos
	rm data/schloss/canada_soil.good.unique.pick.redundant.align.report
	rm data/schloss/canada_soil.good.unique.pick.redundant.align


SCHL_BOOTSTRAP_FASTA = $(addprefix data/schloss/schloss_, $(foreach F,$(FRACTION), $(foreach R,$(REP), $F_$R.fasta)))
$(SCHL_BOOTSTRAP_FASTA) : code/generate_samples.R data/schloss/canada_soil.good.unique.pick.redundant.good.filter.fasta
	$(eval BASE=$(patsubst data/schloss/schloss_%.fasta,%,$@))
	$(eval R=$(lastword $(subst _, ,$(BASE))))
	$(eval F=$(firstword $(subst _, ,$(BASE))))
	R -e "source('code/generate_samples.R'); generate_indiv_samples('data/schloss/canada_soil.good.unique.pick.redundant.good.filter.fasta', 'data/schloss/schloss', $F, '$R')"


SCHL_UNIQUE_FASTA = $(addprefix data/schloss/schloss_, $(foreach F,$(FRACTION), $(foreach R,$(REP), $F_$R.unique.fasta)))
.SECONDEXPANSION:
$(SCHL_UNIQUE_FASTA) : $$(subst unique.fasta,fasta, $$@)
	mothur "#unique.seqs(fasta=$<)"

SCHL_NAMES = $(addprefix data/schloss/schloss_, $(foreach F,$(FRACTION), $(foreach R,$(REP), $F_$R.names)))
.SECONDEXPANSION:
$(SCHL_NAMES) : $$(subst names,unique.fasta, $$@)

SCHL_DISTANCE = $(addprefix data/schloss/schloss_, $(foreach F,$(FRACTION), $(foreach R,$(REP), $F_$R.unique.dist)))
.SECONDEXPANSION:
$(SCHL_DISTANCE) : $$(subst dist,fasta, $$@)
	mothur "#dist.seqs(fasta=$<, processors=8, cutoff=0.20)"



SCHL_AN_LIST = $(addprefix data/schloss/schloss_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.unique.an.list)))
.SECONDEXPANSION:
$(SCHL_AN_LIST) : $$(subst .an.list,.dist, $$@) $$(subst unique.an.list,names, $$@) code/run_an.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_an.sh $(DIST) $(NAMES)

SCHL_NN_LIST = $(addprefix data/schloss/schloss_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.unique.nn.list))) 
.SECONDEXPANSION:
$(SCHL_NN_LIST) : $$(subst .nn.list,.dist, $$@) $$(subst unique.nn.list,names, $$@) code/run_nn.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_nn.sh $(DIST) $(NAMES)

SCHL_FN_LIST = $(addprefix data/schloss/schloss_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.unique.fn.list))) 
.SECONDEXPANSION:
$(SCHL_FN_LIST) : $$(subst .fn.list,.dist, $$@) $$(subst unique.fn.list,names, $$@) code/run_fn.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_fn.sh $(DIST) $(NAMES)

SCHL_NEIGHBOR_LIST = $(SCHL_AN_LIST) $(SCHL_NN_LIST) $(SCHL_FN_LIST) 


SCHL_DEGAP_FASTA = $(subst fasta,ng.fasta,$(SCHL_BOOTSTRAP_FASTA))
$(SCHL_DEGAP_FASTA) : $$(subst ng.fasta,fasta, $$@)
	mothur "#degap.seqs(fasta=$<)"

SCHL_DGC_LIST = $(addprefix data/schloss/schloss_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.dgc.list)))
.SECONDEXPANSION:
$(SCHL_DGC_LIST) : $$(subst dgc.list,ng.fasta, $$@) code/run_dgc.sh code/dgc.params.txt code/biom_to_list.R
	bash code/run_dgc.sh $<
	$(eval NG_LIST=$(subst dgc.list,ng.dgc.list,$@))
	mv $(NG_LIST) $@

SCHL_AGC_LIST = $(addprefix data/schloss/schloss_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.agc.list)))
.SECONDEXPANSION:
$(SCHL_AGC_LIST) : $$(subst agc.list,ng.fasta, $$@) code/run_agc.sh code/agc.params.txt code/biom_to_list.R
	bash code/run_agc.sh $<
	$(eval NG_LIST=$(subst agc.list,ng.agc.list,$@))
	mv $(NG_LIST) $@

SCHL_CLOSED_LIST = $(addprefix data/schloss/schloss_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.closed.list)))
.SECONDEXPANSION:
$(SCHL_CLOSED_LIST) : $$(subst closed.list,ng.fasta, $$@) code/run_closed.sh code/closedref.params.txt code/biom_to_list.R
	bash code/run_closed.sh $<
	$(eval NG_LIST=$(subst closed.list,ng.closed.list,$@))
	mv $(NG_LIST) $@

SCHL_OPEN_LIST = $(addprefix data/schloss/schloss_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.open.list)))
.SECONDEXPANSION:
$(SCHL_OPEN_LIST) : $$(subst open.list,ng.fasta, $$@) code/run_open.sh code/openref.params.txt code/biom_to_list.R
	bash code/run_open.sh $<
	$(eval NG_LIST=$(subst open.list,ng.open.list,$@))
	mv $(NG_LIST) $@

SCHL_SWARM_LIST = $(addprefix data/schloss/schloss_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.swarm.list)))
.SECONDEXPANSION:
$(SCHL_SWARM_LIST) : $$(subst swarm.list,unique.fasta, $$@) $$(subst swarm.list,names, $$@) code/cluster_swarm.R
	$(eval FASTA=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	R -e 'source("code/cluster_swarm.R"); get_mothur_list("$(FASTA)", "$(NAMES)")'

SCHL_VDGC_LIST = $(addprefix data/schloss/schloss_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.vdgc.list)))
.SECONDEXPANSION:
$(SCHL_VDGC_LIST) : $$(subst vdgc.list,ng.fasta, $$@) code/run_vdgc_clust.sh code/uc_to_list.R
	bash code/run_vdgc_clust.sh $<

SCHL_VAGC_LIST = $(addprefix data/schloss/schloss_, $(foreach F,$(FRACTION), $(foreach R,$(REP),  $F_$R.vagc.list)))
.SECONDEXPANSION:
$(SCHL_VAGC_LIST) : $$(subst vagc.list,ng.fasta, $$@) code/run_vagc_clust.sh code/uc_to_list.R
	bash code/run_vagc_clust.sh $<


SCHL_GREEDY_LIST = $(SCHL_DGC_LIST) $(SCHL_AGC_LIST) $(SCHL_OPEN_LIST) $(SCHL_CLOSED_LIST) $(SCHL_SWARM_LIST) $(SCHL_VDGC_LIST) $(SCHL_VAGC_LIST)


SCHL_NEIGHBOR_SENSSPEC = $(subst list,sensspec, $(SCHL_NEIGHBOR_LIST))
.SECONDEXPANSION:
$(SCHL_NEIGHBOR_SENSSPEC) : $$(addsuffix .dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@) $$(addsuffix .names,$$(basename $$(basename $$(basename $$@))))
	$(eval LIST=$(word 2,$^))
	$(eval NAMES=$(word 3,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), name=$(NAMES), label=0.03, outputdir=data/schloss)"

SCHL_GREEDY_SENSSPEC = $(subst list,sensspec, $(SCHL_GREEDY_LIST))
.SECONDEXPANSION:
$(SCHL_GREEDY_SENSSPEC) : $$(addsuffix .unique.dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@) $$(addsuffix .names,$$(basename $$(basename $$@)))
	$(eval LIST=$(word 2,$^))
	$(eval NAMES=$(word 3,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), name=$(NAMES), label=userLabel, cutoff=0.03, outputdir=data/schloss)"


SCHL_REF_MCC = data/schloss/schloss.fn.ref_mcc data/schloss/schloss.nn.ref_mcc data/schloss/schloss.an.ref_mcc data/schloss/schloss.agc.ref_mcc data/schloss/schloss.dgc.ref_mcc data/schloss/schloss.closed.ref_mcc data/schloss/schloss.open.ref_mcc data/schloss/schloss.swarm.ref_mcc data/schloss/schloss.vdgc.ref_mcc data/schloss/schloss.vagc.ref_mcc
data/schloss/schloss.an.ref_mcc : code/reference_mcc.R $(SCHL_AN_LIST) $(SCHL_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/schloss/', 'schloss.*unique.an.list', 'schloss_1.0.*unique.an.list', 'schloss.*names', 'data/schloss/schloss.an.ref_mcc')"

data/schloss/schloss.fn.ref_mcc : code/reference_mcc.R $(SCHL_FN_LIST) $(SCHL_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/schloss/', 'schloss.*unique.fn.list', 'schloss_1.0.*unique.fn.list', 'schloss.*names', 'data/schloss/schloss.fn.ref_mcc')"

data/schloss/schloss.nn.ref_mcc : code/reference_mcc.R $(SCHL_NN_LIST) $(SCHL_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/schloss/', 'schloss.*unique.nn.list', 'schloss_1.0.*unique.nn.list', 'schloss.*names', 'data/schloss/schloss.nn.ref_mcc')"

data/schloss/schloss.closed.ref_mcc : code/reference_mcc.R $(SCHL_CLOSED_LIST) $(SCHL_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/schloss/', 'schloss.*closed.list', 'schloss_1.0.*closed.list', 'schloss.*names', 'data/schloss/schloss.closed.ref_mcc')"

data/schloss/schloss.open.ref_mcc : code/reference_mcc.R $(SCHL_OPEN_LIST) $(SCHL_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/schloss/', 'schloss.*open.list', 'schloss_1.0.*open.list', 'schloss.*names', 'data/schloss/schloss.open.ref_mcc')"

data/schloss/schloss.agc.ref_mcc : code/reference_mcc.R $(SCHL_AGC_LIST) $(SCHL_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/schloss/', 'schloss.*agc.list', 'schloss_1.0.*agc.list', 'schloss.*names', 'data/schloss/schloss.agc.ref_mcc')"

data/schloss/schloss.dgc.ref_mcc : code/reference_mcc.R $(SCHL_DGC_LIST) $(SCHL_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/schloss/', 'schloss.*dgc.list', 'schloss_1.0.*dgc.list', 'schloss.*names', 'data/schloss/schloss.dgc.ref_mcc')"

data/schloss/schloss.swarm.ref_mcc : code/reference_mcc.R $(SCHL_SWARM_LIST) $(SCHL_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/schloss/', 'schloss.*swarm.list', 'schloss_1.0.*swarm.list', 'schloss.*names', 'data/schloss/schloss.swarm.ref_mcc')"

data/schloss/schloss.vdgc.ref_mcc : code/reference_mcc.R $(SCHL_VDGC_LIST) $(SCHL_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/schloss/', 'schloss.*vdgc.list', 'schloss_1.0.*vdgc.list', 'schloss.*names', 'data/schloss/schloss.vdgc.ref_mcc')"

data/schloss/schloss.vagc.ref_mcc : code/reference_mcc.R $(SCHL_VAGC_LIST) $(SCHL_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/schloss/', 'schloss.*vagc.list', 'schloss_1.0.*vagc.list', 'schloss.*names', 'data/schloss/schloss.vagc.ref_mcc')"


SCHL_POOL_SENSSPEC = data/schloss/schloss.an.pool_sensspec data/schloss/schloss.fn.pool_sensspec data/schloss/schloss.nn.pool_sensspec data/schloss/schloss.dgc.pool_sensspec data/schloss/schloss.agc.pool_sensspec data/schloss/schloss.open.pool_sensspec data/schloss/schloss.closed.pool_sensspec data/schloss/schloss.swarm.pool_sensspec data/schloss/schloss.vdgc.pool_sensspec data/schloss/schloss.vagc.pool_sensspec
data/schloss/schloss.an.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(SCHL_AN_LIST)) 
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/schloss', 'schloss_.*an.sensspec', 'data/schloss/schloss.an.pool_sensspec')"

data/schloss/schloss.fn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(SCHL_FN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/schloss', 'schloss_.*fn.sensspec', 'data/schloss/schloss.fn.pool_sensspec')"

data/schloss/schloss.nn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(SCHL_NN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/schloss', 'schloss_.*nn.sensspec', 'data/schloss/schloss.nn.pool_sensspec')"

data/schloss/schloss.dgc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(SCHL_DGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/schloss', 'schloss_.*dgc.sensspec', 'data/schloss/schloss.dgc.pool_sensspec')"

data/schloss/schloss.agc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(SCHL_AGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/schloss', 'schloss_.*agc.sensspec', 'data/schloss/schloss.agc.pool_sensspec')"

data/schloss/schloss.open.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(SCHL_OPEN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/schloss', 'schloss_.*open.sensspec', 'data/schloss/schloss.open.pool_sensspec')"

data/schloss/schloss.closed.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(SCHL_CLOSED_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/schloss', 'schloss_.*closed.sensspec', 'data/schloss/schloss.closed.pool_sensspec')"

data/schloss/schloss.swarm.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(SCHL_SWARM_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/schloss', 'schloss_.*swarm.sensspec', 'data/schloss/schloss.swarm.pool_sensspec')"

data/schloss/schloss.vdgc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(SCHL_VDGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/schloss', 'schloss_.*vdgc.sensspec', 'data/schloss/schloss.vdgc.pool_sensspec')"

data/schloss/schloss.vagc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(SCHL_VAGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/schloss', 'schloss_.*vadc.sensspec', 'data/schloss/schloss.vagc.pool_sensspec')"


SCHL_RAREFACTION = data/schloss/schloss.an.rarefaction data/schloss/schloss.nn.rarefaction data/schloss/schloss.fn.rarefaction data/schloss/schloss.agc.rarefaction data/schloss/schloss.dgc.rarefaction data/schloss/schloss.closed.rarefaction data/schloss/schloss.open.rarefaction data/schloss/schloss.swarm.rarefaction data/schloss/schloss.vdgc.rarefaction data/schloss/schloss.vagc.rarefaction

data/schloss/schloss.an.rarefaction : $(SCHL_AN_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('unique.an', 'data/schloss')"

data/schloss/schloss.nn.rarefaction : $(SCHL_NN_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('unique.nn', 'data/schloss')"

data/schloss/schloss.fn.rarefaction : $(SCHL_FN_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('unique.fn', 'data/schloss')"

data/schloss/schloss.agc.rarefaction : $(SCHL_AGC_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('agc', 'data/schloss')"

data/schloss/schloss.dgc.rarefaction : $(SCHL_DGC_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('dgc', 'data/schloss')"

data/schloss/schloss.closed.rarefaction : $(SCHL_CLOSED_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('closed', 'data/schloss')"

data/schloss/schloss.open.rarefaction : $(SCHL_OPEN_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('open', 'data/schloss')"

data/schloss/schloss.swarm.rarefaction : $(SCHL_SWARM_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('swarm', 'data/schloss')"

data/schloss/schloss.vdgc.rarefaction : $(SCHL_VDGC_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('vdgc', 'data/schloss')"

data/schloss/schloss.vagc.rarefaction : $(SCHL_VAGC_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('vagc', 'data/schloss')"


#get the rdp training set data
$(REFS)trainset10_082014.pds.tax $(REFS)trainset10_082014.pds.fasta :
	wget -N -P $(REFS) http:/www.mothur.org/w/images/2/24/Trainset10_082014.pds.tgz; \
	tar xvzf $(REFS)Trainset10_082014.pds.tgz -C $(REFS);\
	mv $(REFS)trainset10_082014.pds/trainset10_082014.* $(REFS);\
	rm -rf $(REFS)trainset10_082014.pds

data/miseq/mouse.files : code/get_contigsfile.R
	wget -N -P data/miseq http:/www.mothur.org/MiSeqDevelopmentData/StabilityNoMetaG.tar; \
	tar xvf data/miseq/StabilityNoMetaG.tar -C data/miseq/; \
	gunzip -f data/miseq/*gz; \
	rm data/miseq/StabilityNoMetaG.tar; \
	R -e 'source("code/get_contigsfile.R");get_contigsfile("data/miseq")'




M_FRACTION = 0.05 0.1 0.15 0.2 1.0

data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta : code/process_mice.sh data/miseq/miseq.files data/references/silva.bacteria.align data/references/trainset10_082014.pds.fasta data/references/trainset10_082014.pds.tax
	bash code/process_mice.sh data/miseq/miseq.files

data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table : code/process_mice.sh data/miseq/miseq.files data/references/silva.bacteria.align data/references/trainset10_082014.pds.fasta data/references/trainset10_082014.pds.tax
	bash code/process_mice.sh data/miseq/miseq.files

data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pds.wang.pick.taxonomy : code/process_mice.sh data/miseq/miseq.files data/references/silva.bacteria.align data/references/trainset10_082014.pds.fasta data/references/trainset10_082014.pds.tax
	bash code/process_mice.sh data/miseq/miseq.files

data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.redundant.fasta : data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table
	mothur "#deunique.seqs(fasta=data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta,  count=data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table)"
	rm data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.redundant.groups

data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.redundant.fix.fasta : data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.redundant.fasta
	sed "s/_/-/g" < $< > $@

MISEQ_BOOTSTRAP_FASTA = $(addprefix data/miseq/miseq_, $(foreach F,$(M_FRACTION), $(foreach R,$(REP), $F_$R.fasta)))
$(MISEQ_BOOTSTRAP_FASTA) : code/generate_samples.R data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.redundant.fix.fasta
	$(eval BASE=$(patsubst data/miseq/miseq_%.fasta,%,$@))
	$(eval R=$(lastword $(subst _, ,$(BASE))))
	$(eval F=$(firstword $(subst _, ,$(BASE))))
	R -e "source('code/generate_samples.R'); generate_indiv_samples('data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.redundant.fix.fasta', 'data/miseq/miseq', $F, '$R')"


MISEQ_UNIQUE_FASTA = $(addprefix data/miseq/miseq_, $(foreach F,$(M_FRACTION), $(foreach R,$(REP), $F_$R.unique.fasta)))
.SECONDEXPANSION:
$(MISEQ_UNIQUE_FASTA) : $$(subst unique.fasta,fasta, $$@)
	mothur "#unique.seqs(fasta=$<)"

MISEQ_NAMES = $(addprefix data/miseq/miseq_, $(foreach F,$(M_FRACTION), $(foreach R,$(REP), $F_$R.names)))
.SECONDEXPANSION:
$(MISEQ_NAMES) : $$(subst names,unique.fasta, $$@)

MISEQ_DISTANCE = $(addprefix data/miseq/miseq_, $(foreach F,$(M_FRACTION), $(foreach R,$(REP), $F_$R.unique.dist)))
.SECONDEXPANSION:
$(MISEQ_DISTANCE) : $$(subst dist,fasta, $$@)
	mothur "#dist.seqs(fasta=$<, processors=8, cutoff=0.20)"



MISEQ_AN_LIST = $(addprefix data/miseq/miseq_, $(foreach F,$(M_FRACTION), $(foreach R,$(REP),  $F_$R.unique.an.list)))
.SECONDEXPANSION:
$(MISEQ_AN_LIST) : $$(subst .an.list,.dist, $$@) $$(subst unique.an.list,names, $$@) code/run_an.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_an.sh $(DIST) $(NAMES)

MISEQ_NN_LIST = $(addprefix data/miseq/miseq_, $(foreach F,$(M_FRACTION), $(foreach R,$(REP),  $F_$R.unique.nn.list))) 
.SECONDEXPANSION:
$(MISEQ_NN_LIST) : $$(subst .nn.list,.dist, $$@) $$(subst unique.nn.list,names, $$@) code/run_nn.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_nn.sh $(DIST) $(NAMES)

MISEQ_FN_LIST = $(addprefix data/miseq/miseq_, $(foreach F,$(M_FRACTION), $(foreach R,$(REP),  $F_$R.unique.fn.list))) 
.SECONDEXPANSION:
$(MISEQ_FN_LIST) : $$(subst .fn.list,.dist, $$@) $$(subst unique.fn.list,names, $$@) code/run_fn.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_fn.sh $(DIST) $(NAMES)

MISEQ_NEIGHBOR_LIST = $(MISEQ_AN_LIST) $(MISEQ_NN_LIST) $(MISEQ_FN_LIST) 


MISEQ_DEGAP_FASTA = $(subst fasta,ng.fasta,$(MISEQ_BOOTSTRAP_FASTA))
$(MISEQ_DEGAP_FASTA) : $$(subst ng.fasta,fasta, $$@)
	mothur "#degap.seqs(fasta=$<)"

MISEQ_DGC_LIST = $(addprefix data/miseq/miseq_, $(foreach F,$(M_FRACTION), $(foreach R,$(REP),  $F_$R.dgc.list)))
.SECONDEXPANSION:
$(MISEQ_DGC_LIST) : $$(subst dgc.list,ng.fasta, $$@) code/run_dgc.sh code/dgc.params.txt code/biom_to_list.R
	$(eval NG_LIST=$(subst dgc.list,ng.dgc.list,$@))
	bash code/run_dgc.sh $<
	mv $(NG_LIST) $@

MISEQ_AGC_LIST = $(addprefix data/miseq/miseq_, $(foreach F,$(M_FRACTION), $(foreach R,$(REP),  $F_$R.agc.list)))
.SECONDEXPANSION:
$(MISEQ_AGC_LIST) : $$(subst agc.list,ng.fasta, $$@) code/run_agc.sh code/agc.params.txt code/biom_to_list.R
	$(eval NG_LIST=$(subst agc.list,ng.agc.list,$@))
	bash code/run_agc.sh $<
	mv $(NG_LIST) $@

MISEQ_CLOSED_LIST = $(addprefix data/miseq/miseq_, $(foreach F,$(M_FRACTION), $(foreach R,$(REP),  $F_$R.closed.list)))
.SECONDEXPANSION:
$(MISEQ_CLOSED_LIST) : $$(subst closed.list,ng.fasta, $$@) code/run_closed.sh code/closedref.params.txt code/biom_to_list.R
	$(eval NG_LIST=$(subst closed.list,ng.closed.list,$@))
	bash code/run_closed.sh $<
	mv $(NG_LIST) $@

MISEQ_OPEN_LIST = $(addprefix data/miseq/miseq_, $(foreach F,$(M_FRACTION), $(foreach R,$(REP),  $F_$R.open.list)))
.SECONDEXPANSION:
$(MISEQ_OPEN_LIST) : $$(subst open.list,ng.fasta, $$@) code/run_open.sh code/openref.params.txt code/biom_to_list.R
	$(eval NG_LIST=$(subst open.list,ng.open.list,$@))
	bash code/run_open.sh $<
	mv $(NG_LIST) $@

MISEQ_SWARM_LIST = $(addprefix data/miseq/miseq_, $(foreach F,$(M_FRACTION), $(foreach R,$(REP),  $F_$R.swarm.list)))
.SECONDEXPANSION:
$(MISEQ_SWARM_LIST) : $$(subst swarm.list,unique.fasta, $$@) $$(subst swarm.list,names, $$@) code/cluster_swarm.R
	$(eval FASTA=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	R -e 'source("code/cluster_swarm.R"); get_mothur_list("$(FASTA)", "$(NAMES)")'

MISEQ_VDGC_LIST = $(addprefix data/miseq/miseq_, $(foreach F,$(M_FRACTION), $(foreach R,$(REP),  $F_$R.vdgc.list)))
.SECONDEXPANSION:
$(MISEQ_VDGC_LIST) : $$(subst vdgc.list,ng.fasta, $$@) code/run_vdgc_clust.sh code/uc_to_list.R
	bash code/run_vdgc_clust.sh $<

MISEQ_VAGC_LIST = $(addprefix data/miseq/miseq_, $(foreach F,$(M_FRACTION), $(foreach R,$(REP),  $F_$R.vagc.list)))
.SECONDEXPANSION:
$(MISEQ_VAGC_LIST) : $$(subst vagc.list,ng.fasta, $$@) code/run_vagc_clust.sh code/uc_to_list.R
	bash code/run_vagc_clust.sh $<

MISEQ_GREEDY_LIST = $(MISEQ_DGC_LIST) $(MISEQ_AGC_LIST) $(MISEQ_OPEN_LIST) $(MISEQ_CLOSED_LIST) $(MISEQ_SWARM_LIST) $(MISEQ_VDGC_LIST) $(MISEQ_VAGC_LIST)


MISEQ_NEIGHBOR_SENSSPEC = $(subst list,sensspec, $(MISEQ_NEIGHBOR_LIST))
.SECONDEXPANSION:
$(MISEQ_NEIGHBOR_SENSSPEC) : $$(addsuffix .dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@) $$(addsuffix .names,$$(basename $$(basename $$(basename $$@))))
	$(eval LIST=$(word 2,$^))
	$(eval NAMES=$(word 3,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), name=$(NAMES), label=0.03, outputdir=data/miseq)"

MISEQ_GREEDY_SENSSPEC = $(subst list,sensspec, $(MISEQ_GREEDY_LIST))
MISEQ_VAGC_SENSSPEC = $(subst list,sensspec, $(MISEQ_VAGC_LIST))
.SECONDEXPANSION:
$(MISEQ_GREEDY_SENSSPEC) : $$(addsuffix .unique.dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@) $$(addsuffix .names,$$(basename $$(basename $$@)))
	$(eval LIST=$(word 2,$^))
	$(eval NAMES=$(word 3,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), name=$(NAMES), label=userLabel, cutoff=0.03, outputdir=data/miseq)"


MISEQ_REF_MCC = data/miseq/miseq.fn.ref_mcc data/miseq/miseq.nn.ref_mcc data/miseq/miseq.an.ref_mcc data/miseq/miseq.agc.ref_mcc data/miseq/miseq.dgc.ref_mcc data/miseq/miseq.closed.ref_mcc data/miseq/miseq.open.ref_mcc data/miseq/miseq.swarm.ref_mcc data/miseq/miseq.vdgc.ref_mcc data/miseq/miseq.vagc.ref_mcc
data/miseq/miseq.an.ref_mcc : code/reference_mcc.R $(MISEQ_AN_LIST) $(MISEQ_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*unique.an.list', 'miseq_1.0.*unique.an.list', 'miseq.*names', 'data/miseq/miseq.an.ref_mcc')"

data/miseq/miseq.fn.ref_mcc : code/reference_mcc.R $(MISEQ_FN_LIST) $(MISEQ_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*unique.fn.list', 'miseq_1.0_.*unique.fn.list', 'miseq.*names', 'data/miseq/miseq.fn.ref_mcc')"

data/miseq/miseq.nn.ref_mcc : code/reference_mcc.R $(MISEQ_NN_LIST) $(MISEQ_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*unique.nn.list', 'miseq_1.0.*unique.nn.list', 'miseq.*names', 'data/miseq/miseq.nn.ref_mcc')"

data/miseq/miseq.closed.ref_mcc : code/reference_mcc.R $(MISEQ_CLOSED_LIST) $(MISEQ_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*closed.list', 'miseq_1.0.*closed.list', 'miseq.*names', 'data/miseq/miseq.closed.ref_mcc')"

data/miseq/miseq.open.ref_mcc : code/reference_mcc.R $(MISEQ_OPEN_LIST) $(MISEQ_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*open.list', 'miseq_1.0.*open.list', 'miseq.*names', 'data/miseq/miseq.open.ref_mcc')"

data/miseq/miseq.agc.ref_mcc : code/reference_mcc.R $(MISEQ_AGC_LIST) $(MISEQ_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*agc.list', 'miseq_1.0.*agc.list', 'miseq.*names', 'data/miseq/miseq.agc.ref_mcc')"

data/miseq/miseq.dgc.ref_mcc : code/reference_mcc.R $(MISEQ_DGC_LIST) $(MISEQ_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*dgc.list', 'miseq_1.0.*dgc.list', 'miseq.*names', 'data/miseq/miseq.dgc.ref_mcc')"

data/miseq/miseq.swarm.ref_mcc : code/reference_mcc.R $(MISEQ_SWARM_LIST) $(MISEQ_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*swarm.list', 'miseq_1.0.*swarm.list', 'miseq.*names', 'data/miseq/miseq.swarm.ref_mcc')"

data/miseq/miseq.vdgc.ref_mcc : code/reference_mcc.R $(miseq_VDGC_LIST) $(MISEQ_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*vdgc.list', 'miseq_1.0.*vdgc.list', 'miseq.*names', 'data/miseq/miseq.vdgc.ref_mcc')"

data/miseq/miseq.vagc.ref_mcc : code/reference_mcc.R $(miseq_VAGC_LIST) $(MISEQ_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*vagc.list', 'miseq_1.0.*vagc.list', 'miseq.*names', 'data/miseq/miseq.vagc.ref_mcc')"


MISEQ_POOL_SENSSPEC = data/miseq/miseq.an.pool_sensspec data/miseq/miseq.fn.pool_sensspec data/miseq/miseq.nn.pool_sensspec data/miseq/miseq.dgc.pool_sensspec data/miseq/miseq.agc.pool_sensspec data/miseq/miseq.open.pool_sensspec data/miseq/miseq.closed.pool_sensspec data/miseq/miseq.swarm.pool_sensspec data/miseq/miseq.vdgc.pool_sensspec data/miseq/miseq.vagc.pool_sensspec
data/miseq/miseq.an.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_AN_LIST)) 
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*an.sensspec', 'data/miseq/miseq.an.pool_sensspec')"

data/miseq/miseq.fn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_FN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*fn.sensspec', 'data/miseq/miseq.fn.pool_sensspec')"

data/miseq/miseq.nn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_NN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*nn.sensspec', 'data/miseq/miseq.nn.pool_sensspec')"

data/miseq/miseq.dgc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_DGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*dgc.sensspec', 'data/miseq/miseq.dgc.pool_sensspec')"

data/miseq/miseq.agc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_AGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*agc.sensspec', 'data/miseq/miseq.agc.pool_sensspec')"

data/miseq/miseq.open.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_OPEN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*open.sensspec', 'data/miseq/miseq.open.pool_sensspec')"

data/miseq/miseq.closed.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_CLOSED_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*closed.sensspec', 'data/miseq/miseq.closed.pool_sensspec')"

data/miseq/miseq.swarm.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_SWARM_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*swarm.sensspec', 'data/miseq/miseq.swarm.pool_sensspec')"

data/miseq/miseq.vdgc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_VDGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*vdgc.sensspec', 'data/miseq/miseq.vdgc.pool_sensspec')"

data/miseq/miseq.vagc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_VAGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*vagc.sensspec', 'data/miseq/miseq.vagc.pool_sensspec')"


MISEQ_RAREFACTION = data/miseq/miseq.an.rarefaction data/miseq/miseq.nn.rarefaction data/miseq/miseq.fn.rarefaction data/miseq/miseq.agc.rarefaction data/miseq/miseq.dgc.rarefaction data/miseq/miseq.closed.rarefaction data/miseq/miseq.open.rarefaction data/miseq/miseq.swarm.rarefaction data/miseq/miseq.vdgc.rarefaction data/miseq/miseq.vagc.rarefaction

data/miseq/miseq.an.rarefaction : $(MISEQ_AN_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('unique.an', 'data/miseq', c('0.05', '0.1', '0.15', '0.2', '1.0'))"

data/miseq/miseq.nn.rarefaction : $(MISEQ_NN_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('unique.nn', 'data/miseq', c('0.05', '0.1', '0.15', '0.2', '1.0'))"

data/miseq/miseq.fn.rarefaction : $(MISEQ_FN_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('unique.fn', 'data/miseq', c('0.05', '0.1', '0.15', '0.2', '1.0'))"

data/miseq/miseq.agc.rarefaction : $(MISEQ_AGC_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('agc', 'data/miseq', c('0.05', '0.1', '0.15', '0.2', '1.0'))"

data/miseq/miseq.dgc.rarefaction : $(MISEQ_DGC_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('dgc', 'data/miseq', c('0.05', '0.1', '0.15', '0.2', '1.0'))"

data/miseq/miseq.closed.rarefaction : $(MISEQ_CLOSED_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('closed', 'data/miseq', c('0.05', '0.1', '0.15', '0.2', '1.0'))"

data/miseq/miseq.open.rarefaction : $(MISEQ_OPEN_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('open', 'data/miseq', c('0.05', '0.1', '0.15', '0.2', '1.0'))"

data/miseq/miseq.swarm.rarefaction : $(MISEQ_SWARM_LIST) code/rarefy_data.R 
	R -e "source('code/rarefy_data.R');rarefy_sobs('swarm', 'data/miseq', c('0.05', '0.1', '0.15', '0.2', '1.0'))"

data/miseq/miseq.vdgc.rarefaction : $(MISEQ_VDGC_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('vdgc', 'data/miseq', c('0.05', '0.1', '0.15', '0.2', '1.0'))"

data/miseq/miseq.vagc.rarefaction : $(MISEQ_VAGC_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('vagc', 'data/miseq', c('0.05', '0.1', '0.15', '0.2', '1.0'))"




$(REFS)97_otus.fasta : ~/venv/lib/python2.7/site-packages/qiime_default_reference/gg_13_8_otus/rep_set/97_otus.fasta
	cp -p $< $@

data/gg_13_8/gg_13_8_97.v19.align : $(REFS)/97_otus.fasta $(REFS)silva.bact_archaea.align
	mothur "#align.seqs(fasta=$(REFS)/97_otus.fasta, reference=$(REFS)silva.bact_archaea.align, processors=2, outputdir=data/gg_13_8);pcr.seqs(fasta=data/gg_13_8/97_otus.align, start=1044, end=43116, keepdots=F, processors=8);filter.seqs(vertical=T)"
	rm data/gg_13_8/97_otus.align.report data/gg_13_8/97_otus.flip.accnos data/gg_13_8/97_otus.pcr.align data/gg_13_8/97_otus.filter
	mv data/gg_13_8/97_otus.pcr.filter.fasta data/gg_13_8/gg_13_8_97.v19.align

data/gg_13_8/gg_13_8_97.v19_ref.unique.align data/gg_13_8/gg_13_8_97.v19_ref.names data/gg_13_8/gg_13_8_97.v19.bad.accnos : data/gg_13_8/gg_13_8_97.v19.align
	mothur "#screen.seqs(fasta=data/gg_13_8/gg_13_8_97.v19.align, start=3967, end=6116, processors=8); unique.seqs()"
	mv data/gg_13_8/gg_13_8_97.v19.good.unique.align data/gg_13_8/gg_13_8_97.v19_ref.unique.align
	mv data/gg_13_8/gg_13_8_97.v19.good.names data/gg_13_8/gg_13_8_97.v19_ref.names

data/gg_13_8/gg_13_8_97.v4_ref.unique.align data/gg_13_8/gg_13_8_97.v4_ref.names : data/gg_13_8/gg_13_8_97.v19.bad.accnos data/gg_13_8/gg_13_8_97.v19.align
	mothur "#remove.seqs(fasta=data/gg_13_8/gg_13_8_97.v19.align, accnos=data/gg_13_8/gg_13_8_97.v19.bad.accnos); pcr.seqs(fasta=data/gg_13_8/gg_13_8_97.v19.pick.align, keepdots=F, start=3967, end=6116, processors=4); unique.seqs()"
	mv data/gg_13_8/gg_13_8_97.v19.pick.pcr.unique.align data/gg_13_8/gg_13_8_97.v4_ref.unique.align
	mv data/gg_13_8/gg_13_8_97.v19.pick.pcr.names data/gg_13_8/gg_13_8_97.v4_ref.names
	rm data/gg_13_8/gg_13_8_97.v19.pick.align

GG_DIST = data/gg_13_8/gg_13_8_97.v4_ref.unique.dist data/gg_13_8/gg_13_8_97.v19_ref.unique.dist
data/gg_13_8/gg_13_8_97.%.dist : data/gg_13_8/gg_13_8_97.%.align
	mothur "#dist.seqs(fasta=$<, cutoff=0.15, processors=8)"

GG_DIST_V4 = $(foreach R,$(REP),data/gg_13_8/gg_13_8_97.v4_ref.$R.unique.dist)
data/gg_13_8/gg_13_8_97.v4_ref.%.unique.dist : data/gg_13_8/gg_13_8_97.v4_ref.unique.dist
	cp $< $@

GG_NAMES_V4 = $(foreach R,$(REP),data/gg_13_8/gg_13_8_97.v4_ref.$R.names)
data/gg_13_8/gg_13_8_97.v4_ref.%.names : data/gg_13_8/gg_13_8_97.v4_ref.names
	cp $< $@

GG_DIST_V19 = $(foreach R,$(REP),data/gg_13_8/gg_13_8_97.v19_ref.$R.unique.dist)
data/gg_13_8/gg_13_8_97.v19_ref.%.unique.dist : data/gg_13_8/gg_13_8_97.v19_ref.unique.dist
	cp $< $@

GG_NAMES_V19 = $(foreach R,$(REP),data/gg_13_8/gg_13_8_97.v19_ref.$R.names)
data/gg_13_8/gg_13_8_97.v19_ref.%.names : data/gg_13_8/gg_13_8_97.v19_ref.names
	cp $< $@


GG_CLUST_V4 = $(foreach R,$(REP),data/gg_13_8/gg_13_8_97.v4_ref.$R.unique.an.list)
GG_CLUST_V19 = $(foreach R,$(REP),data/gg_13_8/gg_13_8_97.v19_ref.$R.unique.an.list)
data/gg_13_8/gg_13_8_97%unique.an.list : $$(subst .an.list,.dist, $$@) $$(subst unique.an.list,names, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	$(eval REP=$(subst .,,$(suffix $(subst .names,,$(NAMES)))))
	@echo $(REP)
	mothur "#cluster(column=$(DIST), name=$(NAMES), seed=$(REP))"
	rm $(subst list,sabund,$@)
	rm $(subst list,rabund,$@)

data/gg_13_8/gg_13_8_97.v4_v19.ref_mcc : $(GG_CLUST_V4) $(GG_CLUST_V19)
	R -e "source('code/reference_mcc.R');run_reference_mcc2('data/gg_13_8/', 'gg_13_8_97.v4_ref.\\\d\\\d.unique.an.list', 'gg_13_8_97.v19_ref.\\\d\\\d.unique.an.list', 'data/gg_13_8/gg_13_8_97.v4_v19.ref_mcc')"


# allows us to compare how well the length of the region is represented
data/gg_13_8/gg_13_8_97.v19.summary : data/gg_13_8/gg_13_8_97.v19.align
	mothur "#summary.seqs(fasta=$<, processors=8)"


# see how many taxa are represented in duplicate sequences
data/gg_13_8/duplicate.analysis : code/run_duplicate_analysis.R data/gg_13_8/gg_13_8_97.v4_ref.names ~/venv/lib/python2.7/site-packages/qiime_default_reference/gg_13_8_otus/taxonomy/97_otu_taxonomy.txt
	R -e "source('code/run_duplicate_analysis.R')"



data/rand_ref/original.fasta : $(REFS)/97_otus.fasta
	cp $< $@

REF_BOOTSTRAP_FASTA = $(addprefix data/rand_ref/rand_ref_, $(foreach R,$(REP), 1.0_$R.fasta))

$(REF_BOOTSTRAP_FASTA) : code/generate_samples.R data/rand_ref/original.fasta 	
	$(eval BASE=$(patsubst data/rand_ref/rand_ref%.fasta,%,$@))
	$(eval R=$(lastword $(subst _, ,$(BASE))))
	R -e "source('code/generate_samples.R'); generate_indiv_samples('data/references/97_otus.fasta', 'data/rand_ref/rand_ref', 1.0, '$R')"




data/rand_ref/miseq.fasta : data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.redundant.fix.fasta
	mothur "#degap.seqs(fasta=$<, outputdir=data/rand_ref)"
	mv data/rand_ref/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.redundant.fix.ng.fasta $@

RAND_REF_UCLUSTER = $(addprefix data/rand_ref/rand_ref_, $(foreach R,$(REP),  1.0_$R.uclosed.uc)) data/rand_ref/original.uclosed.uc
$(RAND_REF_UCLUSTER) : $$(subst uclosed.uc,fasta, $$@) code/run_rand_uref.sh code/closedref.params.txt data/rand_ref/miseq.fasta
	bash code/run_rand_uref.sh $<

RAND_REF_VCLUSTER = $(addprefix data/rand_ref/rand_ref_, $(foreach R,$(REP),  1.0_$R.vclosed.vc)) data/rand_ref/original.vclosed.vc
$(RAND_REF_VCLUSTER) : $$(subst vclosed.vc,fasta, $$@) code/run_rand_vref.sh code/closedref.params.txt data/rand_ref/miseq.fasta
	bash code/run_rand_vref.sh $<

data/rand_ref/hits.uclosed.summary data/rand_ref/overlap.uclosed.summary : code/summarize_rand_ref.R $(RAND_REF_UCLUSTER)
	R -e "source('code/summarize_rand_ref.R'); summarize_rand_ref('u')"

data/rand_ref/hits.vclosed.summary data/rand_ref/overlap.vclosed.summary : code/summarize_rand_ref.R $(RAND_REF_VCLUSTER)
	R -e "source('code/summarize_rand_ref.R'); summarize_rand_ref('v')"




data/process/he.mcc_ref.summary : code/summarize_mcc_ref.R $(HE_REF_MCC)
	R -e "source('code/summarize_mcc_ref.R'); summarize_mcc_ref('he')"

data/process/schloss.mcc_ref.summary : code/summarize_mcc_ref.R $(SCHL_REF_MCC)
	R -e "source('code/summarize_mcc_ref.R'); summarize_mcc_ref('schloss')"

data/process/miseq.mcc_ref.summary : code/summarize_mcc_ref.R $(MISEQ_REF_MCC)
	R -e "source('code/summarize_mcc_ref.R'); summarize_mcc_ref('miseq')"

