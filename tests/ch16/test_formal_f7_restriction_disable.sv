/*
:name: test_formal_f7_restriction_disable
:description: SymbiYosys checks the F.7 formal semantics of f7_restriction_disable against an independent RTL reference (IEEE 1800-2023 Section F.7)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12 F.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: f7_restriction_disable
*/
// The formal case is compared with an independently written RTL reference
// under SymbiYosys; inputs are symbolic.
//
// formal result: PASS
