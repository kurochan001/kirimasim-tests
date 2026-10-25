/*
:name: test_unbased_unsized_fill_and_self_width
:description: An unbased unsized literal sets every bit that its context needs to its 0, 1, x or z value, is unsigned, and has one bit in a self-determined context (IEEE 1800-2023 Section 5.7.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_unbased_unsized_fill_and_self_width.expected
*/
// IEEE 1800-2023 §5.7.1: '0, '1, 'x and 'z (also 'X and 'Z) are unsized
// unsigned single-bit values: all bits of the value are set to the given
// bit, as many as the expression needs, and in a self-determined context the
// value has a width of 1 bit.
// The literals are assigned to a 70-bit variable, wider than any default
// integer width, and printed with %h. The variable is then compared with '1
// and with 1 in a context of 70 bits. $bits and the operand of $unsigned are
// self-determined, so they see one bit: $unsigned('1) is 1, not all ones.
// In 5 < '1 the literal is unsigned, so the comparison is unsigned and 5 is
// below the all-ones value; a signed '1 would be -1 and give 0.

module test_unbased_unsized_fill_and_self_width;
  logic [69:0] w;
  int r;

  initial begin
    w = '0;
    $display("'0: %h", w);
    w = '1;
    $display("'1: %h", w);
    $display("compare: %0d %0d", w == '1, w == 1);
    w = 'x;
    $display("'x: %h", w);
    w = 'z;
    $display("'z: %h", w);
    w = 'X;
    $display("'X: %h", w);
    w = 'Z;
    $display("'Z: %h", w);
    r = $unsigned('1);
    $display("self: %0d %0d %0d %0d unsigned=%0d", $bits('0), $bits('1), $bits('x), $bits('z), r);
    $display("unsigned compare: %0d", 5 < '1);
  end
endmodule
