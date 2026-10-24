/*
:name: test_illegal_sampled_fell_without_clock
:description: $fell needs a clocking event, which a continuous assignment without default clocking cannot infer (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $fell is called without a clocking event in a continuous assignment of a module that has no default clocking
:expected_stderr_regex: test_illegal_sampled_fell_without_clock\.sv:30:
*/
// IEEE 1800-2023 §16.9.3: a sampled value function other than $sampled needs
// a clocking event, given as an argument or inferred: in an assertion from
// the clock flow, in an action block from the leading clock, in a procedure
// from the procedural context, and elsewhere from default clocking. In a
// disable condition or a clock expression it shall be given explicitly.
// The module has no default clocking. The continuous assignments of s and e
// call $sampled, which needs no clock, and $fell with an explicit clock;
// the assignment of r calls $fell with neither.
// Icarus Verilog 13.0 and Verilator 5.052 do not support the clocking event
// argument of $fell, and report errors on another line, which do not count.

module test_illegal_sampled_fell_without_clock;
  logic clk = 0, a = 0;
  logic r, s, e;
  assign s = $sampled(a);
  assign e = $fell(a, @(posedge clk));
  assign r = $fell(a);   // illegal
endmodule
