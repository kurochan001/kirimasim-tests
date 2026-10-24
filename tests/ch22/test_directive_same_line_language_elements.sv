/*
:name: test_directive_same_line_language_elements
:description: A language element can stand on the same line before a compiler directive and after the defined end of one, while the text after a `define up to the newline is its macro text (IEEE 1800-2023 Section 22.2)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.2 22.5.1 22.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_directive_same_line_language_elements.expected
*/
// IEEE 1800-2023 §22.2: a directive whose syntax has a defined end may be
// followed on the same line by another language element, and a language
// element may stand on the same line before a directive, as long as the
// rules of the element and of the placement of the directive are met; text
// after a directive whose end requires a newline belongs to the directive.
// Declarations stand before and after `ifdef, `else and `endif on one line
// (§22.6), so only the declarations of the group that is compiled exist; a
// declaration follows the macro name that ends an `undef; and a declaration
// precedes a `define, whose macro text is everything after its name up to
// the end of the line (§22.5.1), so SAME_LINE_TEXT * 2 expands to
// 20 + 2 * 2, which is 24.
// Icarus Verilog 13.0 drops the rest of the line after the macro name of an
// `undef, so it does not declare e and stops with an error.

`define SAME_LINE_ON
module test_directive_same_line_language_elements;
  int lead = 1; `define SAME_LINE_TEXT 20 + 2
  localparam int TEXT_TIMES_2 = `SAME_LINE_TEXT * 2;
  int a = 0; `ifdef SAME_LINE_ON int b = 1; `else int b = 2; `endif int c = 3;
  `ifdef SAME_LINE_OFF int f = 1; `else int f = 2; `endif int g = 6;
  int d = 4; `undef SAME_LINE_TEXT int e = 5;

  initial begin
    $display("lead=%0d a=%0d b=%0d c=%0d d=%0d e=%0d f=%0d g=%0d",
             lead, a, b, c, d, e, f, g);
    $display("SAME_LINE_TEXT * 2 = %0d", TEXT_TIMES_2);
`ifdef SAME_LINE_TEXT
    $display("SAME_LINE_TEXT after the undef: defined");
`else
    $display("SAME_LINE_TEXT after the undef: undefined");
`endif
  end
endmodule
