/*
:name: test_formal_s_until_with
:description: SymbiYosys checks the formal semantics of s_until_with against an independent RTL monitor (IEEE 1800-2023 Section 16.12.12)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12.12 F.3.4.3.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: s_until_with
*/
// The reference derivative engine is exported as a finite-state machine and
// compared with an independently written RTL monitor under SymbiYosys. Inputs
// are symbolic; no expected-output file is read.
//
// formal result: PASS
