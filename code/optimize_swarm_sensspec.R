
optimize_swarm <- function(dataset, fraction = c('0.2', '0.4', '0.6', '0.8', '1.0')){
	root <- paste0('data/', dataset, '/', dataset, '_')
	rep <- c(paste(0, 1:9, sep=""), 10:30)
	cutoff <- c(0.00, 0.01, 0.02, 0.03, 0.04, 0.05)

	outputdir <- paste0('data/', dataset)

	confusion <- data.frame()

	for(f in fraction){

		for(r in rep){
			dist <- paste0(root, f, '_', r, '.unique.dist')
			list <- paste0(root, f, '_', r, '.swarm.list')
			names <- paste0(root, f, '_', r, '.names')
			sensspec <- paste0(root, f, '_', r, '.swarm.sensspec')

			for(co in cutoff){
				command <- paste0('mothur --quiet "#sens.spec(column=', dist, ', list=', list, ', name=', names, ', label=userLabel, cutoff=', co, ', outputdir=', outputdir, ')"')
				system(command)

				#concatenate cutoffs
				results <- read.table(file=sensspec, header=T)
				results$label <- list
				confusion <- rbind(confusion, results)
			}
		}
	}

	output_file <- paste0('data/', dataset, '/', dataset, '.swarm.opt.sensspec')
	write.table(confusion, file=output_file, row.names=FALSE, quote=FALSE, sep='\t')
}
