/*
:name: test_illegal_typed_lhs_pattern_rhs_width_only
:description: A typed LHS pattern rejects a different RHS bit count even for assignment-compatible integral types (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the three-bit integral RHS is compatible but has one more bit than pair_t
:expected_stderr_regex: test_illegal_typed_lhs_pattern_rhs_width_only\.sv:26:
*/
// IEEE 1800-2023 10.9 B008/B015 separates positional notation,
// bit-stream type, assignment compatibility and equal bit count.
// The legal control precedes one violation derived from those conditions.

module test_illegal_typed_lhs_pattern_rhs_width_only;
  typedef bit [1:0] pair_t;
  bit first, second;
  pair_t valid = 2'b10;
  bit [2:0] wider = 3'b110;
  // Packed integral types are assignment compatible; only bit counts differ.
  initial begin
    pair_t'{first, second} = valid;
    pair_t'{first, second} = wider; // illegal: 3 RHS bits for a 2-bit pattern
  end
endmodule

// Fixed-tool note: Icarus Verilog 13.0 also rejects legal LHS patterns;
// an unsupported diagnostic is not an oracle for these cases.

// The 5.054 release of Verilator accepts this violation at seeds 1 and 73.
// The expected rejection follows 10.9; that acceptance is not an oracle.
