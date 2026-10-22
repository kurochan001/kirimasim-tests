/*
:name: test_nested_module_lexical_parameter_visibility
:description: A nested module resolves its enclosing parameter lexically and explicit root qualification reaches the top instance (IEEE 1800-2023 Section 23.4)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nested_module_lexical_parameter_visibility.expected
*/
// IEEE 1800-2023 23.4: The nested declaration is instantiated twice but
// shares the enclosing declaration scope; an explicit hierarchy reference
// reaches a separate top-level datum.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

module test_nested_module_lexical_parameter_visibility;
  parameter int BIAS = 17;
  int global_value = 9;
  module inner(output int result);
    assign result = BIAS;
  endmodule
  wire signed [31:0] a, b;
  inner first(a), second(b);
  initial #1 $display("nested=%0d,%0d root=%0d", a, b,
                     $root.test_nested_module_lexical_parameter_visibility.global_value);
endmodule
