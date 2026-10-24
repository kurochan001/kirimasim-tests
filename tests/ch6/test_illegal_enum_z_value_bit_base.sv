/*
:name: test_illegal_enum_z_value_bit_base
:description: An enum with an explicit 2-state base type cannot give a name a value with z bits (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the name B of an enum with the 2-state base bit [1:0] is given the value 2'bz1
:expected_stderr_regex: test_illegal_enum_z_value_bit_base\.sv:19:
*/
// IEEE 1800-2023 §6.19: in an enum with an explicit 2-state base type, or
// with no base type, a name with an x or z value is a syntax error. Here the
// base is bit [1:0] and the value of B has a z bit.

module test_illegal_enum_z_value_bit_base;
  typedef enum bit [1:0] {A = 2'b00, B = 2'bz1} e_t;    // illegal: z value with a 2-state base
  e_t e;
  initial e = A;
endmodule
