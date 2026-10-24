/*
:name: test_illegal_nonblocking_to_automatic_variable
:description: An automatic variable cannot be written by a nonblocking assignment (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 13.3.1 10.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the nonblocking assignment writes the automatic variable av of an automatic task
:expected_stderr_regex: test_illegal_nonblocking_to_automatic_variable\.sv:23:
*/
// IEEE 1800-2023 §6.21: automatic variables shall not be written with
// nonblocking assignments (§10.4.2). av is a variable of the automatic task
// t (§13.3.1); the blocking assignment to it is legal, the nonblocking one
// is the error.

module test_illegal_nonblocking_to_automatic_variable;
  task automatic t();
    int av;
    av = 1;
    av <= 2;    // illegal: nonblocking assignment to an automatic variable
  endtask
  initial t();
endmodule
