/*
:name: test_formal_f342_nonconsecutive_finite
:description: SymbiYosys checks the F sequence rewrite of f342_nonconsecutive_finite against an independent RTL reference (IEEE 1800-2023 Section F.3.4.2.3)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.9 F.3.4.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: f342_nonconsecutive_finite
*/
// The reference derivative engine is compared with an independently written
// RTL reference under SymbiYosys; inputs are symbolic.
//
// formal result: PASS
