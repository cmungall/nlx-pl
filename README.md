## Synopsis

## Description

This repo contains a collection of prolog utilities for querying and
extracting information from NeuroLex.

Prolog has a number of benefits here:

 * Fast loading of nlx triples
 * More powerful programmatic / transformative/ declarative access than SPARQL

## Notes

The neurolex triplestore has dual representations of everything.

E.g. for http://uri.neuinfo.org/nif/nifstd/sao2128417084

    Sao2128417084 type 'Neuron'
        rdfs:label Sao2128417084
        nlxp:label 'Neocortex pyramidal cell'
        located_in Neocortex
            inv(sameAs) ...
        AxonMyelination 'myelinated'
        Id sao2128417084
        sameAs  Neocortex_pyramidal_cell
                     type owl:Class
                     label 'Neocortex pyramidal cell'
                     AxonMyelination 'myelinated'
