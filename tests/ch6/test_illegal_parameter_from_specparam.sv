/*
:name: test_illegal_parameter_from_specparam
:description: A parameter cannot be given a value that uses a specify parameter (IEEE 1800-2023 Section 6.20.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parameter P is assigned an expression with the specparam tDelay
:expected_stderr_regex: test_illegal_parameter_from_specparam\.sv:20:
*/
// IEEE 1800-2023 §6.20.5: specify parameters and parameters are not
// interchangeable, and a parameter or localparam cannot be assigned a constant
// expression that includes a specify parameter.

module test_illegal_parameter_from_specparam;
  specparam tDelay = 5;
  parameter int P = tDelay + 1;   // illegal: a specparam in a parameter
  initial $display("%0d", P);
endmodule
