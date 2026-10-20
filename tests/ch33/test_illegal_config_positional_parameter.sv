/*
:name: test_illegal_config_positional_parameter
:description: A config cannot override a parameter by position (IEEE 1800-2023 Section 33.4.3)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the use clause of the config overrides a parameter by position
:expected_stderr_regex: test_illegal_config_positional_parameter\.sv:27:
*/
// IEEE 1800-2023 §33.4.3: configurations override parameters by name only, not
// by position; use #(8) gives a value without naming the parameter.

module cfgx4_leaf #(parameter int W = 4);
  initial $display("W=%0d", W);
endmodule

module test_illegal_config_positional_parameter;
  cfgx4_leaf u();
endmodule

config cfgx4;
  design work.test_illegal_config_positional_parameter;
  instance test_illegal_config_positional_parameter.u use #(8);   // illegal: by position
endconfig
