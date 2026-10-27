/*
:name: test_formal_f343_strong_eventually_infinite
:description: SymbiYosys checks the F.3.4.3 rewrite semantics of f343_strong_eventually_infinite against an independent RTL reference (IEEE 1800-2023 Section F.3.4.3.9)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12 F.3.4.3.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: f343_strong_eventually_infinite
*/
// The reference derivative engine is compared with an independently written
// RTL reference under SymbiYosys; inputs are symbolic.
//
// formal result: PASS
