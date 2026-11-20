/*
:name: test_illegal_typed_lhs_pattern_rhs_type_same_bits
:description: A self-determined RHS needs assignment compatibility even when its total bit count matches (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the RHS has sixteen byte elements instead of two row_t elements
:expected_stderr_regex: test_illegal_typed_lhs_pattern_rhs_type_same_bits\.sv:27:
*/
// IEEE 1800-2023 10.9 B008/B015 requires positional LHS patterns,
// bit-stream members, compatible types and equal bit counts.
// Expected diagnostics are derived from these requirements, not a tool.

module test_illegal_typed_lhs_pattern_rhs_type_same_bits;
  typedef int row_t[2];
  typedef row_t matrix_t[2];
  matrix_t src;
  row_t first, second;
  byte incompatible[16];
  // matrix_t and byte[16] both have 128 bits, but different array shapes.
  initial begin
    matrix_t'{first, second} = src;
    matrix_t'{first, second} = incompatible; // illegal: type, not bit count
  end
endmodule

// Fixed-tool note: Icarus Verilog 13.0 also rejects legal LHS patterns;
// an unsupported diagnostic is not an oracle for these cases.
