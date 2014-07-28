
# fetch RDF
nlx_stage_all.rdf: 
	wget -N http://neurolex.org/OWL/$@

# note: this only needs regenerated if the properties or core classes in the Nlx RDF
# change substantially. the version in the repo should be good enough for most purposes.
nlxs.pl: nlx_stage_all.rdf
	swipl -g "[generate_schema],gen,halt"

nlx-owl.ttl: nlxs.pl
	swipl -g [nlx_util],nlx2owl,halt

nlx-owl.owl: nlx-owl.ttl
	owltools $< -o $@

non_resource_props.txt:
	swipl -g [nlx_util],show_non_resource_prop_usage,halt | sort -r -n > $@
