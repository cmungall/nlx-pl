:- rdf_load_library(nlx).
:- ensure_loaded(nlxs).

pdump(P) :-
        T =.. [P,_,_],
        forall(T, wtriple(T)).


wtriple(T) :-
        T=..[P,X,Y],
        lbl(X,XN),
        lbl(Y,YN),
        format('~w\t~w\t~w~n',[P,XN,YN]).

lbl(X,XN) :- rdfs_label(X,XN),!.
lbl(X,X).

map_nlx :-
        rdf_library_load(nlx),
        rdf_library_load(ro),
        map_nlx('http://purl.obolibrary.org/obo/cl/nlx.owl').


map_nlx(G) :-
        v(P,X,Y),
        expand_pred(P,P2),
        rdf_assert_wrap(X,P2,Y,G),
        fail.
map_nlx(_).

rdf_assert_wrap(X,P,some(Y),G) :-
        !,
        foo.
rdf_assert_wrap(X,P,Y,G) :-
        rdf_assert(X,P,Y).


:- rdf_meta v(r,r,r).

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

v( related_synonym, X, literal(V) ) :-
        NX synonym V,
        map_iri(NX,X).

  
v( in_taxon, X, some(Y) ) :-
        NX species S,
        S taxID TaxFrag,
        atom_concat('http://purl.obolibrary.org/obo/NCBITaxon_',TaxFrag,Y),
        map_iri(NX,X).

v( part_of, X, some(Y) ) :-
        NX located_in NY,
        map_iri(NX,X),
        map_iri(NY,Y).

v( defining_criteria, X, literal(V) ) :-
        NX definingCriteria V,
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
        NX cellSomeShape NY,
        map_iri(NX,X),
        map_iri(NY,Y).

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

map_iri(NX,X) :-
        NX id Frag,
        xfrag(Frag,X).

xfrag(Frag,X) :-
        is_obo_frag(Frag),
        !,
        rdf_global_id(obo:Frag,X).

xfrag(Frag,X) :-
        rdf_global_id(nifstd:Frag,X).

is_obo_frag(Frag) :- atom_concat('CHEBI',_,Frag).
is_obo_frag(Frag) :- atom_concat('UBERON',_,Frag).

        
        




        
