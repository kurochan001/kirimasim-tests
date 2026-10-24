/*
:name: test_illegal_call_omits_trailing_argument_without_default
:description: an argument without a default cannot be omitted from a call (IEEE 1800-2023 Section 13.5.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call sum3(7) omits the argument b, which has no default value
:expected_stderr_regex: test_illegal_call_omits_trailing_argument_without_default\.sv:27:
*/
// IEEE 1800-2023 §13.5.3: arguments with defaults may be omitted from a call,
// and the compiler inserts their default values; omitting an argument without
// a default is a compiler error. a and c of sum3 have defaults and b has none.
// The first two calls omit or leave empty only a and c, which is legal; the
// third gives a and omits b and c.

module test_illegal_call_omits_trailing_argument_without_default;
  function int sum3(input int a = 1, input int b, input int c = 3);
    return a + b + c;
  endfunction
  initial begin
    $display("%0d", sum3(, 5));
    $display("%0d", sum3(4, 5, ));
    $display("%0d", sum3(7));   // illegal
  end
endmodule
