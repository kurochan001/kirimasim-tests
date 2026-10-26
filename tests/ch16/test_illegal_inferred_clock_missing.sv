/*
:name: test_illegal_inferred_clock_missing
:description: the default actual of a property formal is $inferred_clock, and the property is asserted where no clock event can be resolved
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.14.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: p_bad takes $inferred_clock as the default actual of its formal clk, and the assertion in the initial block has no enclosing clock to resolve
:expected_stderr_regex: test_illegal_inferred_clock_missing\.sv:(25|29):
*/
// IEEE 1800-2023 §16.14.7: $inferred_clock is an elaboration-time query that
// returns the clocking event resolved by clock flow at the instance location,
// and an error shall be issued when no event is resolved. It may be used only
// as the entire default value of a formal of a property, sequence or checker.
// p_bad uses it that way for its formal clk, and the assertion in the initial
// block is not inside any clocking event, so no clock flows to it and the
// assertion is illegal. The property declaration itself is legal.

module test_illegal_inferred_clock_missing;
  logic a = 0;

  property p_bad(clk = $inferred_clock);
    @clk a;
  endproperty

  initial a_bad: assert property (p_bad);   // illegal
endmodule
