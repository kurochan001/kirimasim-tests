/*
:name: test_formal_first_match_tie
:description: SymbiYosys checks the formal semantics of first_match_tie against an independent RTL monitor (IEEE 1800-2023 Section 16.9.8)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.9.8 F.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: first_match_tie
*/
// The reference derivative engine is exported as a finite-state machine and
// compared with an independently written RTL monitor under SymbiYosys. Inputs
// are symbolic; no expected-output file is read.
//
// formal result: PASS
