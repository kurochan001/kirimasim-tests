/*
:name: test_illegal_real_operand_bitwise_and
:description: A binary bitwise operator cannot have a real operand (IEEE 1800-2023 Section 6.12)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.12 11.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the binary bitwise operator & is applied to the real variable r
:expected_stderr_regex: test_illegal_real_operand_bitwise_and\.sv:22:
*/
// IEEE 1800-2023 §6.12: not every operator can be used with real operands;
// 11.3.1, Table 11-1 lists which can. The binary bitwise operators take
// integral operands only, so r & 1 with the real variable r is illegal.
// Oracle checks: the 5.052 release accepts the design with warnings.

module test_illegal_real_operand_bitwise_and;
  real r = 1.5;
  real q;
  initial q = r & 1;   // illegal: & with a real operand
endmodule
