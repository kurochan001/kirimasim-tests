/*
:name: test_illegal_typed_lhs_assignment_pattern_rhs_size
:description: a right-hand side with a self-determined type, assigned to an assignment pattern expression with a type, has to be assignment compatible with that type and have its number of bits (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the array s2 of two bytes is assigned to the left-hand side b3_t'{a, b, c}, whose type has three bytes
:expected_stderr_regex: test_illegal_typed_lhs_assignment_pattern_rhs_size\.sv:31:
*/
// IEEE 1800-2023 §10.9: if the right-hand expression of an assignment to an
// assignment pattern expression has a self-determined type, it shall be
// assignment compatible with the type of the pattern and have the same
// number of bits. src has the type b3_t itself, which is legal; s2 is an
// array of two bytes, 16 bits, for the 24 bits of b3_t.
// Icarus Verilog 13.0 gives syntax errors also on the legal left-hand side
// pattern expression, so its error does not count.

module test_illegal_typed_lhs_assignment_pattern_rhs_size;
  typedef byte b3_t [3];
  typedef byte b2_t [2];
  b3_t src = '{1, 2, 3};
  b2_t s2 = '{4, 5};
  byte a, b, c;

  initial begin
    b3_t'{a, b, c} = src;
    b3_t'{a, b, c} = s2;   // illegal: b2_t does not match b3_t
    $display("%0d %0d %0d", a, b, c);
  end
endmodule
