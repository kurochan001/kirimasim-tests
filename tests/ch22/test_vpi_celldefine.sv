/*
:name: test_vpi_celldefine
:description: Modules defined between `celldefine and `endcelldefine, or after `celldefine until a `resetall, are cell modules, and VPI gives their instances vpiCellInstance true (IEEE 1800-2023 Section 22.10)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.10 22.3 37.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_celldefine.c
:expected_stdout: @test_vpi_celldefine.expected
*/
// IEEE 1800-2023 §22.10: `celldefine and `endcelldefine tag the modules
// defined while `celldefine is the most recent of the two as cell modules;
// `resetall has the effect of `endcelldefine (22.3). §37.10: the instance
// property vpiCellInstance tells whether an instance is of a cell module. So
// cd_cell and cd_cell2 are cells, while cd_plain, cd_after and the top module,
// which come after `endcelldefine or `resetall, are not.

`celldefine
module cd_cell(input wire a, output wire y);
  assign y = a;
endmodule
`endcelldefine

module cd_plain(input wire a, output wire y);
  assign y = ~a;
endmodule

`celldefine
module cd_cell2(input wire a, output wire y);
  assign y = a;
endmodule
`resetall

module cd_after(input wire a, output wire y);
  assign y = ~a;
endmodule

module test_vpi_celldefine;
  logic a = 1'b0;
  wire y1, y2, y3, y4;

  cd_cell c1(a, y1);
  cd_plain p1(a, y2);
  cd_cell2 c2(a, y3);
  cd_after r1(a, y4);

  initial #1 $vt_cells;
endmodule
