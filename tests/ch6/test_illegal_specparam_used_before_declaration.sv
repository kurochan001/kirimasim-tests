/*
:name: test_illegal_specparam_used_before_declaration
:description: A specparam declared in the module body cannot be used before its declaration (IEEE 1800-2023 Section 6.20.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the specparam tHold is used in the initial block before its declaration in the module body
:expected_stderr_regex: test_illegal_specparam_used_before_declaration\.sv:21:
*/
// IEEE 1800-2023 §6.20.5: a specify parameter declared outside a specify
// block shall be declared before it is referenced. The initial block uses
// tHold on a line before the specparam declaration.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 rejects the design; they
// print 5.

module test_illegal_specparam_used_before_declaration;
  initial $display("%0d", tHold);    // illegal: tHold is declared below
  specparam tHold = 5;
endmodule
