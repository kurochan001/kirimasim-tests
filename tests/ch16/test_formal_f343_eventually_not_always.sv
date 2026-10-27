/*
:name: test_formal_f343_eventually_not_always
:description: SymbiYosys checks the F.3.4.3 rewrite semantics of f343_eventually_not_always against an independent RTL reference (IEEE 1800-2023 Section F.3.4.3.8)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12 F.3.4.3.8 16.12.21
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: f343_eventually_not_always
*/
// The reference derivative engine is compared with an independently written
// RTL reference under SymbiYosys; inputs are symbolic.
//
// formal result: PASS
