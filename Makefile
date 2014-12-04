OBO := http://purl.obolibrary.org/obo

# fetch RDF
nlx_stage_all.rdf: 
	wget -N http://neurolex.org/OWL/$@

# Neurolex schema
# note: this only needs regenerated if the properties or core classes in the Nlx RDF
# change substantially. the version in the repo should be good enough for most purposes.
nlxs.pl: nlx_stage_all.rdf
	swipl -g "[generate_schema],gen,halt"

# rewrite into turtle format.
# at this stage, lacks an ontology header, imports
nlx-owl.ttl: nlxs.pl
	swipl -g [nlx_util],nlx2owl,halt

nlx-owl.owl: nlx-owl.ttl
	owltools --create-ontology $(OBO)/nlx  $< --merge-support-ontologies --add-imports-declarations $(OBO)/ro.owl -o $@

nlx-neuron.owl: nlx-owl.owl
	owltools --use-catalog $< --reasoner-query -r elk -d -c nlx/neuron -l Neuron -o $@

nlx-ns-part.owl: nlx-owl.owl
	owltools --use-catalog $< --reasoner-query -r elk -d -c nlx/ns-part -l 'Regional part of nervous system' -o $@

nlx-epc.owl: nlx-owl.owl
	owltools --use-catalog $< --reasoner-query -r elk -d -c $(OBO)/nlx/epc -l 'Electrophysiology concept' -o $@

non_resource_props.txt:
	swipl -g [nlx_util],show_non_resource_prop_usage,halt | sort -r -n > $@

%.obo: %.owl
	owltools $< -o -f obo --no-check $@.tmp && ./util/mk-obo-pfx.pl  $@.tmp > $@
%-dn.obo: %.obo
	./util/fix-leading-uppercase.pl $< > $@


iao.ttl:
	owltools $(OBO)/iao.owl -o -f ttl $@
