/*
:name: test_illegal_no_clock_fallback
:description: With no explicit, default or context-inferred assertion clock, the maximal property shall be a sequence or property instance with a uniquely determined leading clock, so a bare a ##1 b with no clock is an error (IEEE 1800-2023 Section 16.16)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the maximal property a ##1 b is not an instance and has no leading clocking event
:expected_stderr_regex: test_illegal_no_clock_fallback\.sv:30:
*/
// IEEE 1800-2023 §16.16 f): if a concurrent assertion has no explicit
// leading clocking event, no default clocking event and no contextually
// inferred clock, the maximal property shall be an instance of a sequence or
// property for which a unique leading clocking event is determined. p_ok
// writes @(posedge clk) explicitly and is legal. p_bad is the bare sequence
// expression a ##1 b: the module has no default clocking and the assertion
// has no leading clock, and the maximal property is not an instance, so the
// design is illegal. Verilator 5.052 reports that the concurrent assertion
// has no clock at this line.

module test_illegal_no_clock_fallback;
  logic clk = 0;
  logic a = 0;
  logic b = 0;

  p_ok: assert property (@(posedge clk) a ##1 b);
  p_bad: assert property (a ##1 b);   // illegal: no leading clock
endmodule
