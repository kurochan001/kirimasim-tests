/*
:name: test_formal_repetition
:description: SymbiYosys checks the formal semantics of repetition against an independent RTL monitor (IEEE 1800-2023 Section 16.9.2)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.9.2 F.3.4.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: repetition
*/
// The reference derivative engine is exported as a finite-state machine and
// compared with an independently written RTL monitor under SymbiYosys. Inputs
// are symbolic; no expected-output file is read.
//
// formal result: PASS
