/*
:name: test_illegal_real_operand_modulus
:description: The modulus operator cannot have a real operand (IEEE 1800-2023 Section 6.12)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.12 11.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the modulus operator % is applied to the real variable r
:expected_stderr_regex: test_illegal_real_operand_modulus\.sv:24:
*/
// IEEE 1800-2023 §6.12: not every operator can be used with real operands;
// 11.3.1, Table 11-1 lists which can. The modulus operator % takes integral
// operands only, so r % 2.0 with the real variable r is illegal. The other
// operators of the design are legal for reals.
// Oracle checks: Icarus Verilog 13.0 accepts the design, and the 5.052 release
// accepts it with warnings.

module test_illegal_real_operand_modulus;
  real r = 7.5;
  real q;
  initial q = r % 2.0;   // illegal: % with a real operand
endmodule
