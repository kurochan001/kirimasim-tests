/*
:name: test_macro_comments_and_string_continuation
:description: Comments in the text of a macro are not part of what it substitutes, a one-line comment ends before a backslash and newline so that the text goes on, a block comment can span lines without backslashes, and a backslash and newline inside a string literal of the text are both left out (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 5.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_comments_and_string_continuation.expected
*/
// IEEE 1800-2023 §22.5.1: a comment in the macro text does not become part of
// the substituted text. If a one-line comment is followed by a backslash and a
// newline, the comment ends before the backslash and the text continues on the
// next line; a block comment can contain newlines without backslashes. A
// backslash and newline in the middle of a string literal of the text are both
// omitted in the expansion (5.9). So `LINE_CMT + 5 is 15, where a substituted
// comment would hide the + 5; CONT_CMT is 20 + 3; BLOCK_CMT is 30 + 4; and
// STR_CONT is the six characters abcdef. Icarus Verilog 13.0 reports an
// unterminated comment for the block comment that spans two lines.

`define LINE_CMT 10 // not part of the substituted text
`define CONT_CMT 20 // this comment ends before the backslash \
  + 3
`define BLOCK_CMT (30 /* a block comment
  that goes on to a second line */ + 4)
`define STR_CONT "abc\
def"

module test_macro_comments_and_string_continuation;
  string s;

  initial begin
    $display("line comment: %0d", `LINE_CMT + 5);
    $display("continued line comment: %0d", `CONT_CMT);
    $display("block comment: %0d", `BLOCK_CMT);
    s = `STR_CONT;
    $display("string continuation: [%s] len=%0d", s, s.len());
  end
endmodule
