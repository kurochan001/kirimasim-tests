/*
:name: test_formal_f533_booleans_implies
:description: SymbiYosys checks the F.5.3.3 nonvacuity relation of f533_booleans_implies against an independent RTL reference (IEEE 1800-2023 Section F.5.3.3)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12 F.5.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: f533_booleans_implies
*/
// The nonvacuity relation is compared with an independently written RTL
// reference under SymbiYosys; inputs are symbolic.
//
// formal result: PASS
