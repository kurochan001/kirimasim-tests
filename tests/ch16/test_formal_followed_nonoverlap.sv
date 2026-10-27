/*
:name: test_formal_followed_nonoverlap
:description: SymbiYosys checks the formal semantics of followed_nonoverlap against an independent RTL monitor (IEEE 1800-2023 Section 16.12.7)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12.7 F.3.4.3.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: followed_nonoverlap
*/
// The reference derivative engine is exported as a finite-state machine and
// compared with an independently written RTL monitor under SymbiYosys. Inputs
// are symbolic; no expected-output file is read.
//
// formal result: PASS
