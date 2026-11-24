/*
:name: test_illegal_runtime_value_in_parameter_prevents_startup
:description: A runtime-dependent parameter initializer is rejected before the initial block can run
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.12 6.20.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a mutable variable cannot appear in the constant expression for a parameter
:expected_stderr_regex: test_illegal_runtime_value_in_parameter_prevents_startup\.sv:16:(?:\d+:)?[^\n]*(?i:constant|parameter|unable to bind)
*/
module test_illegal_runtime_value_in_parameter_prevents_startup;
  int runtime_value;
  localparam int WIDTH = runtime_value;
  wire [WIDTH-1:0] selected = '0;

  initial begin
    runtime_value = 3;
    $display("unexpected simulation startup: %0d", $bits(selected));
  end
endmodule
