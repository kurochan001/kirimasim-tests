/*
:name: test_vpi_ref_port_simple_expression_use
:description: Each reference port is a simple expression whose VPI uses include the assignment that reads that port
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.58 37.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_ref_port_simple_expression_use.c
:expected_stdout: @test_vpi_ref_port_simple_expression_use.expected
*/
// IEEE 1800-2023 37.15 identifies a ref port's low connection as a ref
// object. The simple expression group in 37.58 exposes its uses, including
// the continuous assignment that consumes it.
`timescale 1ns/1ns
module ref_use_reader(
  ref logic left_input,
  ref logic right_input,
  output wire left_output,
  output wire right_output
);
  assign left_output = left_input;
  assign right_output = right_input;
endmodule

module test_vpi_ref_port_simple_expression_use;
  logic first, second;
  wire seen_left, seen_right;
  ref_use_reader u(first, second, seen_left, seen_right);

  initial begin
    first = 1'b1;
    second = 1'b0;
    #1 $display("aliases=%b%b", seen_left, seen_right);
    first = 1'b0;
    second = 1'b1;
    #1 $display("aliases=%b%b", seen_left, seen_right);
  end
endmodule
