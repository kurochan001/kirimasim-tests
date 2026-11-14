/*
:name: test_vpi_assertion_columns
:description: The vpiColumn and vpiEndColumn properties of a concurrent assertion give the columns where its text starts and ends on its line: they move with the assertion when it is indented more or written later on the same line, and only the ending column moves when the assertion is longer (IEEE 1800-2023 Sections 37.49 and 39.3.2)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.49 39.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_columns.c
:expected_stdout: @test_vpi_assertion_columns.expected
*/
// IEEE 1800-2023 §37.49 gives an assertion the integer properties vpiColumn
// and vpiEndColumn, its starting and ending columns, beside vpiStartLine and
// vpiEndLine; §39.3.2 lists the file, line and column where an assertion is
// defined among its static information. The standard does not fix where
// column numbering starts, so the application prints no column itself. It
// prints only differences between assertions whose text differs in a known
// way, which are the same whatever the origin is and whichever character of
// the label, keyword or closing semicolon a tool takes as the first or last:
// the lines below hold only spaces and ASCII characters, the labels have the
// same length, and each assertion fits on one line.
//
// c2 is the text of c1 indented by three more spaces, so both of its columns
// are 3 more than those of c1. c3 has the indentation of c1 and six more
// characters (" ##1 b") before its closing parenthesis, so it starts in the
// same column as c1 and ends 6 columns later. c5 follows c4 on one line; c4
// with the space after it is 40 characters long, and the two texts have the
// same length, so both columns of c5 are 40 more than those of c4. An
// assertion on one line also ends in a later column than it starts.
// The assertions are named, so the application finds them by name (§39.3.1).
// No clock edge occurs, so no assertion is evaluated.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiStartLine, vpiEndLine, vpiColumn and
// vpiEndColumn, and the 5.054 release of Verilator does not build a design
// that calls a system task registered by a VPI application.

`timescale 1ns/1ns

module test_vpi_assertion_columns;
  logic clk = 0, a = 1, b = 1;

  c1: assert property (@(posedge clk) a |-> b);
     c2: assert property (@(posedge clk) a |-> b);
  c3: assert property (@(posedge clk) a |-> b ##1 b);
  c4: assert property (@(posedge clk) a); c5: assert property (@(posedge clk) b);

  initial #1 $vt_columns;
endmodule
