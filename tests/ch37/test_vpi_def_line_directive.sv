/*
:name: test_vpi_def_line_directive
:description: vpiDefFile and vpiDefLineNo of an instance give the file and line of its module definition, and a `line directive before a definition changes them to the file name and line number it sets (IEEE 1800-2023 Section 37.10)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.10 22.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_def_line_directive.c
:expected_stdout: @test_vpi_def_line_directive.expected
*/
// IEEE 1800-2023 §37.10: an instance has vpiDefFile and vpiDefLineNo, the
// location of the definition of its module, and the `line directive affects
// them (detail 8). §22.12: `line sets the line number and the file name of the
// line that follows it, and the numbers go on from there. The top module and
// dl_plain are defined before any `line, so they keep the name of this file
// and their own line numbers. dl_moved follows a `line that makes it line 40
// of rtl/cells.v, and dl_moved2 another one that makes it line 7 of
// gen/other.sv. The application prints the last component of each file name,
// since the directory of this file depends on how the tool is run.

module test_vpi_def_line_directive;
  dl_plain p();
  dl_moved m1();
  dl_moved2 m2();

  initial #1 $vt_defs;
endmodule

module dl_plain;
endmodule

`line 40 "rtl/cells.v" 0
module dl_moved;
endmodule

`line 7 "gen/other.sv" 0
module dl_moved2;
endmodule
