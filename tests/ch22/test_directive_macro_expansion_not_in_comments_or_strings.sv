/*
:name: test_directive_macro_expansion_not_in_comments_or_strings
:description: Macros are expanded inside compiler directives, here the file name of `include and the arguments of `timescale, while directive text in a block comment, a line comment or a string literal is not processed (IEEE 1800-2023 Section 22.2)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.2 22.4 22.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: directive_lexing_helper.svh
:expected_stdout: @test_directive_macro_expansion_not_in_comments_or_strings.expected
*/
// IEEE 1800-2023 §22.2: macro expansion shall occur within a compiler
// directive, and directives are not recognized within comments or string
// literals. The file name of the `include inside the top module comes from
// the macro LEX_INCLUDE_FILE, and the included file declares
// LEX_FROM_INCLUDE = 7. The time unit and precision of the second
// `timescale come from the macros LEX_UNIT (10ns) and LEX_PREC (1ns), so the
// delay #1 in lex_scaled lasts 10 ns, which the top module, with a time unit
// of 1 ns, measures. A `define inside a block comment defines nothing, an
// `undef inside a line comment and one inside a string literal undefine
// nothing (LEX_KEEP_C and LEX_KEEP_S stay defined), and the string is
// printed with its text unchanged.

`define LEX_INCLUDE_FILE "directive_lexing_helper.svh"
`define LEX_UNIT 10ns
`define LEX_PREC 1ns
`define LEX_KEEP_C 1
`define LEX_KEEP_S 1

`timescale 1ns / 1ns

module test_directive_macro_expansion_not_in_comments_or_strings;
  `include `LEX_INCLUDE_FILE

  lex_scaled scaled();

  /* `define LEX_IN_BLOCK_COMMENT 1 */
  // `undef LEX_KEEP_C

  initial begin
    $display("included through a macro: %0d", LEX_FROM_INCLUDE);
    @(scaled.fired);
    $display("delay of 1 under the macro timescale, in ns: %0d", $time);
`ifdef LEX_IN_BLOCK_COMMENT
    $display("define inside a block comment: processed");
`else
    $display("define inside a block comment: not processed");
`endif
`ifdef LEX_KEEP_C
    $display("undef inside a line comment: not processed");
`else
    $display("undef inside a line comment: processed");
`endif
    $display("string with a directive: %s", "`undef LEX_KEEP_S");
`ifdef LEX_KEEP_S
    $display("undef inside a string: not processed");
`else
    $display("undef inside a string: processed");
`endif
  end
endmodule

`timescale `LEX_UNIT / `LEX_PREC

module lex_scaled;
  event fired;
  initial #1 -> fired;
endmodule
