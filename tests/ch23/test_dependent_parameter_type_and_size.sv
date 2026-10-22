/*
:name: test_dependent_parameter_type_and_size
:description: Overriding a parameter re-evaluates dependent local parameters and packed ranges (IEEE 1800-2023 Section 23.10.3)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dependent_parameter_type_and_size.expected
*/
// IEEE 1800-2023 23.10.3: A port width derived through a local parameter must
// be recomputed for each specialization instead of retaining the default width.

module sized_leaf #(int N = 2, localparam int W = 2*N) (output bit [W-1:0] value);
  assign value = '1;
endmodule
module test_dependent_parameter_type_and_size;
  wire [5:0] value;
  sized_leaf #(.N(3)) u(value);
  initial #1 $display("value=%h derived=%0d", value, u.W);
endmodule
