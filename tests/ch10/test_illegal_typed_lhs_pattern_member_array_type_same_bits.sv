/*
:name: test_illegal_typed_lhs_pattern_member_array_type_same_bits
:description: Equal bit counts do not make different unpacked array member types assignment compatible (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the first member has two int elements instead of eight byte elements
:expected_stderr_regex: test_illegal_typed_lhs_pattern_member_array_type_same_bits\.sv:27:
*/
// IEEE 1800-2023 10.9 B008/B015 requires positional LHS patterns,
// bit-stream members, compatible types and equal bit counts.
// Expected diagnostics are derived from these requirements, not a tool.

module test_illegal_typed_lhs_pattern_member_array_type_same_bits;
  typedef byte row_t[8];
  typedef row_t matrix_t[2];
  matrix_t src;
  row_t first, second;
  int incompatible[2];
  // row_t and int[2] both have 64 bits, but have different array lengths.
  initial begin
    matrix_t'{first, second} = src;
    matrix_t'{incompatible, second} = src; // illegal: type, not bit count
  end
endmodule

// Fixed-tool note: Icarus Verilog 13.0 also rejects legal LHS patterns;
// an unsupported diagnostic is not an oracle for these cases.
