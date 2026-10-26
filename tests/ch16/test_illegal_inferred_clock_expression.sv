/*
:name: test_illegal_inferred_clock_expression
:description: An inferred clocking function shall be used only as the entire default value expression of a formal argument to a property, sequence or checker, so using $inferred_clock as a property expression is an error (IEEE 1800-2023 Section 16.14.7)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.14.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: p_bad uses $inferred_clock as its property expression instead of as a formal default
:expected_stderr_regex: test_illegal_inferred_clock_expression\.sv:31:
*/
// IEEE 1800-2023 §16.14.7: $inferred_clock returns the clocking event that
// clock flow resolves at the point of the call, and shall only be used as the
// entire default value expression for a formal argument to a property,
// sequence or checker declaration. In p_ok the call is the whole default of
// the untyped formal clkarg, and p_good provides the context @(posedge clk),
// so both are legal. In p_bad $inferred_clock is itself the property
// expression, which the placement rule forbids.

module test_illegal_inferred_clock_expression;
  logic clk = 0;
  logic a = 1;

  property p_ok(clkarg = $inferred_clock);
    @(clkarg) a;
  endproperty

  p_good: assert property (@(posedge clk) p_ok);
  p_bad: assert property (@(posedge clk) $inferred_clock);   // illegal
endmodule
