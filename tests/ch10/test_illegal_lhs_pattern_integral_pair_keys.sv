/*
:name: test_illegal_lhs_pattern_integral_pair_keys
:description: LHS pattern keys are forbidden while integral member types and widths otherwise match (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the LHS uses index keys although its members have matching bit-stream types and widths
:expected_stderr_regex: test_illegal_lhs_pattern_integral_pair_keys\.sv:25:
*/
// IEEE 1800-2023 10.9 B008/B015 separates positional notation,
// bit-stream type, assignment compatibility and equal bit count.
// The legal control precedes one violation derived from those conditions.

module test_illegal_lhs_pattern_integral_pair_keys;
  typedef bit [63:0] element_t;
  typedef element_t pair_t[2];
  pair_t src;
  element_t first, second;
  initial begin
    '{first, second} = src;
    '{0:first, 1:second} = src; // illegal: keyed LHS instead of positional
  end
endmodule

// Fixed-tool note: Icarus Verilog 13.0 also rejects legal LHS patterns;
// an unsupported diagnostic is not an oracle for these cases.
// The 5.054 release of Verilator also rejects legal untyped LHS patterns.
// Its matching unsupported diagnostic is not an oracle for this rule.
