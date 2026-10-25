/*
:name: test_block_comment_not_nested
:description: Block comments do not nest, so the first end token closes a block comment that holds more start tokens, and a one-line comment token has no meaning inside a block comment (IEEE 1800-2023 Section 5.4)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_block_comment_not_nested.expected
*/
// IEEE 1800-2023 §5.4: a block comment starts with /* and ends with */, and
// block comments do not nest; the one-line comment token // has no special
// meaning inside a block comment.
// The first assignment has a block comment with a second /* inside it: the
// first */ ends the comment, so + 2 is part of the expression and v is 3.
// If comments nested, the comment would still be open after that */ and the
// rest of the file would be a comment. The second assignment has // inside a
// block comment, which does not hide the */ or the + 8 that follow, so w is
// 12. The third comment has three /* before its one */, so u is 5 * 3 + 1.
// Icarus Verilog 13.0 rejects a /* inside a block comment as a possible
// nested comment; §5.4 gives it no meaning there.

module test_block_comment_not_nested;
  int v, w, u;

  initial begin
    v = 1 /* first /* second */ + 2;
    w = 4 /* a // b */ + 8;
    u = 5 /* /* /* */ * 3 + 1;
    $display("v=%0d w=%0d u=%0d", v, w, u);
  end
endmodule
