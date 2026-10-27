/*
:name: test_formal_f343_clocked_nonoverlap
:description: SymbiYosys checks the F.3.4.3 rewrite semantics of f343_clocked_nonoverlap against an independent RTL reference (IEEE 1800-2023 Section F.3.4.3.3)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12 F.3.4.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: f343_clocked_nonoverlap
*/
// The reference derivative engine is compared with an independently written
// RTL reference under SymbiYosys; inputs are symbolic.
//
// formal result: PASS
