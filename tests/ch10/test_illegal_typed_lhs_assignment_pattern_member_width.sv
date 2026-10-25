/*
:name: test_illegal_typed_lhs_assignment_pattern_member_width
:description: each member of an assignment pattern expression with a type on the left-hand side has to have as many bits as the element of that type (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the left-hand side b3_t'{a, b, wide} puts the 32-bit int wide where b3_t has a byte element
:expected_stderr_regex: test_illegal_typed_lhs_assignment_pattern_member_width\.sv:33:
*/
// IEEE 1800-2023 §10.9: in a left-hand side assignment pattern expression,
// each member expression shall have a bit-stream type that is assignment
// compatible with, and has the same number of bits as, the corresponding
// element of the type of the pattern. b3_t'{a, b, c} with byte variables is
// legal, also with an untyped pattern on the right; the int wide has 32 bits
// where b3_t has an 8-bit element.
// Icarus Verilog 13.0 gives syntax errors also on the legal left-hand side
// pattern expressions, so its error does not count; the design is accepted
// by the 5.052 release of Verilator.

module test_illegal_typed_lhs_assignment_pattern_member_width;
  typedef byte b3_t [3];
  b3_t src = '{1, 2, 3};
  byte a, b, c;
  int wide;

  initial begin
    b3_t'{a, b, c} = src;
    b3_t'{c, a, b} = '{a + 1, b + 1, c + 1};
    b3_t'{a, b, wide} = src;   // illegal: an int member for a byte element
    $display("%0d %0d %0d", a, b, c);
  end
endmodule
