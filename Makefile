nlx_stage_all.rdf: 
	wget -N http://neurolex.org/OWL/$@

nlxs.pl: nlx_stage_all.rdf
	swipl -g "[generate_schema],gen,halt"
