/*
:name: test_illegal_automatic_task_variable_dumped
:description: a variable of an automatic task cannot be traced with $dumpvars (IEEE 1800-2023 Section 13.3.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $dumpvars traces the automatic task variable v
:expected_stderr_regex: test_illegal_automatic_task_variable_dumped\.sv:25:
*/
// IEEE 1800-2023 §13.3.2: variables of an automatic task shall not be traced
// with system tasks such as $monitor and $dumpvars. $dumpvars on the static
// module variable s is legal; on the automatic v it is not.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design.

module test_illegal_automatic_task_variable_dumped;
  int s;
  task automatic t(input int a);
    int v;
    v = a;
    $dumpvars(1, s);
    $dumpvars(1, v);   // illegal
  endtask
  initial t(1);
endmodule
