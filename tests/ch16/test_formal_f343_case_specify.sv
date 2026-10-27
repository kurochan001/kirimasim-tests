/*
:name: test_formal_f343_case_specify
:description: SymbiYosys checks the F.3.4.3 rewrite semantics of f343_case_specify against an independent RTL reference (IEEE 1800-2023 Section F.3.4.3.5)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12 F.3.4.3.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: f343_case_specify
*/
// The reference derivative engine is compared with an independently written
// RTL reference under SymbiYosys; inputs are symbolic.
//
// formal result: PASS
