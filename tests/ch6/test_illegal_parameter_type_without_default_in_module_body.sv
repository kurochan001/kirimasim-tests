/*
:name: test_illegal_parameter_type_without_default_in_module_body
:description: a type parameter can be declared without a default type only in a parameter port list, not as a module item (IEEE 1800-2023 Section 6.20.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the type parameter ITEM_T, declared in the module body, has no data type
:expected_stderr_regex: test_illegal_parameter_type_without_default_in_module_body\.sv:28:
*/
// IEEE 1800-2023 §6.20.1 (footnote 22 of Syntax 6-6): it is legal to leave
// out the data type of a type_assignment only within a parameter port list.
// The module that has a port list declares T there without a default, and
// its instance overrides it; the top module declares ITEM_T as a module
// item, with no port list, and without a data type.

module test_illegal_parameter_type_without_default_in_module_body_m #(parameter type T) ();
  T v = 5;
  initial $display("%0d", v);
endmodule

module test_illegal_parameter_type_without_default_in_module_body;
  test_illegal_parameter_type_without_default_in_module_body_m #(.T(byte)) u();
  parameter type KEY_T = int;
  parameter type ITEM_T;   // illegal: no type outside a parameter port list
endmodule
