/*
:name: test_vpi_protected_access_controls
:description: VPI protection follows recovered source ranges while preserving permitted type and expression queries
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.6 38.7 38.11 38.18 38.19 38.20 38.21 38.23 37.3.6 37.42 37.59
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @vpi_protected_access/probe.c
:expected_stdout: @test_vpi_protected_access_controls.expected
:files: vpi_protected_access/adapter.h vpi_protected_access/adapter.c vpi_protected_access/right.expected vpi_protected_access/left.expected
*/
`timescale 1ns/1ns

// left leaf begin
module protection_left_leaf;
  wire [7:0] sample = 8'h5a;
  logic [6:0] data = 7'd5;
  initial begin
    #1 $vt_protection_arguments(data + 7'd2, 4'd13);
    if ($vt_protection_function(data + 7'd3, 4'd12) != 17) $fatal(1);
  end
endmodule
// left leaf end

// right leaf begin
`pragma protect begin
module protection_right_leaf;
  wire [7:0] sample = 8'ha5;
  logic [6:0] data = 7'd8;
  initial begin
    #2 $vt_protection_arguments(data + 7'd3, 4'd9);
    if ($vt_protection_function(data + 7'd4, 4'd8) != 17) $fatal(1);
  end
endmodule
`pragma protect end
// right leaf end

module test_vpi_protected_access_controls;
  class payload;
    int member;
  endclass

  // left objects begin
  logic [7:0] left_grid [-1:0][4:5];
  payload left_object = new;
  protection_left_leaf left_scope();
  // left objects end

  // right objects begin
`pragma protect begin
  logic [7:0] right_grid [-1:0][4:5];
  payload right_object = new;
  protection_right_leaf right_scope();
`pragma protect end
  // right objects end

  initial begin
    left_grid[-1][5] = 8'h5a;
    right_grid[-1][5] = 8'ha5;
    #3 $finish(0);
  end
endmodule
