/*
:name: test_vpi_operation_and_timing_subtype_names
:description: Operator and timing-check objects provide both integer subtypes and constant names
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.2 37.3.1 37.40 37.59
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_operation_and_timing_subtype_names.c
:expected_stdout: @test_vpi_operation_and_timing_subtype_names.expected
*/
`timescale 1ns/1ns
module subtype_timing(input a, clk);
  specify
    $setup(a, posedge clk, 3);
    $hold(posedge clk, a, 2);
  endspecify
endmodule

module test_vpi_operation_and_timing_subtype_names;
  logic [3:0] a = 3, b = 7;
  logic clk = 0;
  subtype_timing timing(a[0], clk);

  initial begin
    #1;
    $vt_operation_and_timing_names(a + b, a & b);
  end
endmodule
