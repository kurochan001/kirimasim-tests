/*
:name: test_comment_forms
:description: One-line and block comments: a block comment ends at its first closing delimiter, and each form's delimiters mean nothing inside the other (IEEE 1800-2023 Section 5.4)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comment_forms.expected
*/
// IEEE 1800-2023 §5.4: a one-line comment runs from // to the end of the line,
// and a block comment from its opening delimiter to the first closing one, so
// block comments do not nest. Inside a block comment // has no meaning, and
// inside a one-line comment the block delimiters have no meaning. A block
// comment can sit between the tokens of an expression.

module test_comment_forms;
  int a, b, c, d;

  initial begin
    a = 1 /* a block comment // holding a slash pair */ + 2;
    b = 10; // a one-line comment holding /* an opening delimiter
    c = 4 /* the first closing delimiter ends this comment */ + 5 /* again */;
    d = /**/ 7 /***/;
    $display("a=%0d b=%0d c=%0d d=%0d", a, b, c, d);
  end
endmodule
