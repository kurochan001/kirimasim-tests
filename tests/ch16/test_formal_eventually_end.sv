/*
:name: test_formal_eventually_end
:description: SymbiYosys checks the formal semantics of eventually_end against an independent RTL monitor (IEEE 1800-2023 Section 16.12.13)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12.13 F.3.4.3.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: eventually_end
*/
// The reference derivative engine is exported as a finite-state machine and
// compared with an independently written RTL monitor under SymbiYosys. Inputs
// are symbolic; no expected-output file is read.
//
// formal result: PASS
