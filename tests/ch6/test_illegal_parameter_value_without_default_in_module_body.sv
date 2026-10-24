/*
:name: test_illegal_parameter_value_without_default_in_module_body
:description: a value parameter can be declared without a default value only in a parameter port list, not as a module item (IEEE 1800-2023 Section 6.20.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parameter COUNT, declared in the module body, has no value
:expected_stderr_regex: test_illegal_parameter_value_without_default_in_module_body\.sv:27:
*/
// IEEE 1800-2023 §6.20.1 (footnote 22 of Syntax 6-6): it is legal to leave
// out the value of a param_assignment only within a parameter port list.
// The module that has a port list declares WIDTH there without a default,
// and its instance overrides it; the top module declares COUNT as a module
// item, with no port list, and without a value.

module test_illegal_parameter_value_without_default_in_module_body_m #(parameter int WIDTH) ();
  initial $display("%0d", WIDTH);
endmodule

module test_illegal_parameter_value_without_default_in_module_body;
  test_illegal_parameter_value_without_default_in_module_body_m #(.WIDTH(4)) u();
  parameter int LIMIT = 3;
  parameter int COUNT;   // illegal: no value outside a parameter port list
endmodule
