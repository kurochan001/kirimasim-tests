/*
:name: test_vpi_interconnect_elements
:description: vpiElement on a multidimensional interconnect array gives one dimension at a time: interconnect arrays first, then interconnect nets (IEEE 1800-2023 Section 37.24)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.24 6.6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_interconnect_elements.c
:expected_stdout: @test_vpi_interconnect_elements.expected
*/
// IEEE 1800-2023 §37.24: vpiElement iterates the elements of an interconnect
// array one dimension level at a time, so for a two-dimensional array it
// returns interconnect arrays, whose own elements are the interconnect nets.
// Each net of g [0:1][0:2] (6.6.8) is connected to the output port of a driver,
// which gives it a type.

`timescale 1ns/1ns

module test_vpi_interconnect_elements_drv (output wire logic o);
  assign o = 1'b1;
endmodule

module test_vpi_interconnect_elements;
  interconnect g [0:1][0:2];

  for (genvar i = 0; i < 2; i++) begin : row
    for (genvar j = 0; j < 3; j++) begin : col
      test_vpi_interconnect_elements_drv u(g[i][j]);
    end
  end

  initial #1 $vt_ic;
endmodule
