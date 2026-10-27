/*
:name: test_formal_f531_clock_paren
:description: SymbiYosys checks the F.5.3.1 top-level property semantics of f531_clock_paren against an independent RTL reference (IEEE 1800-2023 Section F.5.3.1)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12 F.5.3.1 16.16.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: f531_clock_paren
*/
// The reference derivative engine is compared with an independently written
// RTL reference under SymbiYosys; inputs are symbolic.
//
// formal result: PASS
