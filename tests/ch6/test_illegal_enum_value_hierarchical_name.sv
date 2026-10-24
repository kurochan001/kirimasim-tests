/*
:name: test_illegal_enum_value_hierarchical_name
:description: An enum name value cannot use a hierarchical name, even of a parameter (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the value of the enum name A uses the hierarchical name u.BASE
:expected_stderr_regex: test_illegal_enum_value_hierarchical_name\.sv:28:
*/
// IEEE 1800-2023 §6.19: the value of an enum name may use parameters and
// other elaboration-time constants, but hierarchical names are not allowed.
// u.BASE names a local parameter of the instance u through the hierarchy,
// so the value of A is an error.
// Icarus Verilog 13.0 rejects the design on that line (it cannot bind
// u.BASE there and the value is not a constant). Verilator 5.052 accepts it
// and gives A the value 4.

module test_illegal_enum_value_hierarchical_name_child;
  localparam int BASE = 4;
endmodule

module test_illegal_enum_value_hierarchical_name;
  test_illegal_enum_value_hierarchical_name_child u();
  typedef enum {A = u.BASE, B} e_t;    // illegal: hierarchical name
  e_t e;
  initial e = B;
endmodule
