/*
:name: test_formal_f52_nonempty_word
:description: SymbiYosys checks the F sequence rewrite of f52_nonempty_word against an independent RTL reference (IEEE 1800-2023 Section F.5.2)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.9 F.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: f52_nonempty_word
*/
// The reference derivative engine is compared with an independently written
// RTL reference under SymbiYosys; inputs are symbolic.
//
// formal result: PASS
