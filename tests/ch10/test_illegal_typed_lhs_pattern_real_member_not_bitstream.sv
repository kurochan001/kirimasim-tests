/*
:name: test_illegal_typed_lhs_pattern_real_member_not_bitstream
:description: A compatible equal-width real member is not a bit-stream type for an LHS pattern (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the real member has matching type and width but is not a bit-stream data type
:expected_stderr_regex: test_illegal_typed_lhs_pattern_real_member_not_bitstream\.sv:30:
*/
// IEEE 1800-2023 10.9 B008/B015 requires positional LHS patterns,
// bit-stream members, compatible types and equal bit counts.
// Expected diagnostics are derived from these requirements, not a tool.

module test_illegal_typed_lhs_pattern_real_member_not_bitstream;
  typedef struct { real r; int i; } record_t;
  record_t src;
  real real_member;
  int int_member;
  int control[2];
  typedef int control_t[2];
  int c0, c1;
  initial begin
    control_t'{c0, c1} = control;
    real_member = src.r;
    int_member = src.i;
    record_t'{real_member, int_member} = src; // illegal: real is not bit-stream
  end
endmodule

// Fixed-tool note: Icarus Verilog 13.0 also rejects legal LHS patterns;
// an unsupported diagnostic is not an oracle for these cases.

// The 5.054 release of Verilator accepts this violation at seeds 1 and 73.
// The expected rejection follows 10.9; that acceptance is not an oracle.
