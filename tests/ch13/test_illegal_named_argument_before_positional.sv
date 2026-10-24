/*
:name: test_illegal_named_argument_before_positional
:description: positional arguments of a call have to come before the named ones (IEEE 1800-2023 Section 13.5.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call f(.b(2), 1) has a positional argument after a named one
:expected_stderr_regex: test_illegal_named_argument_before_positional\.sv:24:
*/
// IEEE 1800-2023 §13.5.4: when a call has both positional and named arguments,
// all the positional arguments shall come before the named ones. f(1, .b(2))
// is legal; f(.b(2), 1) is not.

module test_illegal_named_argument_before_positional;
  function int f(input int a, input int b);
    return 10 * a + b;
  endfunction
  initial begin
    $display("%0d", f(1, .b(2)));
    $display("%0d", f(.b(2), 1));   // illegal
  end
endmodule
