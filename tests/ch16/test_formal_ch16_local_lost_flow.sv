/*
:name: test_formal_ch16_local_lost_flow
:description: SymbiYosys checks the Chapter 16 SVA semantics of ch16_local_lost_flow against an independent RTL reference (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: ch16_local_lost_flow
*/
// The formal case is compared with an independently written RTL reference
// under SymbiYosys; inputs are symbolic.
//
// formal result: PASS
