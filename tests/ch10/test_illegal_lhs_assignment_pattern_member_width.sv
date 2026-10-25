/*
:name: test_illegal_lhs_assignment_pattern_member_width
:description: each member of an assignment pattern on the left-hand side has to have as many bits as the element of the right-hand side it receives (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the left-hand side pattern '{a, b, wide} puts the 32-bit int wide where src has a byte element
:expected_stderr_regex: test_illegal_lhs_assignment_pattern_member_width\.sv:31:
*/
// IEEE 1800-2023 §10.9: each member expression of a left-hand side assignment
// pattern shall have a bit-stream type that is assignment compatible with,
// and has the same number of bits as, the corresponding element of the
// right-hand side. '{a, b, c} with three byte variables matches the byte
// elements of src, which is legal; the int wide has 32 bits, not 8.
// Icarus Verilog 13.0 gives syntax errors also on the legal left-hand side
// pattern, and the 5.052 release of Verilator reports it as unsupported, so
// neither error counts.

module test_illegal_lhs_assignment_pattern_member_width;
  typedef byte b3_t [3];
  b3_t src = '{1, 2, 3};
  byte a, b, c;
  int wide;

  initial begin
    '{a, b, c} = src;
    '{a, b, wide} = src;   // illegal: an int member for a byte element
    $display("%0d %0d %0d", a, b, c);
  end
endmodule
