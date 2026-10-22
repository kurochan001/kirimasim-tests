/*
:name: test_illegal_stacktrace_argument
:description: The standard stacktrace call accepts no arguments (IEEE 1800-2023 Section 20.17.2)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.17.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a value argument is supplied to the argumentless stacktrace task
:expected_stderr_regex: test_illegal_stacktrace_argument\.sv:(?:20)(?::|\s)
*/
// IEEE 1800-2023 20.17.2: The stacktrace syntax has no argument list accepting
// a value; stack contents are tool dependent, so this negative test checks the
// call contract instead.
// Oracle checks: Icarus Verilog 13.0 accepts the illegal design.

module test_illegal_stacktrace_argument;
  initial $stacktrace(1); // illegal
endmodule
