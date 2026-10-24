/*
:name: test_illegal_type_parameter_assigned_value
:description: a type parameter can only be set to a data type, which can be a package-qualified type name; a value expression is illegal (IEEE 1800-2023 Section 6.20.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance bad overrides the type parameter T with the value 5 instead of a data type
:expected_stderr_regex: test_illegal_type_parameter_assigned_value\.sv:34:
*/
// IEEE 1800-2023 §6.20.3: a type parameter can only be set to a data type,
// and package references are allowed. The instances give T a built-in type,
// a type written with a range, and a type named through its package; the
// legal design prints the width of T for each of them (16, 3 and 12). The
// instance bad gives T the number 5.

package test_illegal_type_parameter_assigned_value_pkg;
  typedef logic [11:0] word_t;
endpackage

module test_illegal_type_parameter_assigned_value_m #(parameter type T = int) ();
  T v;
  initial $display("%0d", $bits(v));
endmodule

module test_illegal_type_parameter_assigned_value;
  test_illegal_type_parameter_assigned_value_m #(.T(shortint)) builtin();
  test_illegal_type_parameter_assigned_value_m #(.T(logic [2:0])) ranged();
  test_illegal_type_parameter_assigned_value_m
      #(.T(test_illegal_type_parameter_assigned_value_pkg::word_t)) from_pkg();
  test_illegal_type_parameter_assigned_value_m #(.T(5)) bad();   // illegal: not a type
endmodule
