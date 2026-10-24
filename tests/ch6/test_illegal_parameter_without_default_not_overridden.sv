/*
:name: test_illegal_parameter_without_default_not_overridden
:description: every instance of a module whose parameter has no default value has to override that parameter (IEEE 1800-2023 Section 6.20.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance bad of a module whose parameter WIDTH has no default value does not override WIDTH
:expected_stderr_regex: test_illegal_parameter_without_default_not_overridden\.sv:(20|27):
*/
// IEEE 1800-2023 §6.20.1: a parameter in a parameter port list can be left
// without a default value; then every instantiation of the design element
// shall give it an overriding value. The instances by_name and by_position
// override WIDTH; the instance bad gives no parameter value. A tool can
// report the instance, or the parameter that is left without a value.

module test_illegal_parameter_without_default_not_overridden_m #(parameter int WIDTH) ();
  initial $display("%0d", WIDTH);
endmodule

module test_illegal_parameter_without_default_not_overridden;
  test_illegal_parameter_without_default_not_overridden_m #(.WIDTH(4)) by_name();
  test_illegal_parameter_without_default_not_overridden_m #(8) by_position();
  test_illegal_parameter_without_default_not_overridden_m bad();   // illegal: no WIDTH
endmodule
