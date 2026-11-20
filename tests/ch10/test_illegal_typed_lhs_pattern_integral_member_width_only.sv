/*
:name: test_illegal_typed_lhs_pattern_integral_member_width_only
:description: LHS pattern members require equal widths even for assignment-compatible integral types (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the first integral member has 63 bits where the corresponding element has 64
:expected_stderr_regex: test_illegal_typed_lhs_pattern_integral_member_width_only\.sv:27:
*/
// IEEE 1800-2023 10.9 B008/B015 separates positional notation,
// bit-stream type, assignment compatibility and equal bit count.
// The legal control precedes one violation derived from those conditions.

module test_illegal_typed_lhs_pattern_integral_member_width_only;
  typedef bit [63:0] element_t;
  typedef element_t pair_t[2];
  pair_t src;
  element_t first, second;
  bit [62:0] narrow;
  // Every member is integral and assignment compatible; one has 63 not 64 bits.
  initial begin
    pair_t'{first, second} = src;
    pair_t'{narrow, second} = src; // illegal: member width only
  end
endmodule

// Fixed-tool note: Icarus Verilog 13.0 also rejects legal LHS patterns;
// an unsupported diagnostic is not an oracle for these cases.

// The 5.054 release of Verilator accepts this violation at seeds 1 and 73.
// The expected rejection follows 10.9; that acceptance is not an oracle.
