/*
:name: test_formal_f5_fusion
:description: The fusion operator tightly matches exactly when the word splits into operands that share exactly one letter (IEEE 1800-2023 Sections 16.9.2.1 and F.5.2)
:tags: ch16
:type: formal
:lrm: 1800-2023 16.9.2.1 F.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: fusion
*/
// IEEE 1800-2023 F.5.2: concatenation tightly matches when the word splits
// into adjacent operand matches; fusion splits with exactly one shared
// letter. The tool sva_reference.formal exports the reference derivative
// engine as a finite-state machine and compares every prefix with an
// independently written RTL monitor under SymbiYosys. The word is not
// constrained to any test stimulus.
//
// The check is a symbolic proof over all input words up to the bounded depth,
// not a simulation of a SystemVerilog assertion.
//
// formal result: PASS
