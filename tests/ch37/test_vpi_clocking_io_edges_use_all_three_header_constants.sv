/*
:name: test_vpi_clocking_io_edges_use_all_three_header_constants
:description: Clocking inputs and outputs each report the distinct no-edge rising and falling VPI constants
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.48 M.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_clocking_io_edges_use_all_three_header_constants.expected
:vpi_c: @test_vpi_clocking_io_edges_use_all_three_header_constants.c
*/
`timescale 1ns/1ns

interface edge_view(input logic clk);
  logic in_delay, in_rise, in_fall;
  logic out_delay, out_rise, out_fall;

  clocking sample @(posedge clk);
    input #1 in_delay;
    input posedge in_rise;
    input negedge in_fall;
    output #2 out_delay;
    output posedge out_rise;
    output negedge out_fall;
  endclocking
endinterface

module test_vpi_clocking_io_edges_use_all_three_header_constants;
  logic clk = 0;
  edge_view bus(clk);

  initial #1 $vt_edge_constant_matrix;
endmodule
