/*
:name: test_formal_gated_past
:description: SymbiYosys checks the formal semantics of gated_past against an independent RTL monitor (IEEE 1800-2023 Section 16.5.1)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.5.1 F.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: gated_past
*/
// The reference derivative engine is exported as a finite-state machine and
// compared with an independently written RTL monitor under SymbiYosys. Inputs
// are symbolic; no expected-output file is read.
//
// formal result: PASS
