/*
:name: test_ifdef_hidden_directives_and_spacing
:description: A block of conditional compilation ends only at an `elsif, `else or `endif of its own construct, not at one inside a comment, a string literal or a macro definition, and the directives need no white space around them beyond separating tokens (IEEE 1800-2023 Section 22.6)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.6 22.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ifdef_hidden_directives_and_spacing.expected
*/
// IEEE 1800-2023 §22.6: the block of text after `ifdef or `elsif ends at
// `elsif, `else or `endif, and the one after `else at `endif; a directive
// within a comment, a string literal or a macro definition (22.5.1) is hidden
// and does not end a block. White space is not considered for the end of a
// block, and the directives need white space only as token separators. In the
// used branch of the first conditional, `else, `elsif and `endif appear in
// comments, in a string and in the text of two macros, and the branch goes on
// to its last declaration. In the skipped branch of the second, they appear in
// a comment and a string too. A conditional is written on one line with `else
// and `endif right after semicolons, and one with tabs and spaces. Icarus
// Verilog 13.0 reports that the first `ifdef lacks an `endif.

`define A

module test_ifdef_hidden_directives_and_spacing;
`ifdef A
  // `else and `endif in this comment do not end the block
  /* nor does `elsif A in this one */
  string text = "`endif in a string";
`define HIDDEN_END `endif
`define HIDDEN_ELSE `else
  int used = 1;
`else
  string text = "else";
  int used = 0;
`endif
`ifdef B
  // `endif in a comment of the skipped branch
  int skipped = 1;
  string s2 = "`else in a string of the skipped branch";
`else
  int skipped = 0;
`endif
`ifdef A int one_line = 1;`else int one_line = 2;`endif
`ifdef B int one_line_b = 1;`else int one_line_b = 2;`endif
`ifdef	   A
  int spaced = 1;
`else
  int spaced = 0;
`endif

  initial begin
    $display("used=%0d text=%s skipped=%0d", used, text, skipped);
    $display("one_line=%0d one_line_b=%0d spaced=%0d", one_line, one_line_b, spaced);
  end
endmodule
