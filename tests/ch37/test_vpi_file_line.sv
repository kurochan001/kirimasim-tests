/*
:name: test_vpi_file_line
:description: vpiLineNo and vpiFile give the source line and file of nets, variables and instances, vpiDefLineNo and vpiDefFile those of an instance's module, and a `line directive changes them for the lines after it (IEEE 1800-2023 Section 37.3.3)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.3 37.10 22.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_file_line.c
:expected_stdout: @test_vpi_file_line.expected
*/
// IEEE 1800-2023 §37.3.3: objects from the source have vpiLineNo and vpiFile,
// and §37.10 gives an instance also vpiDefLineNo and vpiDefFile, the location
// of its module's definition. §22.12: `line sets the line number and file name
// of the line after it, and the lines that follow count on from there; both
// properties follow it (37.3.3, 37.10 detail 8). The application prints the
// line and the last part of the file name of r and w, declared before the
// directive, of after_line and the instance u, declared after it, of the net
// n inside u, and the definition line and file of u.

module fl_leaf(input wire i, output wire o);
  wire n = ~i;
  assign o = n;
endmodule

module test_vpi_file_line;
  logic r = 1'b0;
  wire w;
`line 200 "renamed.sv" 0
  logic after_line = 1'b1;
  fl_leaf u(.i(r), .o(w));

  initial #1 $vt_lines;
endmodule
