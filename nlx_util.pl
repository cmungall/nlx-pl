/* -*- Mode: Prolog -*- */

:- use_module(library(debug)).
:- use_module(library(semweb/rdf_turtle_write)).

:- rdf_load_library(nlx).
:- rdf_load_library(ro).
:- ensure_loaded(nlxs).


:- rdf_register_ns(obo,'http://purl.obolibrary.org/obo/').
:- rdf_register_ns(oio,'http://www.geneontology.org/formats/oboInOwl#').


%% pdump(+Pred) is det
%
% writes all triples using Pred as TSV
%
pdump(P) :-
        T =.. [P,_,_],
        forall(T, wtriple(T)).

% write a triple as a TSV, using labels instead of URIs
wtriple(T) :-
        T=..[P,X,Y],
        lbl(X,XN),
        lbl(Y,YN),
        format('~w\t~w\t~w~n',[P,XN,YN]).

:- rdf_meta id_pv(?,r,o).
id_pv(Id,P,V) :-
        X id Id,
        rdf(X,P,V).


% note: is reflexive
sameid(X,Y) :-
        X id Id,
        Y id Id.

electrophysiology_concept_a(Y) :-
        electrophysiology_concept(X),
        sameid(X,Y).

neuron_a(Y) :-
        neuron(X),
        sameid(X,Y).

ep_prop_usage(P,Num) :-
        aggregate(count,V,X^(electrophysiology_concept_a(X),rdf(X,P,V)),Num).

neuron_prop_usage(P,Num) :-
        aggregate(count,V,X^(neuron_a(X),rdf(X,P,V)),Num).

non_resource_prop_usage(P,Num) :-
        aggregate(count,V,X^(non_resource(X),rdf(X,P,V)),Num).

non_resource(X) :-
        X id _,
        \+ resource(X).

show_non_resource_prop_usage :-
        non_resource_prop_usage(P,Num),
        format('~w\t~w~n',[Num,P]),
        fail.
show_non_resource_prop_usage.

% IRI to labels.
%
% NOTE: any nlx IRI may have both rdfs:labels and its own label property
lbl(X,XN) :- rdfs_label(X,XN),!.
lbl(X,X).

rdfs_label_2(X,L) :- rdfs_label(X,L).
rdfs_label_2(X,L) :- rdf(X,rdfs:label,literal(type(_,L))).


nlxowl_uri('http://purl.obolibrary.org/obo/cl/nlx.owl').

nlx2owl :-
        debug(nlx),
        rdf_load_library(nlx),
        rdf_load_library(ro),
        nlxowl_uri(Ont),
        map_nlx(Ont),
        rdf_save_turtle('nlx-owl.ttl',[graph(Ont)]).



% Extract OWL axioms from triples using w/3,
% assert into G
map_nlx(G) :-
        v(P,X,Y),
        expand_pred(P,P2),
        %debug(nlx,'~w -> [ ~w ] -> ~w',[X,P2,Y]),
        rdf_assert_wrap(X,P2,Y,G),
        fail.
map_nlx(_).

% rdf_assert/4 with special sauce for OWL shortcuts
rdf_assert_wrap(X,P,some(Y),G) :-
        !,
        %debug(nlx,'~w SubClassOf  ~w SOME ~w',[X,P,Y]),
        rdf_bnode(Restr),
        rdf_assert(Restr,rdf:type,owl:'Restriction',G),
        rdf_assert(X,rdfs:subClassOf,Restr,G),
        rdf_assert(Restr,owl:onProperty,P,G),
        rdf_assert(Restr,owl:someValuesFrom,Y,G).
rdf_assert_wrap(X,P,Y,G) :-
        rdf_assert(X,P,Y,G).

% we use shorthand such as in_taxon in this module;
% these are expanded to complete IRIs, based on label.
% this relies on rdfs:labels being loader for RO, IAO, etc
expand_pred(P,PIRI) :-
        pmap(P,Frag),
        !,
        atom_concat('http://purl.obolibrary.org/obo/',Frag,PIRI).
expand_pred(P,PIRI) :-
        %debug(nlx,'EXP: ~w',[P]),
        concat_atom(Toks,'_',P),
        concat_atom(Toks,' ',Label),
        rdfs_label_2(PIRI,Label),
        atom_concat('http://purl.obolibrary.org/obo/',_,PIRI),
        !.
expand_pred(P,P).


%% v( ?Pred, ?X, ?Y ) is nondet
%
% view predicate for generating OWLish triples from neurolex.
% This is not as straightforward as mapping predicates;
% we have to 'join' based on the Id field.

:- rdf_meta v(o,r,r).

v( rdfs:subClassOf, X, Y ) :-
        rdf(NX, rdfs:subClassOf, NY),
        map_iri(NX,X),
        map_iri(NY,Y).

v( rdfs:label, X, V ) :-
        rdf(NX, nlxp:'Label', V),
        map_iri(NX,X).

v( definition, X, literal(V) ) :-
        NX definition V,
        map_iri(NX,X).

v( oio:hasRelatedSynonym, X, literal(V) ) :-
        NX synonym V,
        map_iri(NX,X).

% TODO: make this leff obo-centric
% this is useful for now as we don't have a way of tracking 'merges' in the nlx2owl transition
v( oio:hasDbXref, X, literal(V) ) :-
        NX id Id,
        downcase_atom(Id,Id_Dn),
        atom_concat('nifstd:',Id_Dn),
        map_iri(NX,X).


v( in_taxon, X, some(Y) ) :-
        NX species S,
        S taxID TaxFrag,
        atom_concat('http://purl.obolibrary.org/obo/NCBITaxon_',TaxFrag,Y),
        map_iri(NX,X).

% todo - soma part of
v( part_of, X, some(Y) ) :-
        NX located_in NY,
        map_iri(NX,X),
        map_iri(NY,Y).

v( part_of, X, some(Y) ) :-
        NX is_part_of NY,
        map_iri(NX,X),
        map_iri(NY,Y).

v( overlaps, X, some(Y) ) :-
        NX partiallyOverlapsWith NY,
        map_iri(NX,X),
        map_iri(NY,Y).

v( fasciculates_with, X, some(Y) ) :-
        NX fasciculates_with NY,
        map_iri(NX,X),
        map_iri(NY,Y).

% Notes from DOS:
% Possibly - has presynaptic terminal in?  (seems safe to assume
% terminal arbor of axon forms synapses - at least in most cases).
% Defining 'arborizes in' would be harder as formal of arbor may be
% hard.  Maybe 'has terminal arbor in' SubProperty of overlaps) -
% letting user judgment apply for what counts as terminal arbor.
v( has presynaptic terminal in, X, some(Y) ) :-
        NX location_of_distant_axon_arborization NY,
        map_iri(NX,X),
        map_iri(NY,Y).



v( defining_criteria, X, literal(V) ) :-
        NX definingCriteria V,
        map_iri(NX,X).

v( abbreviation, X, literal(V) ) :-
        NX abbrev V,
        map_iri(NX,X).

/*
Category:Fusiform 
Category:Fusiform Soma Quality 
Category:Granule 
Category:Granule Soma Quality
Category:Mitral 
Category:Multipolar 
Category:Other 
Category:Oval 
Category:Oval Soma Quality 
Category:Pear-shaped 
Category:Pyramidal 
Category:Pyramidal Soma Quality 
Category:Round, oval, fusiform 
Category:Spherical 
Category:Spherical Soma Quality 
Category:bipolar 

  */

v( has_quality, X, some(Y) ) :-
        NX cellSomaShape NY,
        map_iri(NX,X),
        map_iri(NY,Y).

% TODO
v( has_quality, X, some(Y) ) :-
        NX neurotransmitter NY,
        map_iri(NX,X),
        map_iri(NY,Y).


%v( has_part, X, myelinated_axon ) :-
%        NX axonMyelination myelinated,
%        map_iri(NX,X).



%neurotransmitterReceptors
/*
http://neurolex.org/wiki/Category-3A5HT
http://neurolex.org/wiki/Category-3AACh_muscarinic_M3
http://neurolex.org/wiki/Category-3AAMPA-2Dtype_glutamate-2Dgated_cationic_channel
http://neurolex.org/wiki/Category-3AATP-2Dgated_ion_channel
http://neurolex.org/wiki/Category-3AAcetylcholine
http://neurolex.org/wiki/Category-3AAcetylcholine-2Dgated_channel_(nicotinic)
http://neurolex.org/wiki/Category-3AAcetylcholine_Receptor
http://neurolex.org/wiki/Category-3AAdenosine_A2
http://neurolex.org/wiki/Category-3ABombesin_type_2_receptor
http://neurolex.org/wiki/Category-3AD1_receptor
http://neurolex.org/wiki/Category-3AD2_receptor
http://neurolex.org/wiki/Category-3ADopamine
http://neurolex.org/wiki/Category-3ADopamine_D3R
http://neurolex.org/wiki/Category-3AFrom_horizontal_cells
http://neurolex.org/wiki/Category-3AGABA
http://neurolex.org/wiki/Category-3AGABA-2DA
http://neurolex.org/wiki/Category-3AGABA-2DB
http://neurolex.org/wiki/Category-3AGABA-2DB_Receptor
http://neurolex.org/wiki/Category-3AGABA-2Dgated_anionic_channel
http://neurolex.org/wiki/Category-3AGABA-2Dgated_channels
http://neurolex.org/wiki/Category-3AGABA_A-2Dgated_anionic_channel
http://neurolex.org/wiki/Category-3AGABA_B
http://neurolex.org/wiki/Category-3AGABA_C-2Dgated_anionic_channel
http://neurolex.org/wiki/Category-3AGABA_receptor
http://neurolex.org/wiki/Category-3AGa
http://neurolex.org/wiki/Category-3AGlutamate
http://neurolex.org/wiki/Category-3AGlutamate-2Dgated_cationic_channel
http://neurolex.org/wiki/Category-3AGlutamate-2Dgated_channels
http://neurolex.org/wiki/Category-3AGlutamate_receptor
http://neurolex.org/wiki/Category-3AGlycine-2Dgated_chloride_channel
http://neurolex.org/wiki/Category-3AKainate_glutamate-2Dgated_cationic_channel
http://neurolex.org/wiki/Category-3AMGluR1alpha
http://neurolex.org/wiki/Category-3AMu_receptor
http://neurolex.org/wiki/Category-3AMuscarinic_ACh
http://neurolex.org/wiki/Category-3AMuscarinic_ACh_receptor
http://neurolex.org/wiki/Category-3AMuscarinic_M4R
http://neurolex.org/wiki/Category-3ANAChR
http://neurolex.org/wiki/Category-3ANK-2D1
http://neurolex.org/wiki/Category-3ANMDA
http://neurolex.org/wiki/Category-3ANMDA-2Dtype_glutamate-2Dgated_cationic_channel
http://neurolex.org/wiki/Category-3ANot_known
http://neurolex.org/wiki/Category-3AOctopamine
http://neurolex.org/wiki/Category-3AP2Y4
http://neurolex.org/wiki/Category-3AP2x2
http://neurolex.org/wiki/Category-3AP2y1
http://neurolex.org/wiki/Category-3ASerotonin
http://neurolex.org/wiki/Category-3AUnknown
http://neurolex.org/wiki/Category-3AVPAC2_receptor

  */

/*
% ['http://neurolex.org/wiki/Category-3AIntrinsic_neuron_role', 'http://neurolex.org/wiki/Category-3AModulatory', 'http://neurolex.org/wiki/Category-3AMotor_role_of_nerve_cell', 'http://neurolex.org/wiki/Category-3ANociceptive_role_of_nerve_cell', 'http://neurolex.org/wiki/Category-3APrincipal_neuron_role', 'http://neurolex.org/wiki/Category-3ASensory_reception_role']

v( has_role, X, V ) :-
        NX originOfAxon V,
        % ['44', dendrite, 'no axon', soma, 'soma and sometimes dendrite'].
        map_iri(NX,X).
*/

/*
v( axon_part_of, X, V ) :-
        NX originOfAxon V,
        % ['44', dendrite, 'no axon', soma, 'soma and sometimes dendrite'].
        map_iri(NX,X).
*/

% We take the Id property as primary, and use this to construct a URI.
% Note that some resources share an Id field, so we end up 'collapsing' or mapping these onto a common IRI - this is intentional.
% additionally, some resources may have >1 Id value
map_iri(NX,X) :-
        NX id FragOrig,
        fix_frag(FragOrig, Frag),  % repair
        xfrag(Frag,X).

% occasionally some classes do not have Ids - e.g. 'http://neurolex.org/wiki/Category-3ACell_layer'
map_iri(NX,X) :-
        rdf(NX_Equiv, owl:sameAs, NX),
        NX_Equiv id FragOrig,
        fix_frag(FragOrig, Frag),  % repair
        xfrag(Frag,X).

% Argh. Sometimes the value of the Id field is 'CHEBI: 10093'
fix_frag(X,Y) :-
        concat_atom(Toks,' ',X),
        Toks=[_,_|_],
        !,
        concat_atom(Toks,'',Y).
fix_frag(X,X).

        
% expand a fragment;
% map all OBO-like IDs to OBO, and everything else to nifstd
xfrag(Frag,X) :-
        is_obo_frag(Frag),
        !,
        rdf_global_id(obo:Frag,X).

xfrag(Frag,X) :-
        rdf_global_id(nifstd:Frag,X).

is_obo_frag(Frag) :- atom_concat('CHEBI',_,Frag).
is_obo_frag(Frag) :- atom_concat('UBERON',_,Frag).

dupe(A,B,Id) :-
        id(A,Id),
        \+ atom_concat('http://neurolex.org/wiki/Category',_,A),
        id(B,Id),
        \+ atom_concat('http://neurolex.org/wiki/Category',_,B),
        A@<B.
        
pmap(in_taxon,'RO_0002162').





        
