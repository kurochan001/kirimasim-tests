/*
:name: test_formal_sequence_or_multiplicity
:description: SymbiYosys checks the formal semantics of sequence_or_multiplicity against an independent RTL monitor (IEEE 1800-2023 Section 16.9.7)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.9.7 F.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: sequence_or_multiplicity
*/
// The reference derivative engine is exported as a finite-state machine and
// compared with an independently written RTL monitor under SymbiYosys. Inputs
// are symbolic; no expected-output file is read.
//
// formal result: PASS
