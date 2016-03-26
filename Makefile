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

HE_OTUCLUST_LIST = $(addprefix data/he/he_1.0, $(foreach R,$(REP),  _$R.otuclust.list))
.SECONDEXPANSION:
$(HE_OTUCLUST_LIST) : $$(subst otuclust.list,fasta, $$@) code/run_otuclust.sh code/otuclust_to_list.R
	bash code/run_otuclust.sh $<

HE_SUMACLUST_LIST = $(addprefix data/he/he_1.0, $(foreach R,$(REP),  _$R.sumaclust.list))
.SECONDEXPANSION:
$(HE_SUMACLUST_LIST) : $$(subst sumaclust.list,fasta, $$@) code/run_sumaclust.sh code/sumaclust_to_list.R
	bash code/run_sumaclust.sh $<

HE_SORTMERNA_LIST = $(addprefix data/he/he_1.0, $(foreach R,$(REP),  _$R.sortmerna.list))
.SECONDEXPANSION:
$(HE_SORTMERNA_LIST) : $$(subst sortmerna.list,fasta, $$@) code/run_sortmerna.sh code/sortmerna_to_list.R code/sortmerna.params.txt
	bash code/run_sortmerna.sh $<

HE_CVSEARCH_LIST = $(addprefix data/he/he_1.0, $(foreach R,$(REP),  _$R.cvsearch.list))
.SECONDEXPANSION:
$(HE_CVSEARCH_LIST) : $$(subst cvsearch.list,fasta, $$@) code/run_cvsearch.sh code/cvsearch_to_list.R
	bash code/run_cvsearch.sh $<

HE_NINJA_LIST = $(addprefix data/he/he_1.0, $(foreach R,$(REP),  _$R.ninja.list))
.SECONDEXPANSION:
$(HE_NINJA_LIST) : $$(subst ninja.list,fasta, $$@) code/run_ninja.sh code/ninja_to_list.R
	bash code/run_ninja.sh $<


HE_GREEDY_LIST = $(HE_SWARM_LIST) $(HE_DGC_LIST) $(HE_AGC_LIST) $(HE_OPEN_LIST) $(HE_CLOSED_LIST) $(HE_VDGC_LIST) $(HE_VAGC_LIST) $(HE_OTUCLUST_LIST) $(HE_SUMACLUST_LIST)  $(HE_SORTMERNA_LIST) $(HE_CVSEARCH_LIST) $(HE_NINJA_LIST)


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

data/he/he.swarm.opt.sensspec : code/optimize_swarm_sensspec.R $(HE_SWARM_LIST) $$(addsuffix .unique.dist,$$(basename $$(basename $$(HE_SWARM_LIST)))) $$(addsuffix .names,$$(basename $$(basename $$(HE_SWARM_LIST))))
	R -e 'source("code/optimize_swarm_sensspec.R"); optimize_swarm("he")'


HE_VAGC_SENSSPEC = $(subst list,sensspec, $(HE_VAGC_LIST))
HE_VDGC_SENSSPEC = $(subst list,sensspec, $(HE_VDGC_LIST))


HE_REF_MCC = data/he/he.fn.ref_mcc data/he/he.nn.ref_mcc data/he/he.an.ref_mcc data/he/he.agc.ref_mcc data/he/he.dgc.ref_mcc data/he/he.closed.ref_mcc data/he/he.open.ref_mcc data/he/he.swarm.ref_mcc data/he/he.vdgc.ref_mcc data/he/he.vagc.ref_mcc
data/he/he.an.ref_mcc : code/reference_mcc.R $(HE_AN_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*unique.an.list', 'he_1.0.*unique.an.list', 'he.*names', 'data/he/he.an.ref_mcc')"

data/he/he.fn.ref_mcc : code/reference_mcc.R $(HE_FN_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*unique.fn.list', 'he_1.0.*unique.fn.list', 'he.*names', 'data/he/he.fn.ref_mcc')"

data/he/he.nn.ref_mcc : code/reference_mcc.R $(HE_NN_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*unique.nn.list', 'he_1.0.*unique.nn.list', 'he.*names', 'data/he/he.nn.ref_mcc')"

data/he/he.closed.ref_mcc : code/reference_mcc.R $(HE_CLOSED_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*.closed.list', 'he_1.0.*closed.list', 'he.*names', 'data/he/he.closed.ref_mcc')"

data/he/he.open.ref_mcc : code/reference_mcc.R $(HE_OPEN_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*.open.list', 'he_1.0.*open.list', 'he.*names', 'data/he/he.open.ref_mcc')"

data/he/he.agc.ref_mcc : code/reference_mcc.R $(HE_AGC_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*\\\.agc.list', 'he_1.0.*\\\.agc.list', 'he.*names', 'data/he/he.agc.ref_mcc')"

data/he/he.dgc.ref_mcc : code/reference_mcc.R $(HE_DGC_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*\\\.dgc.list', 'he_1.0.*\\\.dgc.list', 'he.*names', 'data/he/he.dgc.ref_mcc')"

data/he/he.swarm.ref_mcc : code/reference_mcc.R $(HE_SWARM_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*.swarm.list', 'he_1.0.*swarm.list', 'he.*names', 'data/he/he.swarm.ref_mcc')"

data/he/he.vdgc.ref_mcc : code/reference_mcc.R $(HE_VDGC_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*.vdgc.list', 'he_1.0.*.vdgc.list', 'he.*names', 'data/he/he.vdgc.ref_mcc')"

data/he/he.vagc.ref_mcc : code/reference_mcc.R $(HE_VAGC_LIST) $(HE_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/he/', 'he.*.vagc.list', 'he_1.0.*.vagc.list', 'he.*names', 'data/he/he.vagc.ref_mcc')"


HE_POOL_SENSSPEC = data/he/he.an.pool_sensspec data/he/he.fn.pool_sensspec data/he/he.nn.pool_sensspec data/he/he.agc.pool_sensspec data/he/he.dgc.pool_sensspec data/he/he.vagc.pool_sensspec data/he/he.vdgc.pool_sensspec data/he/he.sumaclust.pool_sensspec data/he/he.otuclust.pool_sensspec data/he/he.closed.pool_sensspec data/he/he.ninja.pool_sensspec data/he/he.sortmerna.pool_sensspec data/he/he.cvsearch.pool_sensspec data/he/he.open.pool_sensspec data/he/he.swarm.pool_sensspec

data/he/he.an.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_AN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*an.sensspec', 'data/he/he.an.pool_sensspec')"

data/he/he.fn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_FN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*fn.sensspec', 'data/he/he.fn.pool_sensspec')"

data/he/he.nn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_NN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*nn.sensspec', 'data/he/he.nn.pool_sensspec')"

data/he/he.dgc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_DGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*\\\.dgc.sensspec', 'data/he/he.dgc.pool_sensspec')"

data/he/he.agc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_AGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*\\\.agc.sensspec', 'data/he/he.agc.pool_sensspec')"

data/he/he.open.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_OPEN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*open.sensspec', 'data/he/he.open.pool_sensspec')"

data/he/he.closed.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_CLOSED_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*closed.sensspec', 'data/he/he.closed.pool_sensspec')"

data/he/he.vdgc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_VDGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*vdgc.sensspec', 'data/he/he.vdgc.pool_sensspec')"

data/he/he.vagc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_VAGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*vagc.sensspec', 'data/he/he.vagc.pool_sensspec')"

data/he/he.otuclust.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_OTUCLUST_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*otuclust.sensspec', 'data/he/he.otuclust.pool_sensspec')"

data/he/he.sumaclust.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_SUMACLUST_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*sumaclust.sensspec', 'data/he/he.sumaclust.pool_sensspec')"

data/he/he.sortmerna.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_SORTMERNA_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*sortmerna.sensspec', 'data/he/he.sortmerna.pool_sensspec')"

data/he/he.cvsearch.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_CVSEARCH_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*cvsearch.sensspec', 'data/he/he.cvsearch.pool_sensspec')"

data/he/he.ninja.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(HE_NINJA_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/he', 'he_.*ninja.sensspec', 'data/he/he.ninja.pool_sensspec')"

data/he/he.swarm.pool_sensspec : data/he/he.swarm.opt.sensspec code/merge_sensspec_files.R
	R -e "source('code/extract_opt_swarm.R');extract_opt_swarm('data/he/he.swarm.opt.sensspec')"


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

$(REFS)silva.v4.align : $(REFS)silva.bacteria.align
	mothur "#pcr.seqs(fasta=$^, start=13862, end=23445, keepdots=F, processors=8);degap.seqs();unique.seqs()"
	cut -f 1 $(REFS)silva.bacteria.pcr.ng.names > $(REFS)silva.bacteria.pcr.ng.accnos
	mothur "#get.seqs(fasta=$(REFS)silva.bacteria.pcr.align, accnos=$(REFS)silva.bacteria.pcr.ng.accnos);screen.seqs(minlength=240, maxlength=275, maxambig=0, maxhomop=8, processors=8); filter.seqs(vertical=T)"
	rm $(REFS)silva.bacteria.pcr.align
	rm $(REFS)silva.bacteria.pcr.ng.fasta
	rm $(REFS)silva.bacteria.pcr.ng.names
	rm $(REFS)silva.bacteria.pcr.ng.unique.fasta
	rm $(REFS)silva.bacteria.pcr.ng.accnos
	rm $(REFS)silva.bacteria.pcr.pick.good.align
	rm $(REFS)silva.bacteria.pcr.pick.bad.accnos
	rm $(REFS)silva.filter
	mv $(REFS)silva.bacteria.pcr.pick.good.filter.fasta $@


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




#M_FRACTION = 0.05 0.1 0.2 0.4 1.0
M_FRACTION = 0.2 0.4 0.6 0.8 1.0

data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta : code/process_mice.sh data/miseq/miseq.files data/references/silva.bacteria.align data/references/trainset10_082014.pds.fasta data/references/trainset10_082014.pds.tax
	bash code/process_mice.sh data/miseq/miseq.files

data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table : code/process_mice.sh data/miseq/miseq.files data/references/silva.bacteria.align data/references/trainset10_082014.pds.fasta data/references/trainset10_082014.pds.tax
	bash code/process_mice.sh data/miseq/miseq.files

data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pds.wang.pick.taxonomy : code/process_mice.sh data/miseq/miseq.files data/references/silva.bacteria.align data/references/trainset10_082014.pds.fasta data/references/trainset10_082014.pds.tax
	bash code/process_mice.sh data/miseq/miseq.files


data/miseq/miseq.seq.info : code/get_miseq_info.R data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.denovo.uchime.pick.pick.count_table
	R -e "source('code/get_miseq_info.R')"


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

MISEQ_OTUCLUST_LIST = $(addprefix data/miseq/miseq_1.0, $(foreach R,$(REP),  _$R.otuclust.list))
.SECONDEXPANSION:
$(MISEQ_OTUCLUST_LIST) : $$(subst otuclust.list,ng.fasta, $$@) code/run_otuclust.sh code/otuclust_to_list.R
	bash code/run_otuclust.sh $<

MISEQ_SUMACLUST_LIST = $(addprefix data/miseq/miseq_1.0, $(foreach R,$(REP),  _$R.sumaclust.list))
.SECONDEXPANSION:
$(MISEQ_SUMACLUST_LIST) : $$(subst sumaclust.list,ng.fasta, $$@) code/run_sumaclust.sh code/sumaclust_to_list.R
	bash code/run_sumaclust.sh $<

MISEQ_SORTMERNA_LIST = $(addprefix data/miseq/miseq_1.0, $(foreach R,$(REP),  _$R.sortmerna.list))
.SECONDEXPANSION:
$(MISEQ_SORTMERNA_LIST) : $$(subst sortmerna.list,ng.fasta, $$@) code/run_sortmerna.sh code/sortmerna_to_list.R code/sortmerna.params.txt
	bash code/run_sortmerna.sh $<

MISEQ_CVSEARCH_LIST = $(addprefix data/miseq/miseq_1.0, $(foreach R,$(REP),  _$R.cvsearch.list))
.SECONDEXPANSION:
$(MISEQ_CVSEARCH_LIST) : $$(subst cvsearch.list,ng.fasta, $$@) code/run_cvsearch.sh code/cvsearch_to_list.R
	bash code/run_cvsearch.sh $<

MISEQ_NINJA_LIST = $(addprefix data/miseq/miseq_1.0, $(foreach R,$(REP),  _$R.ninja.list))
.SECONDEXPANSION:
$(MISEQ_NINJA_LIST) : $$(subst ninja.list,ng.fasta, $$@) code/run_ninja.sh code/ninja_to_list.R
	bash code/run_ninja.sh $<


MISEQ_GREEDY_LIST = $(MISEQ_DGC_LIST) $(MISEQ_AGC_LIST) $(MISEQ_OPEN_LIST) $(MISEQ_CLOSED_LIST) $(MISEQ_VDGC_LIST) $(MISEQ_VAGC_LIST) $(MISEQ_OTUCLUST_LIST)  $(MISEQ_SUMACLUST_LIST) $(MISEQ_SORTMERNA_LIST) $(MISEQ_CVSEARCH_LIST) $(MISEQ_NINJA_LIST)


MISEQ_NEIGHBOR_SENSSPEC = $(subst list,sensspec, $(MISEQ_NEIGHBOR_LIST))
.SECONDEXPANSION:
$(MISEQ_NEIGHBOR_SENSSPEC) : $$(addsuffix .dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@) $$(addsuffix .names,$$(basename $$(basename $$(basename $$@))))
	$(eval LIST=$(word 2,$^))
	$(eval NAMES=$(word 3,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), name=$(NAMES), label=0.03, outputdir=data/miseq)"

MISEQ_GREEDY_SENSSPEC = $(subst list,sensspec, $(MISEQ_GREEDY_LIST))

.SECONDEXPANSION:
$(MISEQ_GREEDY_SENSSPEC) : $$(addsuffix .unique.dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@) $$(addsuffix .names,$$(basename $$(basename $$@)))
	$(eval LIST=$(word 2,$^))
	$(eval NAMES=$(word 3,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), name=$(NAMES), label=userLabel, cutoff=0.03, outputdir=data/miseq)"

data/miseq/miseq.swarm.opt.sensspec : code/optimize_swarm_sensspec.R $(MISEQ_SWARM_LIST) $$(addsuffix .unique.dist,$$(basename $$(basename $$(MISEQ_SWARM_LIST)))) $$(addsuffix .names,$$(basename $$(basename $$(MISEQ_SWARM_LIST))))
	R -e 'source("code/optimize_swarm_sensspec.R"); optimize_swarm("miseq")'

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
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*\\\.agc.list', 'miseq_1.0.*\\\.agc.list', 'miseq.*names', 'data/miseq/miseq.agc.ref_mcc')"

data/miseq/miseq.dgc.ref_mcc : code/reference_mcc.R $(MISEQ_DGC_LIST) $(MISEQ_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*\\\.dgc.list', 'miseq_1.0.*\\\.dgc.list', 'miseq.*names', 'data/miseq/miseq.dgc.ref_mcc')"

data/miseq/miseq.swarm.ref_mcc : code/reference_mcc.R $(MISEQ_SWARM_LIST) $(MISEQ_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*swarm.list', 'miseq_1.0.*swarm.list', 'miseq.*names', 'data/miseq/miseq.swarm.ref_mcc')"

data/miseq/miseq.vdgc.ref_mcc : code/reference_mcc.R $(MISEQ_VDGC_LIST) $(MISEQ_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*vdgc.list', 'miseq_1.0.*vdgc.list', 'miseq.*names', 'data/miseq/miseq.vdgc.ref_mcc')"

data/miseq/miseq.vagc.ref_mcc : code/reference_mcc.R $(MISEQ_VAGC_LIST) $(MISEQ_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/miseq/', 'miseq.*vagc.list', 'miseq_1.0.*vagc.list', 'miseq.*names', 'data/miseq/miseq.vagc.ref_mcc')"


MISEQ_POOL_SENSSPEC = data/miseq/miseq.an.pool_sensspec data/miseq/miseq.fn.pool_sensspec data/miseq/miseq.nn.pool_sensspec data/miseq/miseq.dgc.pool_sensspec data/miseq/miseq.agc.pool_sensspec data/miseq/miseq.open.pool_sensspec data/miseq/miseq.closed.pool_sensspec data/miseq/miseq.vdgc.pool_sensspec data/miseq/miseq.vagc.pool_sensspec data/miseq/miseq.otuclust.pool_sensspec data/miseq/miseq.sumaclust.pool_sensspec data/miseq/miseq.sortmerna.pool_sensspec data/miseq/miseq.cvsearch.pool_sensspec data/miseq/miseq.ninja.pool_sensspec data/miseq/miseq.swarm.pool_sensspec

data/miseq/miseq.an.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_AN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*an.sensspec', 'data/miseq/miseq.an.pool_sensspec')"

data/miseq/miseq.fn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_FN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*fn.sensspec', 'data/miseq/miseq.fn.pool_sensspec')"

data/miseq/miseq.nn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_NN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*nn.sensspec', 'data/miseq/miseq.nn.pool_sensspec')"

data/miseq/miseq.dgc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_DGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*\\\.dgc.sensspec', 'data/miseq/miseq.dgc.pool_sensspec')"

data/miseq/miseq.agc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_AGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*\\\.agc.sensspec', 'data/miseq/miseq.agc.pool_sensspec')"

data/miseq/miseq.open.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_OPEN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*open.sensspec', 'data/miseq/miseq.open.pool_sensspec')"

data/miseq/miseq.closed.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_CLOSED_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*closed.sensspec', 'data/miseq/miseq.closed.pool_sensspec')"

data/miseq/miseq.vdgc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_VDGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*vdgc.sensspec', 'data/miseq/miseq.vdgc.pool_sensspec')"

data/miseq/miseq.vagc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_VAGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*vagc.sensspec', 'data/miseq/miseq.vagc.pool_sensspec')"

data/miseq/miseq.otuclust.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_OTUCLUST_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*otuclust.sensspec', 'data/miseq/miseq.otuclust.pool_sensspec')"

data/miseq/miseq.sumaclust.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_SUMACLUST_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*sumaclust.sensspec', 'data/miseq/miseq.sumaclust.pool_sensspec')"

data/miseq/miseq.sortmerna.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_SORTMERNA_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*sortmerna.sensspec', 'data/miseq/miseq.sortmerna.pool_sensspec')"

data/miseq/miseq.cvsearch.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_CVSEARCH_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*cvsearch.sensspec', 'data/miseq/miseq.cvsearch.pool_sensspec')"

data/miseq/miseq.ninja.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(MISEQ_NINJA_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/miseq', 'miseq_.*ninja.sensspec', 'data/miseq/miseq.ninja.pool_sensspec')"

data/miseq/miseq.swarm.pool_sensspec : data/miseq/miseq.swarm.opt.sensspec code/merge_sensspec_files.R
	R -e "source('code/extract_opt_swarm.R');extract_opt_swarm('data/miseq/miseq.swarm.opt.sensspec')"


MISEQ_RAREFACTION = data/miseq/miseq.an.rarefaction data/miseq/miseq.nn.rarefaction data/miseq/miseq.fn.rarefaction data/miseq/miseq.agc.rarefaction data/miseq/miseq.dgc.rarefaction data/miseq/miseq.closed.rarefaction data/miseq/miseq.open.rarefaction data/miseq/miseq.swarm.rarefaction data/miseq/miseq.vdgc.rarefaction data/miseq/miseq.vagc.rarefaction

data/miseq/miseq.an.rarefaction : $(MISEQ_AN_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('unique.an', 'data/miseq')"

data/miseq/miseq.nn.rarefaction : $(MISEQ_NN_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('unique.nn', 'data/miseq')"

data/miseq/miseq.fn.rarefaction : $(MISEQ_FN_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('unique.fn', 'data/miseq')"

data/miseq/miseq.agc.rarefaction : $(MISEQ_AGC_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('agc', 'data/miseq')"

data/miseq/miseq.dgc.rarefaction : $(MISEQ_DGC_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('dgc', 'data/miseq')"

data/miseq/miseq.closed.rarefaction : $(MISEQ_CLOSED_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('closed', 'data/miseq')"

data/miseq/miseq.open.rarefaction : $(MISEQ_OPEN_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('open', 'data/miseq')"

data/miseq/miseq.swarm.rarefaction : $(MISEQ_SWARM_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('swarm', 'data/miseq')"

data/miseq/miseq.vdgc.rarefaction : $(MISEQ_VDGC_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('vdgc', 'data/miseq')"

data/miseq/miseq.vagc.rarefaction : $(MISEQ_VAGC_LIST) code/rarefy_data.R
	R -e "source('code/rarefy_data.R');rarefy_sobs('vagc', 'data/miseq')"



$(shell mkdir -p data/even/)
$(shell mkdir -p data/staggered/)
data/even/even.fasta data/staggered/staggered.fasta : $(REFS)silva.v4.align
	grep ">" $^ | cut -c 2- | awk 'NR % 8 == 0' > simulated.accnos
	mothur "#get.seqs(fasta=$^, accnos=simulated.accnos)"
	mv data/references/silva.v4.pick.align $@

data/even/even.names : data/even/even.fasta code/build_simulated_names.R
	R -e "source('code/build_simulated_names.R'); even('$<')"

data/even/even.redundant.fasta : data/even/even.fasta data/even/even.names
	mothur "#deunique.seqs(fasta=data/even/even.fasta, name=data/even/even.names)"

data/even/even.redundant.fix.fasta : data/even/even.redundant.fasta
	sed "s/_/-/g" < $< > $@

EVEN_BOOTSTRAP_FASTA = $(addprefix data/even/even_1.0, $(foreach R,$(REP), _$R.fasta))
$(EVEN_BOOTSTRAP_FASTA) : code/generate_samples.R data/even/even.redundant.fix.fasta
	$(eval BASE=$(patsubst data/even/even_%.fasta,%,$@))
	$(eval R=$(lastword $(subst _, ,$(BASE))))
	R -e "source('code/generate_samples.R'); generate_indiv_samples('data/even/even.redundant.fix.fasta', 'data/even/even', 1.0, '$R')"

EVEN_UNIQUE_FASTA = $(addprefix data/even/even_1.0, $(foreach R,$(REP), _$R.unique.fasta))
$(EVEN_UNIQUE_FASTA) : $$(subst unique.fasta,fasta, $$@)
	mothur "#unique.seqs(fasta=$<)"

EVEN_NAMES = $(addprefix data/even/even_1.0, $(foreach R,$(REP), _$R.names))
$(EVEN_NAMES) : $$(subst names,unique.fasta, $$@)

EVEN_DISTANCE = $(addprefix data/even/even_1.0, $(foreach R,$(REP), _$R.unique.dist))
$(EVEN_DISTANCE) : $$(subst dist,fasta, $$@)
	mothur "#dist.seqs(fasta=$<, processors=8, cutoff=0.20)"



EVEN_AN_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP), _$R.unique.an.list))
$(EVEN_AN_LIST) : $$(subst .an.list,.dist, $$@) $$(subst unique.an.list,names, $$@) code/run_an.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_an.sh $(DIST) $(NAMES)

EVEN_NN_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP), _$R.unique.nn.list))
$(EVEN_NN_LIST) : $$(subst .nn.list,.dist, $$@) $$(subst unique.nn.list,names, $$@) code/run_nn.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_nn.sh $(DIST) $(NAMES)

EVEN_FN_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP), _$R.unique.fn.list))
.SECONDEXPANSION:
$(EVEN_FN_LIST) : $$(subst .fn.list,.dist, $$@) $$(subst unique.fn.list,names, $$@) code/run_fn.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_fn.sh $(DIST) $(NAMES)

EVEN_NEIGHBOR_LIST = $(EVEN_AN_LIST) $(EVEN_NN_LIST) $(EVEN_FN_LIST)

EVEN_DEGAP_FASTA = $(subst fasta,ng.fasta,$(EVEN_BOOTSTRAP_FASTA))
$(EVEN_DEGAP_FASTA) : $$(subst ng.fasta,fasta, $$@)
	mothur "#degap.seqs(fasta=$<)"

EVEN_DGC_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP),  _$R.dgc.list))
.SECONDEXPANSION:
$(EVEN_DGC_LIST) : $$(subst dgc.list,ng.fasta, $$@) code/run_dgc.sh code/dgc.params.txt code/biom_to_list.R
	$(eval NG_LIST=$(subst dgc.list,ng.dgc.list,$@))
	bash code/run_dgc.sh $<
	mv $(NG_LIST) $@

EVEN_AGC_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP),  _$R.agc.list))
.SECONDEXPANSION:
$(EVEN_AGC_LIST) : $$(subst agc.list,ng.fasta, $$@) code/run_agc.sh code/agc.params.txt code/biom_to_list.R
	$(eval NG_LIST=$(subst agc.list,ng.agc.list,$@))
	bash code/run_agc.sh $<
	mv $(NG_LIST) $@

EVEN_CLOSED_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP),  _$R.closed.list))
.SECONDEXPANSION:
$(EVEN_CLOSED_LIST) : $$(subst closed.list,ng.fasta, $$@) code/run_closed.sh code/closedref.params.txt code/biom_to_list.R
	$(eval NG_LIST=$(subst closed.list,ng.closed.list,$@))
	bash code/run_closed.sh $<
	mv $(NG_LIST) $@

EVEN_OPEN_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP),  _$R.open.list))
.SECONDEXPANSION:
$(EVEN_OPEN_LIST) : $$(subst open.list,ng.fasta, $$@) code/run_open.sh code/openref.params.txt code/biom_to_list.R
	$(eval NG_LIST=$(subst open.list,ng.open.list,$@))
	bash code/run_open.sh $<
	mv $(NG_LIST) $@

EVEN_SWARM_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP),  _$R.swarm.list))
.SECONDEXPANSION:
$(EVEN_SWARM_LIST) : $$(subst swarm.list,unique.fasta, $$@) $$(subst swarm.list,names, $$@) code/cluster_swarm.R
	$(eval FASTA=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	R -e 'source("code/cluster_swarm.R"); get_mothur_list("$(FASTA)", "$(NAMES)")'

EVEN_VDGC_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP),  _$R.vdgc.list))
.SECONDEXPANSION:
$(EVEN_VDGC_LIST) : $$(subst vdgc.list,ng.fasta, $$@) code/run_vdgc_clust.sh code/uc_to_list.R
	bash code/run_vdgc_clust.sh $<

EVEN_VAGC_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP),  _$R.vagc.list))
.SECONDEXPANSION:
$(EVEN_VAGC_LIST) : $$(subst vagc.list,ng.fasta, $$@) code/run_vagc_clust.sh code/uc_to_list.R
	bash code/run_vagc_clust.sh $<

EVEN_OTUCLUST_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP),  _$R.otuclust.list))
.SECONDEXPANSION:
$(EVEN_OTUCLUST_LIST) : $$(subst otuclust.list,ng.fasta, $$@) code/run_otuclust.sh code/otuclust_to_list.R
	bash code/run_otuclust.sh $<

EVEN_SUMACLUST_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP),  _$R.sumaclust.list))
.SECONDEXPANSION:
$(EVEN_SUMACLUST_LIST) : $$(subst sumaclust.list,ng.fasta, $$@) code/run_sumaclust.sh code/sumaclust_to_list.R
	bash code/run_sumaclust.sh $<

EVEN_SORTMERNA_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP),  _$R.sortmerna.list))
.SECONDEXPANSION:
$(EVEN_SORTMERNA_LIST) : $$(subst sortmerna.list,ng.fasta, $$@) code/run_sortmerna.sh code/sortmerna_to_list.R  code/sortmerna.params.txt
	bash code/run_sortmerna.sh $<

EVEN_CVSEARCH_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP),  _$R.cvsearch.list))
.SECONDEXPANSION:
$(EVEN_CVSEARCH_LIST) : $$(subst cvsearch.list,ng.fasta, $$@) code/run_cvsearch.sh code/cvsearch_to_list.R
	bash code/run_cvsearch.sh $<

EVEN_NINJA_LIST = $(addprefix data/even/even_1.0, $(foreach R,$(REP),  _$R.ninja.list))
.SECONDEXPANSION:
$(EVEN_NINJA_LIST) : $$(subst ninja.list,ng.fasta, $$@) code/run_ninja.sh code/ninja_to_list.R
	bash code/run_ninja.sh $<


EVEN_GREEDY_LIST = $(EVEN_DGC_LIST) $(EVEN_AGC_LIST) $(EVEN_OPEN_LIST) $(EVEN_CLOSED_LIST) $(EVEN_VDGC_LIST) $(EVEN_VAGC_LIST) $(EVEN_SWARM_LIST) $(EVEN_OTUCLUST_LIST)  $(EVEN_SUMACLUST_LIST) $(EVEN_SORTMERNA_LIST) $(EVEN_CVSEARCH_LIST) $(EVEN_NINJA_LIST)

EVEN_NEIGHBOR_SENSSPEC = $(subst list,sensspec, $(EVEN_NEIGHBOR_LIST))
.SECONDEXPANSION:
$(EVEN_NEIGHBOR_SENSSPEC) : $$(addsuffix .dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@) $$(addsuffix .names,$$(basename $$(basename $$(basename $$@))))
	$(eval LIST=$(word 2,$^))
	$(eval NAMES=$(word 3,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), name=$(NAMES), label=0.03, outputdir=data/even)"

EVEN_GREEDY_SENSSPEC = $(subst list,sensspec, $(EVEN_GREEDY_LIST))

.SECONDEXPANSION:
$(EVEN_GREEDY_SENSSPEC) : $$(addsuffix .unique.dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@) $$(addsuffix .names,$$(basename $$(basename $$@)))
	$(eval LIST=$(word 2,$^))
	$(eval NAMES=$(word 3,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), name=$(NAMES), label=userLabel, cutoff=0.03, outputdir=data/even)"

data/even/even.swarm.opt.sensspec : code/optimize_swarm_sensspec.R $(EVEN_SWARM_LIST) $$(addsuffix .unique.dist,$$(basename $$(basename $$(EVEN_SWARM_LIST)))) $$(addsuffix .names,$$(basename $$(basename $$(EVEN_SWARM_LIST))))
	R -e 'source("code/optimize_swarm_sensspec.R"); optimize_swarm("even", fraction="1.0")'

EVEN_REF_MCC = data/even/even.fn.ref_mcc data/even/even.nn.ref_mcc data/even/even.an.ref_mcc data/even/even.agc.ref_mcc data/even/even.dgc.ref_mcc data/even/even.closed.ref_mcc data/even/even.open.ref_mcc data/even/even.swarm.ref_mcc data/even/even.vdgc.ref_mcc data/even/even.vagc.ref_mcc
data/even/even.an.ref_mcc : code/reference_mcc.R $(EVEN_AN_LIST) $(EVEN_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/even/', 'even.*unique.an.list', 'even_1.0.*unique.an.list', 'even.*names', 'data/even/even.an.ref_mcc')"

data/even/even.fn.ref_mcc : code/reference_mcc.R $(EVEN_FN_LIST) $(EVEN_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/even/', 'even.*unique.fn.list', 'even_1.0_.*unique.fn.list', 'even.*names', 'data/even/even.fn.ref_mcc')"

data/even/even.nn.ref_mcc : code/reference_mcc.R $(EVEN_NN_LIST) $(EVEN_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/even/', 'even.*unique.nn.list', 'even_1.0.*unique.nn.list', 'even.*names', 'data/even/even.nn.ref_mcc')"

data/even/even.closed.ref_mcc : code/reference_mcc.R $(EVEN_CLOSED_LIST) $(EVEN_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/even/', 'even.*closed.list', 'even_1.0.*closed.list', 'even.*names', 'data/even/even.closed.ref_mcc')"

data/even/even.open.ref_mcc : code/reference_mcc.R $(EVEN_OPEN_LIST) $(EVEN_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/even/', 'even.*open.list', 'even_1.0.*open.list', 'even.*names', 'data/even/even.open.ref_mcc')"

data/even/even.agc.ref_mcc : code/reference_mcc.R $(EVEN_AGC_LIST) $(EVEN_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/even/', 'even.*\\\.agc.list', 'even_1.0.*\\\.agc.list', 'even.*names', 'data/even/even.agc.ref_mcc')"

data/even/even.dgc.ref_mcc : code/reference_mcc.R $(EVEN_DGC_LIST) $(EVEN_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/even/', 'even.*\\\.dgc.list', 'even_1.0.*\\\.dgc.list', 'even.*names', 'data/even/even.dgc.ref_mcc')"

data/even/even.swarm.ref_mcc : code/reference_mcc.R $(EVEN_SWARM_LIST) $(EVEN_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/even/', 'even.*swarm.list', 'even_1.0.*swarm.list', 'even.*names', 'data/even/even.swarm.ref_mcc')"

data/even/even.vdgc.ref_mcc : code/reference_mcc.R $(EVEN_VDGC_LIST) $(EVEN_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/even/', 'even.*vdgc.list', 'even_1.0.*vdgc.list', 'even.*names', 'data/even/even.vdgc.ref_mcc')"

data/even/even.vagc.ref_mcc : code/reference_mcc.R $(EVEN_VAGC_LIST) $(EVEN_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/even/', 'even.*vagc.list', 'even_1.0.*vagc.list', 'even.*names', 'data/even/even.vagc.ref_mcc')"


EVEN_POOL_SENSSPEC = data/even/even.an.pool_sensspec data/even/even.fn.pool_sensspec data/even/even.nn.pool_sensspec data/even/even.dgc.pool_sensspec data/even/even.agc.pool_sensspec data/even/even.open.pool_sensspec data/even/even.closed.pool_sensspec data/even/even.vdgc.pool_sensspec data/even/even.vagc.pool_sensspec data/even/even.otuclust.pool_sensspec  data/even/even.sumaclust.pool_sensspec data/even/even.sortmerna.pool_sensspec data/even/even.cvsearch.pool_sensspec data/even/even.ninja.pool_sensspec data/even/even.swarm.pool_sensspec

data/even/even.an.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(EVEN_AN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/even', 'even_.*an.sensspec', 'data/even/even.an.pool_sensspec')"

data/even/even.fn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(EVEN_FN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/even', 'even_.*fn.sensspec', 'data/even/even.fn.pool_sensspec')"

data/even/even.nn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(EVEN_NN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/even', 'even_.*nn.sensspec', 'data/even/even.nn.pool_sensspec')"

data/even/even.dgc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(EVEN_DGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/even', 'even_.*\\\.dgc.sensspec', 'data/even/even.dgc.pool_sensspec')"

data/even/even.agc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(EVEN_AGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/even', 'even_.*\\\.agc.sensspec', 'data/even/even.agc.pool_sensspec')"

data/even/even.open.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(EVEN_OPEN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/even', 'even_.*open.sensspec', 'data/even/even.open.pool_sensspec')"

data/even/even.closed.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(EVEN_CLOSED_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/even', 'even_.*closed.sensspec', 'data/even/even.closed.pool_sensspec')"

data/even/even.vdgc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(EVEN_VDGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/even', 'even_.*vdgc.sensspec', 'data/even/even.vdgc.pool_sensspec')"

data/even/even.vagc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(EVEN_VAGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/even', 'even_.*vagc.sensspec', 'data/even/even.vagc.pool_sensspec')"

data/even/even.otuclust.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(EVEN_OTUCLUST_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/even', 'even_.*otuclust.sensspec', 'data/even/even.otuclust.pool_sensspec')"

data/even/even.sumaclust.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(EVEN_SUMACLUST_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/even', 'even_.*sumaclust.sensspec', 'data/even/even.sumaclust.pool_sensspec')"

data/even/even.sortmerna.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(EVEN_SORTMERNA_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/even', 'even_.*sortmerna.sensspec', 'data/even/even.sortmerna.pool_sensspec')"

data/even/even.cvsearch.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(EVEN_CVSEARCH_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/even', 'even_.*cvsearch.sensspec', 'data/even/even.cvsearch.pool_sensspec')"

data/even/even.ninja.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(EVEN_NINJA_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/even', 'even_.*ninja.sensspec', 'data/even/even.ninja.pool_sensspec')"

data/even/even.swarm.pool_sensspec : code/merge_sensspec_files.R data/even/even.swarm.opt.sensspec
	R -e "source('code/extract_opt_swarm.R');extract_opt_swarm('data/even/even.swarm.opt.sensspec')"




data/staggered/staggered.names : data/staggered/staggered.fasta code/build_simulated_names.R
	R -e "source('code/build_simulated_names.R'); staggered('$<')"

data/staggered/staggered.redundant.fasta : data/staggered/staggered.fasta data/staggered/staggered.names
	mothur "#deunique.seqs(fasta=data/staggered/staggered.fasta, name=data/staggered/staggered.names)"

data/staggered/staggered.redundant.fix.fasta : data/staggered/staggered.redundant.fasta
	sed "s/_/-/g" < $< > $@

STAGGERED_BOOTSTRAP_FASTA = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP), _$R.fasta))
$(STAGGERED_BOOTSTRAP_FASTA) : code/generate_samples.R data/staggered/staggered.redundant.fix.fasta
	$(eval BASE=$(patsubst data/staggered/staggered_%.fasta,%,$@))
	$(eval R=$(lastword $(subst _, ,$(BASE))))
	R -e "source('code/generate_samples.R'); generate_indiv_samples('data/staggered/staggered.redundant.fix.fasta', 'data/staggered/staggered', 1.0, '$R')"

STAGGERED_UNIQUE_FASTA = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP), _$R.unique.fasta))
$(STAGGERED_UNIQUE_FASTA) : $$(subst unique.fasta,fasta, $$@)
	mothur "#unique.seqs(fasta=$<)"

STAGGERED_NAMES = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP), _$R.names))
$(STAGGERED_NAMES) : $$(subst names,unique.fasta, $$@)

STAGGERED_DISTANCE = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP), _$R.unique.dist))
$(STAGGERED_DISTANCE) : $$(subst dist,fasta, $$@)
	mothur "#dist.seqs(fasta=$<, processors=8, cutoff=0.20)"



STAGGERED_AN_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP), _$R.unique.an.list))
$(STAGGERED_AN_LIST) : $$(subst .an.list,.dist, $$@) $$(subst unique.an.list,names, $$@) code/run_an.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_an.sh $(DIST) $(NAMES)

STAGGERED_NN_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP), _$R.unique.nn.list))
$(STAGGERED_NN_LIST) : $$(subst .nn.list,.dist, $$@) $$(subst unique.nn.list,names, $$@) code/run_nn.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_nn.sh $(DIST) $(NAMES)

STAGGERED_FN_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP), _$R.unique.fn.list))
.SECONDEXPANSION:
$(STAGGERED_FN_LIST) : $$(subst .fn.list,.dist, $$@) $$(subst unique.fn.list,names, $$@) code/run_fn.sh
	$(eval DIST=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	bash code/run_fn.sh $(DIST) $(NAMES)

STAGGERED_NEIGHBOR_LIST = $(STAGGERED_AN_LIST) $(STAGGERED_NN_LIST) $(STAGGERED_FN_LIST)


STAGGERED_DEGAP_FASTA = $(subst fasta,ng.fasta,$(STAGGERED_BOOTSTRAP_FASTA))
$(STAGGERED_DEGAP_FASTA) : $$(subst ng.fasta,fasta, $$@)
	mothur "#degap.seqs(fasta=$<)"

STAGGERED_DGC_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP),  _$R.dgc.list))
.SECONDEXPANSION:
$(STAGGERED_DGC_LIST) : $$(subst dgc.list,ng.fasta, $$@) code/run_dgc.sh code/dgc.params.txt code/biom_to_list.R
	$(eval NG_LIST=$(subst dgc.list,ng.dgc.list,$@))
	bash code/run_dgc.sh $<
	mv $(NG_LIST) $@

STAGGERED_AGC_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP),  _$R.agc.list))
.SECONDEXPANSION:
$(STAGGERED_AGC_LIST) : $$(subst agc.list,ng.fasta, $$@) code/run_agc.sh code/agc.params.txt code/biom_to_list.R
	$(eval NG_LIST=$(subst agc.list,ng.agc.list,$@))
	bash code/run_agc.sh $<
	mv $(NG_LIST) $@

STAGGERED_CLOSED_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP),  _$R.closed.list))
.SECONDEXPANSION:
$(STAGGERED_CLOSED_LIST) : $$(subst closed.list,ng.fasta, $$@) code/run_closed.sh code/closedref.params.txt code/biom_to_list.R
	$(eval NG_LIST=$(subst closed.list,ng.closed.list,$@))
	bash code/run_closed.sh $<
	mv $(NG_LIST) $@

STAGGERED_OPEN_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP),  _$R.open.list))
.SECONDEXPANSION:
$(STAGGERED_OPEN_LIST) : $$(subst open.list,ng.fasta, $$@) code/run_open.sh code/openref.params.txt code/biom_to_list.R
	$(eval NG_LIST=$(subst open.list,ng.open.list,$@))
	bash code/run_open.sh $<
	mv $(NG_LIST) $@

STAGGERED_SWARM_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP),  _$R.swarm.list))
.SECONDEXPANSION:
$(STAGGERED_SWARM_LIST) : $$(subst swarm.list,unique.fasta, $$@) $$(subst swarm.list,names, $$@) code/cluster_swarm.R
	$(eval FASTA=$(word 1,$^))
	$(eval NAMES=$(word 2,$^))
	R -e 'source("code/cluster_swarm.R"); get_mothur_list("$(FASTA)", "$(NAMES)")'

STAGGERED_VDGC_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP),  _$R.vdgc.list))
.SECONDEXPANSION:
$(STAGGERED_VDGC_LIST) : $$(subst vdgc.list,ng.fasta, $$@) code/run_vdgc_clust.sh code/uc_to_list.R
	bash code/run_vdgc_clust.sh $<

STAGGERED_VAGC_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP),  _$R.vagc.list))
.SECONDEXPANSION:
$(STAGGERED_VAGC_LIST) : $$(subst vagc.list,ng.fasta, $$@) code/run_vagc_clust.sh code/uc_to_list.R
	bash code/run_vagc_clust.sh $<

STAGGERED_OTUCLUST_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP),  _$R.otuclust.list))
.SECONDEXPANSION:
$(STAGGERED_OTUCLUST_LIST) : $$(subst otuclust.list,ng.fasta, $$@) code/run_otuclust.sh code/otuclust_to_list.R
	bash code/run_otuclust.sh $<

STAGGERED_SUMACLUST_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP),  _$R.sumaclust.list))
.SECONDEXPANSION:
$(STAGGERED_SUMACLUST_LIST) : $$(subst sumaclust.list,ng.fasta, $$@) code/run_sumaclust.sh code/sumaclust_to_list.R
	bash code/run_sumaclust.sh $<

STAGGERED_SORTMERNA_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP),  _$R.sortmerna.list))
.SECONDEXPANSION:
$(STAGGERED_SORTMERNA_LIST) : $$(subst sortmerna.list,ng.fasta, $$@) code/run_sortmerna.sh code/sortmerna_to_list.R code/sortmerna.params.txt
	bash code/run_sortmerna.sh $<

STAGGERED_CVSEARCH_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP),  _$R.cvsearch.list))
.SECONDEXPANSION:
$(STAGGERED_CVSEARCH_LIST) : $$(subst cvsearch.list,ng.fasta, $$@) code/run_cvsearch.sh code/cvsearch_to_list.R
	bash code/run_cvsearch.sh $<

STAGGERED_NINJA_LIST = $(addprefix data/staggered/staggered_1.0, $(foreach R,$(REP),  _$R.ninja.list))
.SECONDEXPANSION:
$(STAGGERED_NINJA_LIST) : $$(subst ninja.list,ng.fasta, $$@) code/run_ninja.sh code/ninja_to_list.R
	bash code/run_ninja.sh $<



STAGGERED_GREEDY_LIST = $(STAGGERED_DGC_LIST) $(STAGGERED_AGC_LIST) $(STAGGERED_OPEN_LIST) $(STAGGERED_CLOSED_LIST) $(STAGGERED_VDGC_LIST) $(STAGGERED_VAGC_LIST) $(STAGGERED_SWARM_LIST) $(STAGGERED_OTUCLUST_LIST) $(STAGGERED_SUMACLUST_LIST) $(STAGGERED_SORTMERNA_LIST) $(STAGGERED_CVSEARCH_LIST) $(STAGGERED_NINJA_LIST)


STAGGERED_NEIGHBOR_SENSSPEC = $(subst list,sensspec, $(STAGGERED_NEIGHBOR_LIST))
.SECONDEXPANSION:
$(STAGGERED_NEIGHBOR_SENSSPEC) : $$(addsuffix .dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@) $$(addsuffix .names,$$(basename $$(basename $$(basename $$@))))
	$(eval LIST=$(word 2,$^))
	$(eval NAMES=$(word 3,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), name=$(NAMES), label=0.03, outputdir=data/staggered)"

STAGGERED_GREEDY_SENSSPEC = $(subst list,sensspec, $(STAGGERED_GREEDY_LIST))

.SECONDEXPANSION:
$(STAGGERED_GREEDY_SENSSPEC) : $$(addsuffix .unique.dist,$$(basename $$(basename $$@)))  $$(subst sensspec,list,$$@) $$(addsuffix .names,$$(basename $$(basename $$@)))
	$(eval LIST=$(word 2,$^))
	$(eval NAMES=$(word 3,$^))
	mothur "#sens.spec(column=$<, list=$(LIST), name=$(NAMES), label=userLabel, cutoff=0.03, outputdir=data/staggered)"

data/staggered/staggered.swarm.opt.sensspec : code/optimize_swarm_sensspec.R $(STAGGERED_SWARM_LIST) $$(addsuffix .unique.dist,$$(basename $$(basename $$(STAGGERED_SWARM_LIST)))) $$(addsuffix .names,$$(basename $$(basename $$(STAGGERED_SWARM_LIST))))
	R -e 'source("code/optimize_swarm_sensspec.R"); optimize_swarm("staggered", fraction="1.0")'

STAGGERED_REF_MCC = data/staggered/staggered.fn.ref_mcc data/staggered/staggered.nn.ref_mcc data/staggered/staggered.an.ref_mcc data/staggered/staggered.agc.ref_mcc data/staggered/staggered.dgc.ref_mcc data/staggered/staggered.closed.ref_mcc data/staggered/staggered.open.ref_mcc data/staggered/staggered.swarm.ref_mcc data/staggered/staggered.vdgc.ref_mcc data/staggered/staggered.vagc.ref_mcc

data/staggered/staggered.an.ref_mcc : code/reference_mcc.R $(STAGGERED_AN_LIST) $(STAGGERED_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/staggered/', 'staggered.*unique.an.list', 'staggered_1.0.*unique.an.list', 'staggered.*names', 'data/staggered/staggered.an.ref_mcc')"

data/staggered/staggered.fn.ref_mcc : code/reference_mcc.R $(STAGGERED_FN_LIST) $(STAGGERED_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/staggered/', 'staggered.*unique.fn.list', 'staggered_1.0_.*unique.fn.list', 'staggered.*names', 'data/staggered/staggered.fn.ref_mcc')"

data/staggered/staggered.nn.ref_mcc : code/reference_mcc.R $(STAGGERED_NN_LIST) $(STAGGERED_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/staggered/', 'staggered.*unique.nn.list', 'staggered_1.0.*unique.nn.list', 'staggered.*names', 'data/staggered/staggered.nn.ref_mcc')"

data/staggered/staggered.closed.ref_mcc : code/reference_mcc.R $(STAGGERED_CLOSED_LIST) $(STAGGERED_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/staggered/', 'staggered.*closed.list', 'staggered_1.0.*closed.list', 'staggered.*names', 'data/staggered/staggered.closed.ref_mcc')"

data/staggered/staggered.open.ref_mcc : code/reference_mcc.R $(STAGGERED_OPEN_LIST) $(STAGGERED_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/staggered/', 'staggered.*open.list', 'staggered_1.0.*open.list', 'staggered.*names', 'data/staggered/staggered.open.ref_mcc')"

data/staggered/staggered.agc.ref_mcc : code/reference_mcc.R $(STAGGERED_AGC_LIST) $(STAGGERED_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/staggered/', 'staggered.*\\\.agc.list', 'staggered_1.0.*\\\.agc.list', 'staggered.*names', 'data/staggered/staggered.agc.ref_mcc')"

data/staggered/staggered.dgc.ref_mcc : code/reference_mcc.R $(STAGGERED_DGC_LIST) $(STAGGERED_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/staggered/', 'staggered.*\\\.dgc.list', 'staggered_1.0.*\\\.dgc.list', 'staggered.*names', 'data/staggered/staggered.dgc.ref_mcc')"

data/staggered/staggered.swarm.ref_mcc : code/reference_mcc.R $(STAGGERED_SWARM_LIST) $(STAGGERED_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/staggered/', 'staggered.*swarm.list', 'staggered_1.0.*swarm.list', 'staggered.*names', 'data/staggered/staggered.swarm.ref_mcc')"

data/staggered/staggered.vdgc.ref_mcc : code/reference_mcc.R $(STAGGERED_VDGC_LIST) $(STAGGERED_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/staggered/', 'staggered.*vdgc.list', 'staggered_1.0.*vdgc.list', 'staggered.*names', 'data/staggered/staggered.vdgc.ref_mcc')"

data/staggered/staggered.vagc.ref_mcc : code/reference_mcc.R $(STAGGERED_VAGC_LIST) $(STAGGERED_NAMES)
	R -e "source('code/reference_mcc.R');run_reference_mcc('data/staggered/', 'staggered.*vagc.list', 'staggered_1.0.*vagc.list', 'staggered.*names', 'data/staggered/staggered.vagc.ref_mcc')"


STAGGERED_POOL_SENSSPEC = data/staggered/staggered.an.pool_sensspec data/staggered/staggered.fn.pool_sensspec data/staggered/staggered.nn.pool_sensspec data/staggered/staggered.dgc.pool_sensspec data/staggered/staggered.agc.pool_sensspec data/staggered/staggered.open.pool_sensspec data/staggered/staggered.closed.pool_sensspec data/staggered/staggered.vdgc.pool_sensspec data/staggered/staggered.vagc.pool_sensspec  data/staggered/staggered.otuclust.pool_sensspec data/staggered/staggered.sumaclust.pool_sensspec data/staggered/staggered.sortmerna.pool_sensspec data/staggered/staggered.cvsearch.pool_sensspec  data/staggered/staggered.ninja.pool_sensspec data/staggered/staggered.swarm.pool_sensspec

data/staggered/staggered.an.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(STAGGERED_AN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/staggered', 'staggered_.*an.sensspec', 'data/staggered/staggered.an.pool_sensspec')"

data/staggered/staggered.fn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(STAGGERED_FN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/staggered', 'staggered_.*fn.sensspec', 'data/staggered/staggered.fn.pool_sensspec')"

data/staggered/staggered.nn.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(STAGGERED_NN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/staggered', 'staggered_.*nn.sensspec', 'data/staggered/staggered.nn.pool_sensspec')"

data/staggered/staggered.dgc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(STAGGERED_DGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/staggered', 'staggered_.*\\\.dgc.sensspec', 'data/staggered/staggered.dgc.pool_sensspec')"

data/staggered/staggered.agc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(STAGGERED_AGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/staggered', 'staggered_.*\\\.agc.sensspec', 'data/staggered/staggered.agc.pool_sensspec')"

data/staggered/staggered.open.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(STAGGERED_OPEN_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/staggered', 'staggered_.*open.sensspec', 'data/staggered/staggered.open.pool_sensspec')"

data/staggered/staggered.closed.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(STAGGERED_CLOSED_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/staggered', 'staggered_.*closed.sensspec', 'data/staggered/staggered.closed.pool_sensspec')"

data/staggered/staggered.vdgc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(STAGGERED_VDGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/staggered', 'staggered_.*vdgc.sensspec', 'data/staggered/staggered.vdgc.pool_sensspec')"

data/staggered/staggered.vagc.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(STAGGERED_VAGC_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/staggered', 'staggered_.*vagc.sensspec', 'data/staggered/staggered.vagc.pool_sensspec')"

data/staggered/staggered.otuclust.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(STAGGERED_OTUCLUST_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/staggered', 'staggered_.*otuclust.sensspec', 'data/staggered/staggered.otuclust.pool_sensspec')"

data/staggered/staggered.sumaclust.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(STAGGERED_SUMACLUST_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/staggered', 'staggered_.*sumaclust.sensspec', 'data/staggered/staggered.sumaclust.pool_sensspec')"

data/staggered/staggered.sortmerna.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(STAGGERED_SORTMERNA_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/staggered', 'staggered_.*sortmerna.sensspec', 'data/staggered/staggered.sortmerna.pool_sensspec')"

data/staggered/staggered.cvsearch.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(STAGGERED_CVSEARCH_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/staggered', 'staggered_.*cvsearch.sensspec', 'data/staggered/staggered.cvsearch.pool_sensspec')"

data/staggered/staggered.ninja.pool_sensspec : code/merge_sensspec_files.R $$(subst list,sensspec, $$(STAGGERED_NINJA_LIST))
	R -e "source('code/merge_sensspec_files.R');merge_sens_spec('data/staggered', 'staggered_.*ninja.sensspec', 'data/staggered/staggered.ninja.pool_sensspec')"

data/staggered/staggered.swarm.pool_sensspec : code/merge_sensspec_files.R data/staggered/staggered.swarm.opt.sensspec
	R -e "source('code/extract_opt_swarm.R');extract_opt_swarm('data/staggered/staggered.swarm.opt.sensspec')"



$(REFS)97_otus.fasta : ~/venv/lib/python2.7/site-packages/qiime_default_reference/gg_13_8_otus/rep_set/97_otus.fasta
	cp -p $< $@

$(REFS)97_otus.taxonomy : ~/venv/lib/python2.7/site-packages/qiime_default_reference/gg_13_8_otus/taxonomy/97_otu_taxonomy.txt
	sed 's/ //g' < ~/venv/lib/python2.7/site-packages/qiime_default_reference/gg_13_8_otus/taxonomy/97_otu_taxonomy.txt > $(REFS)97_otus.taxonomy_temp
	sed 's/$$/;/' < $(REFS)97_otus.taxonomy_temp > $(REFS)97_otus.taxonomy
	rm $(REFS)97_otus.taxonomy_temp

$(REFS)97_otus.idx : ~/venv/lib/python2.7/site-packages/qiime_default_reference/gg_13_8_otus/rep_set/97_otus.fasta
	~/venv/bin/indexdb_rna --ref data/references/97_otus.fasta,data/references/97_otus.idx -v


data/gg_13_8/gg_13_8_97.v19.align : $(REFS)/97_otus.fasta $(REFS)silva.bact_archaea.align
	mothur "#align.seqs(fasta=$(REFS)/97_otus.fasta, reference=$(REFS)silva.bact_archaea.align, processors=2, outputdir=data/gg_13_8);pcr.seqs(fasta=data/gg_13_8/97_otus.align, start=1044, end=43116, keepdots=F, processors=8);filter.seqs(vertical=T)"
	rm data/gg_13_8/97_otus.align.report data/gg_13_8/97_otus.flip.accnos data/gg_13_8/97_otus.pcr.align data/gg_13_8/97_otus.filter
	mv data/gg_13_8/97_otus.pcr.filter.fasta data/gg_13_8/gg_13_8_97.v19.align

data/gg_13_8/gg_13_8_97.v19_ref.unique.align data/gg_13_8/gg_13_8_97.v19_ref.names data/gg_13_8/gg_13_8_97.v19.bad.accnos : data/gg_13_8/gg_13_8_97.v19.align
	mothur "#screen.seqs(fasta=data/gg_13_8/gg_13_8_97.v19.align, start=3967, end=6116, processors=8); unique.seqs()"
	mv data/gg_13_8/gg_13_8_97.v19.good.unique.align data/gg_13_8/gg_13_8_97.v19_ref.unique.align
	mv data/gg_13_8/gg_13_8_97.v19.good.names data/gg_13_8/gg_13_8_97.v19_ref.names
	rm data/gg_13_8/gg_13_8_97.v19.good.align

data/gg_13_8/gg_13_8_97.v4_ref.unique.align data/gg_13_8/gg_13_8_97.v4_ref.names : data/gg_13_8/gg_13_8_97.v19.bad.accnos data/gg_13_8/gg_13_8_97.v19.align
	mothur "#remove.seqs(fasta=data/gg_13_8/gg_13_8_97.v19.align, accnos=data/gg_13_8/gg_13_8_97.v19.bad.accnos); pcr.seqs(fasta=data/gg_13_8/gg_13_8_97.v19.pick.align, keepdots=F, start=3967, end=6116, processors=4); degap.seqs(); unique.seqs()"
	cut -f 1 data/gg_13_8/gg_13_8_97.v19.pick.pcr.ng.names > data/gg_13_8/gg_13_8_97.v19.unique.accnos
	mothur "#get.seqs(fasta=data/gg_13_8/gg_13_8_97.v19.pick.pcr.align, accnos=data/gg_13_8/gg_13_8_97.v19.unique.accnos)"
	mv data/gg_13_8/gg_13_8_97.v19.pick.pcr.pick.align data/gg_13_8/gg_13_8_97.v4_ref.unique.align
	mv data/gg_13_8/gg_13_8_97.v19.pick.pcr.ng.names data/gg_13_8/gg_13_8_97.v4_ref.names
	rm data/gg_13_8/gg_13_8_97.v19.pick.align
	rm data/gg_13_8/gg_13_8_97.v19.pick.pcr.align
	rm data/gg_13_8/gg_13_8_97.v19.pick.pcr.ng.fasta
	rm data/gg_13_8/gg_13_8_97.v19.pick.pcr.ng.unique.fasta
	rm data/gg_13_8/gg_13_8_97.v19.unique.accnos


GG_DIST = data/gg_13_8/gg_13_8_97.v4_ref.unique.dist data/gg_13_8/gg_13_8_97.v19_ref.unique.dist
data/gg_13_8/gg_13_8_97.%.dist : data/gg_13_8/gg_13_8_97.%.align
	mothur "#dist.seqs(fasta=$<, cutoff=0.15, processors=8)"

data/gg_13_8/gg_13_8_97.small_dist.count : $(GG_DIST) code/count_small_distances.R
	R -e "source('code/count_small_distances.R')"



# allows us to compare how well the length of the region is represented
data/gg_13_8/gg_13_8_97.v19.summary : data/gg_13_8/gg_13_8_97.v19.align
	mothur "#summary.seqs(fasta=$<, processors=8)"

data/gg_13_8/gg_13_8_97.overlap.count : data/gg_13_8/gg_13_8_97.v19.summary code/count_region_overlap.R
	R -e "source('code/count_region_overlap.R')"


# see how many taxa are represented in duplicate sequences
data/gg_13_8/duplicate.analysis : code/run_duplicate_analysis.R data/gg_13_8/gg_13_8_97.v4_ref.names ~/venv/lib/python2.7/site-packages/qiime_default_reference/gg_13_8_otus/taxonomy/97_otu_taxonomy.txt
	R -e "source('code/run_duplicate_analysis.R')"

data/rand_ref/miseq.ref.mapping : code/map_mouse_to_gg.sh code/distance.cpp code/map_to_reference.R data/miseq/miseq.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.fasta data/gg_13_8/97_otus.align data/references/silva.bact_archaea.align
	bash code/map_mouse_to_gg.sh

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

data/rand_ref/miseq.unique.fasta : data/rand_ref/miseq.fasta
	mothur "#unique.seqs(fasta=$<)"



RAND_REF_UCLUSTER = $(addprefix data/rand_ref/rand_ref_, $(foreach R,$(REP),  1.0_$R.uclosed.uc)) data/rand_ref/original.uclosed.uc
$(RAND_REF_UCLUSTER) : $$(subst uclosed.uc,fasta, $$@) code/run_rand_uref.sh data/rand_ref/miseq.fasta
	bash code/run_rand_uref.sh $<

RAND_REF_VCLUSTER = $(addprefix data/rand_ref/rand_ref_, $(foreach R,$(REP),  1.0_$R.vclosed.vc)) data/rand_ref/original.vclosed.vc
$(RAND_REF_VCLUSTER) : $$(subst vclosed.vc,fasta, $$@) code/run_rand_vref.sh data/rand_ref/miseq.fasta
	bash code/run_rand_vref.sh $<

RAND_REF_SCLUSTER = $(addprefix data/rand_ref/rand_ref_, $(foreach R,$(REP),  1.0_$R.sclosed.sc)) data/rand_ref/original.sclosed.sc
$(RAND_REF_SCLUSTER) : $$(subst sclosed.sc,fasta, $$@) code/run_rand_sref.sh data/rand_ref/miseq.unique.fasta
	bash code/run_rand_sref.sh $<

RAND_REF_NCLUSTER = $(addprefix data/rand_ref/rand_ref_, $(foreach R,$(REP),  1.0_$R.nclosed.nc)) data/rand_ref/original.nclosed.nc
$(RAND_REF_NCLUSTER) : $$(subst nclosed.nc,fasta, $$@) code/run_rand_nref.sh data/rand_ref/miseq.unique.fasta
	bash code/run_rand_nref.sh $<


data/rand_ref/hits.uclosed.summary data/rand_ref/overlap.uclosed.summary data/rand_ref/hits.uclosed.counts : code/summarize_rand_ref.R $(RAND_REF_UCLUSTER)
	R -e "source('code/summarize_rand_ref.R'); summarize_rand_ref('u')"

data/rand_ref/hits.vclosed.summary data/rand_ref/overlap.vclosed.summary data/rand_ref/hits.vclosed.counts : code/summarize_rand_ref.R $(RAND_REF_VCLUSTER)
	R -e "source('code/summarize_rand_ref.R'); summarize_rand_ref('v')"

data/rand_ref/hits.sclosed.summary data/rand_ref/overlap.sclosed.summary data/rand_ref/hits.sclosed.counts : code/summarize_rand_ref.R $(RAND_REF_SCLUSTER)
	R -e "source('code/summarize_rand_ref.R'); summarize_rand_ref('s')"

data/rand_ref/hits.nclosed.summary data/rand_ref/overlap.nclosed.summary data/rand_ref/hits.nclosed.counts : code/summarize_rand_ref.R $(RAND_REF_NCLUSTER)
	R -e "source('code/summarize_rand_ref.R'); summarize_rand_ref('n')"



data/rand_ref/closed_ref.usearch.sensspec : code/closed_ref_analysis.R $(RAND_REF_UCLUSTER) data/gg_13_8/gg_13_8_97.v4_ref.names data/rand_ref/miseq.ref.mapping
	R -e "source('code/closed_ref_analysis.R'); run_sens_spec_analysis('usearch')"

data/rand_ref/closed_ref.vsearch.sensspec : code/closed_ref_analysis.R $(RAND_REF_VCLUSTER) data/gg_13_8/gg_13_8_97.v4_ref.names data/rand_ref/miseq.ref.mapping
	R -e "source('code/closed_ref_analysis.R'); run_sens_spec_analysis('vsearch')"

data/rand_ref/closed_ref.sortmerna.sensspec : code/closed_ref_analysis.R $(RAND_REF_SCLUSTER) data/gg_13_8/gg_13_8_97.v4_ref.names data/rand_ref/miseq.ref.mapping
	R -e "source('code/closed_ref_analysis.R'); run_sens_spec_analysis('sortmerna')"

data/rand_ref/closed_ref.ninja.sensspec : code/closed_ref_analysis.R $(RAND_REF_NCLUSTER) data/gg_13_8/gg_13_8_97.v4_ref.names data/rand_ref/miseq.ref.mapping
	R -e "source('code/closed_ref_analysis.R'); run_sens_spec_analysis('ninja')"

data/process/closed_ref_sensspec.summary : code/finalize_rand_ref.R\
									data/rand_ref/closed_ref.usearch.sensspec\
									data/rand_ref/closed_ref.vsearch.sensspec\
									data/rand_ref/closed_ref.sortmerna.sensspec\
									data/rand_ref/closed_ref.ninja.sensspec\
									data/rand_ref/hits.nclosed.summary\
									data/rand_ref/hits.sclosed.summary\
									data/rand_ref/hits.uclosed.summary\
									data/rand_ref/hits.vclosed.summary
	R -e "source('$<')"






data/rand_ref/closed_ref.redundancy.analysis : code/closed_ref_analysis.R data/gg_13_8/gg_13_8_97.v4_ref.names data/rand_ref/miseq.ref.mapping data/references/97_otus.taxonomy
	R -e "source('code/closed_ref_analysis.R'); run_redundancy_analysis()"


data/process/he.mcc_ref.summary : code/summarize_mcc_ref.R $(HE_REF_MCC)
	R -e "source('code/summarize_mcc_ref.R'); summarize_mcc_ref('he')"

data/process/miseq.mcc_ref.summary : code/summarize_mcc_ref.R $(MISEQ_REF_MCC)
	R -e "source('code/summarize_mcc_ref.R'); summarize_mcc_ref('miseq')"

data/process/he.rarefaction.summary : code/summarize_rarefaction.R $(HE_RAREFACTION)
	R -e "source('code/summarize_rarefaction.R'); summarize_rarefaction('he')"

data/process/miseq.rarefaction.summary : code/summarize_rarefaction.R $(MISEQ_RAREFACTION)
	R -e "source('code/summarize_rarefaction.R'); summarize_rarefaction('miseq')"



data/process/he.mcc.summary : code/summarize_mcc.R $(HE_POOL_SENSSPEC)
	R -e "source('code/summarize_mcc.R'); summarize_mcc('he')"

data/process/miseq.mcc.summary : code/summarize_mcc.R $(MISEQ_POOL_SENSSPEC) data/miseq/miseq.swarm.opt.sensspec
	R -e "source('code/summarize_mcc.R'); summarize_mcc('miseq')"

data/process/even.mcc.summary : code/summarize_mcc.R $(EVEN_POOL_SENSSPEC) data/even/even.swarm.opt.sensspec
	R -e "source('code/summarize_mcc.R'); summarize_mcc('even')"

data/process/staggered.mcc.summary : code/summarize_mcc.R $(STAGGERED_POOL_SENSSPEC) data/staggered/staggered.swarm.opt.sensspec
	R -e "source('code/summarize_mcc.R'); summarize_mcc('staggered')"



results/figures/figure_1.pdf : code/build_mcc_plot.R data/process/he.mcc_ref.summary\
								data/process/he.mcc.summary\
								data/he/he.swarm.opt.sensspec
	R -e "source('code/build_mcc_plot.R'); build_mcc_plots('he', '$@')"

results/figures/figure_2.pdf : code/build_figure2.R data/process/he.rarefaction.summary
	R -e "source('code/build_figure2.R'); build_figure2('he', '$@')"

results/figures/figure_3.pdf : code/build_mcc_plot.R data/process/miseq.mcc_ref.summary\
								data/process/miseq.mcc.summary\
								data/miseq/miseq.swarm.opt.sensspec
	R -e "source('code/build_mcc_plot.R'); build_mcc_plots('miseq', '$@')"

results/figures/figure_4.pdf : code/build_figure4.R data/process/miseq.mcc_ref.summary\
							data/process/he.mcc_ref.summary\
							data/process/he.mcc.summary data/process/miseq.mcc.summary
	R -e "source('code/build_figure4.R')"

results/figures/figure_5.pdf : code/build_figure5.R data/rand_ref/hits.uclosed.counts\
							data/rand_ref/hits.vclosed.counts\
							data/rand_ref/closed_ref.redundancy.analysis
	R -e "source('code/build_figure5.R')"


results/figures/figure_2_miseq.pdf : code/build_figure2.R data/process/miseq.rarefaction.summary
	R -e "source('code/build_figure2.R'); build_figure2('miseq', '$@', 'topright')"


get.paper_data : data/gg_13_8/gg_13_8_97.v4_ref.names\
	data/he/canada_soil.good.unique.pick.redundant.fasta\
	data/he/canada_soil.good.unique.pick.fasta\
	data/process/he.mcc_ref.summary\
	data/gg_13_8/gg_13_8_97.overlap.count\
	data/miseq/miseq.seq.info\
	data/process/miseq.mcc_ref.summary\
	data/process/miseq.mcc.summary\
	data/rand_ref/hits.uclosed.summary\
	data/rand_ref/hits.vclosed.summary\
	data/gg_13_8/gg_13_8_97.small_dist.count\
	data/rand_ref/overlap.uclosed.summary\
	data/rand_ref/overlap.vclosed.summary\
	data/gg_13_8/duplicate.analysis\
	data/rand_ref/closed_ref.usearch.sensspec\
	data/rand_ref/closed_ref.vsearch.sensspec\
	data/rand_ref/closed_ref.redundancy.analysis\
	results/figures/figure_1.pdf\
	results/figures/figure_2.pdf\
	results/figures/figure_3.pdf\
	results/figures/figure_4.pdf\
	results/figures/figure_5.pdf

write.paper : papers/peerj_2015/Schloss_Cluster_PeerJ_2015.Rmd get.paper_data
	R -e "render('papers/peerj_2015/Schloss_Cluster_PeerJ_2015.Rmd', clean=FALSE)"
	mv papers/peerj_2015/Schloss_Cluster_PeerJ_2015.utf8.md papers/peerj_2015/Schloss_Cluster_PeerJ_2015.md
	rm papers/peerj_2015/Schloss_Cluster_PeerJ_2015.knit.md




get.commentary_data : data/process/even.mcc.summary\
 					data/process/he.mcc.summary\
					data/process/miseq.mcc.summary\
 					data/process/staggered.mcc.summary\
					data/process/closed_ref_sensspec.summary

results/figures/all_method_comparison.pdf : code/build_all_methods_compare_plot.R\
					get.commentary_data
	R -e "source('$<')"

write.commentary : papers/msystems_2016/Schloss_Commentary_mSystems_2016.Rmd\
					get.commentary_data\
					results/figures/all_method_comparison.pdf
	R -e "render('papers/msystems_2016/Schloss_Commentary_mSystems_2016.Rmd', clean=FALSE)"
	mv papers/msystems_2016/Schloss_Commentary_mSystems_2016.utf8.md papers/msystems_2016/Schloss_Commentary_mSystems_2016.md
	rm papers/msystems_2016/Schloss_Commentary_mSystems_2016.knit.md


papers/msystems_2016/Schloss_Commentary_mSystems_2016_track_changes.pdf: \
					papers/msystems_2016/Schloss_Commentary_mSystems_2016.md\
					papers/msystems_2016/references.bib\
					papers/msystems_2016/msystems.csl\
					papers/msystems_2016/header.tex

	OPTS="--bibliography=papers/msystems_2016/references.bib --csl=papers/msystems_2016/msystems.csl  --filter=pandoc-citeproc --include-in-header=papers/msystems_2016/header.tex"
	git show b81452c1cec7:$< > orig.md
	pandoc orig.md -o orig.tex $(OPTS)
	pandoc $< -o revised.tex $(OPTS)
	latexdiff orig.tex revised.tex > diff.tex
	pdflatex diff
	mv diff.pdf $@
	rm {revised,orig,diff}.tex

papers/msystems_2016/Schloss_Commentary_mSystems_2016_response.pdf: \
					papers/msystems_2016/ResponseToReviewers.md
	pandoc $< -o $@
