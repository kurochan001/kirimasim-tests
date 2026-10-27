/*
:name: test_formal_f51_sequence
:description: SymbiYosys checks the F.5.1.2 formal semantics of f51_sequence against an independent RTL reference (IEEE 1800-2023 Section F.5.1.2)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12 F.5.1.2 16.16.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: f51_sequence
*/
// The formal case is compared with an independently written RTL reference
// under SymbiYosys; inputs are symbolic.
//
// formal result: PASS
