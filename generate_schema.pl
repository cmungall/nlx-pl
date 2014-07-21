:- use_module(library(semweb/rdf_library)).
:- use_module(library(semweb/rdf_http_plugin)).
:- use_module(library(semweb/rdf_cache)).
:- use_module(library(semweb/rdf_db)).
:- use_module(library(semweb/rdfs)).
:- use_module(library(rdfs2pl)).
:- rdf_attach_library('void.ttl').

:- rdf_set_cache_options([ global_directory('RDF-Cache'),
                           create_global_directory(true)
                         ]).

:- rdf_register_ns(nlxp,'http://neurolex.org/wiki/Property-3A').
:- rdf_register_ns(nlxc,'http://neurolex.org/wiki/Category-3A').

gen :-
    rdf_load_library(nlx),
    tell('nlxs.pl'),
    write_schema(nlxs,'http://neurolex.org/wiki/',[use_labels(true)]),
    told.

