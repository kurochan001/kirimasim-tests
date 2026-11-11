/*
:name: test_illegal_multiclock_two_leading_clocks
:description: A multiclocked property whose leading clocks are not identical has no unique semantic leading clock and cannot be asserted (IEEE 1800-2023 Section 16.16.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.16.1 16.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the two sides of the or start on the rising and on the falling edge of ck
:expected_stderr_regex: test_illegal_multiclock_two_leading_clocks\.sv:23:
*/
// IEEE 1800-2023 §16.16.1: the leading clocks of p or q are those of both
// sides, and a property has a unique semantic leading clock only when they are
// identical. @(posedge ck) and @(negedge ck) are different clocking events, so
// the assertion has no unique leading clock. Icarus Verilog 13.0 does not
// support these concurrent assertions and Verilator 5.052 does not support
// multiclocked properties, so the syntax errors they report here do not count.

module test_illegal_multiclock_two_leading_clocks;
  logic ck, x, y;
  p_two: assert property (@(posedge ck) x or @(negedge ck) y);   // illegal: two leading clocks
endmodule
