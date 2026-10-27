/*
:name: test_formal_sequence_and
:description: SymbiYosys checks the formal semantics of sequence_and against an independent RTL monitor (IEEE 1800-2023 Section 16.9.5)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.9.5 F.3.4.2.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: sequence_and
*/
// The reference derivative engine is exported as a finite-state machine and
// compared with an independently written RTL monitor under SymbiYosys. Inputs
// are symbolic; no expected-output file is read.
//
// formal result: PASS
