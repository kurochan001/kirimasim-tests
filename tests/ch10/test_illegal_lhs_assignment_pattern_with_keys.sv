/*
:name: test_illegal_lhs_assignment_pattern_with_keys
:description: an assignment pattern on the left-hand side of an assignment has to use positional notation, not keys (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the assignment pattern on the left-hand side uses the index keys 0, 1 and 2
:expected_stderr_regex: test_illegal_lhs_assignment_pattern_with_keys\.sv:29:
*/
// IEEE 1800-2023 §10.9: when an assignment pattern is the left-hand side of
// an assignment, positional notation shall be required. '{a, b, c} = src takes
// the three elements of src apart, which is legal; the same pattern written
// with index keys is not.
// Icarus Verilog 13.0 gives syntax errors also on the legal left-hand side
// pattern, and the 5.052 release of Verilator reports it as unsupported, so
// neither error counts.

module test_illegal_lhs_assignment_pattern_with_keys;
  typedef byte b3_t [3];
  b3_t src = '{1, 2, 3};
  byte a, b, c;

  initial begin
    '{a, b, c} = src;
    '{0:a, 1:b, 2:c} = src;   // illegal: keys in a left-hand side pattern
    $display("%0d %0d %0d", a, b, c);
  end
endmodule
