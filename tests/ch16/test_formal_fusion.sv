/*
:name: test_formal_fusion
:description: SymbiYosys checks the formal semantics of fusion against an independent RTL monitor (IEEE 1800-2023 Section 16.9.1)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.9.1 F.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: fusion
*/
// The reference derivative engine is exported as a finite-state machine and
// compared with an independently written RTL monitor under SymbiYosys. Inputs
// are symbolic; no expected-output file is read.
//
// formal result: PASS
