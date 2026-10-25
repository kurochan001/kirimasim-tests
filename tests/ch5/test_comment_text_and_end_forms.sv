/*
:name: test_comment_text_and_end_forms
:description: A block comment holds any characters, none or several lines of them, up to its first closing delimiter, and a one-line comment, empty or not, ends at the newline so that the next line is source text again (IEEE 1800-2023 Section 5.4)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.4 A.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comment_text_and_end_forms.expected
*/
// IEEE 1800-2023 §5.4 and A.9.2: a comment is a one-line comment or a block
// comment. A block comment is its opening delimiter, any ASCII characters
// (possibly none) and the closing delimiter; it ends at the first closing
// delimiter, since block comments do not nest. A one-line comment starts with
// two slashes and ends with the newline. The delimiters of one form mean
// nothing inside the other.
//
// Each assignment below puts a comment between the tokens of an expression,
// so the printed value shows where the comment ended:
//   a  an empty block comment between 4 and +1                       -> 5
//   b  a block comment over three lines holding a double quote, a
//      backslash, a keyword, a star and a slash apart, and a second
//      opening delimiter; it ends at the first closing one       -> 2*3 = 6
//   c  a one-line comment holding both block delimiters and a double
//      quote ends at the newline, so "- 2" on the next line counts -> 5
//   d  an empty one-line comment ends at the newline as well        -> 9
//   e  two slashes inside a block comment do not hide its end       -> 7
// The string s holds the comment delimiters as characters: they do not start
// a comment inside a string literal.
//
// Icarus Verilog 13.0 rejects the second opening delimiter inside the block
// comment of b as a possible nested comment; §5.4 gives it no meaning there.

module test_comment_text_and_end_forms;
  int a, b, c, d, e;
  string s;

  initial begin
    a = 4/**/+1;
    b = 2 /* line one " has no closing quote, a\b holds a backslash,
             endmodule is only text here, * / is not a delimiter, /* nor is this
             third line */ * 3;
    c = 7 // the rest of this line is comment text: */ /* "
        - 2;
    d = 1 //
        + 8;
    e = 3 /* // */ + 4;
    s = "x//y/*z*/";
    $display("a=%0d b=%0d c=%0d d=%0d e=%0d s=%s", a, b, c, d, e, s);
  end
endmodule
