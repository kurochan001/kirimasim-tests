/*
:name: test_vpi_celldefine_inside_design_elements
:description: `celldefine and `endcelldefine can be written inside module declarations, not only between them, and still tag the modules defined between the two as cell modules, which VPI reports through vpiCellInstance (IEEE 1800-2023 Section 22.10)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_celldefine_inside_design_elements.c
:expected_stdout: @test_vpi_celldefine_inside_design_elements.expected
*/
// IEEE 1800-2023 §22.10: `celldefine and `endcelldefine tag the modules
// defined between them as cell modules. The two directives may appear
// anywhere in the source description; writing them outside the design
// elements is only a recommendation. Here `celldefine is written inside the
// body of cp_host and `endcelldefine inside the body of cp_closer, so cp_cell,
// whose whole declaration lies between them, is a cell module, while cp_plain
// and the top module, declared after `endcelldefine, are not. The instances
// of cp_host and cp_closer are not printed: the directives fall inside their
// declarations, and the clause does not say whether such a module is a cell.
// A VPI application reads vpiCellInstance (§37.10) of the instances c1 and p1
// and of the top module by name and prints it.
// The 5.054 release of Verilator does not build a call of a system task that
// a VPI application registers, so it does not confirm the output.

module cp_host(input wire a, output wire y);
  assign y = a;
`celldefine
endmodule

module cp_cell(input wire a, output wire y);
  assign y = ~a;
endmodule

module cp_closer(input wire a, output wire y);
  assign y = a;
`endcelldefine
endmodule

module cp_plain(input wire a, output wire y);
  assign y = ~a;
endmodule

module test_vpi_celldefine_inside_design_elements;
  logic a = 1'b0;
  wire y1, y2, y3, y4;

  cp_host h1(a, y1);
  cp_cell c1(a, y2);
  cp_closer e1(a, y3);
  cp_plain p1(a, y4);

  initial #1 $vt_cells;
endmodule
