/*
:name: test_illegal_real_bit_select
:description: A bit-select of a real variable is not allowed (IEEE 1800-2023 Section 6.12)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.12 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the design selects a bit of the real variable r
:expected_stderr_regex: test_illegal_real_bit_select\.sv:19:
*/
// IEEE 1800-2023 §6.12: bit-selects and part-selects of real variables are not
// allowed (11.5.1).

module test_illegal_real_bit_select;
  real r = 2.5;
  initial $display("%b", r[0]);   // illegal: a bit-select of r
endmodule
