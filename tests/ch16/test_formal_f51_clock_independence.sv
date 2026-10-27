/*
:name: test_formal_f51_clock_independence
:description: SymbiYosys checks the F.5.1 formal semantics of f51_clock_independence against an independent RTL reference (IEEE 1800-2023 Section F.5.1)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12 F.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: f51_clock_independence
*/
// The formal case is compared with an independently written RTL reference
// under SymbiYosys; inputs are symbolic.
//
// formal result: PASS
