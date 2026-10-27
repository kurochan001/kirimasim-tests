/*
:name: test_formal_f531_enable
:description: SymbiYosys checks the F.5.3.1 top-level property semantics of f531_enable against an independent RTL reference (IEEE 1800-2023 Section F.5.3.1)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12 F.5.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: f531_enable
*/
// The reference derivative engine is compared with an independently written
// RTL reference under SymbiYosys; inputs are symbolic.
//
// formal result: PASS
