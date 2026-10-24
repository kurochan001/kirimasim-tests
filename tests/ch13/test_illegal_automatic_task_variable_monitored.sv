/*
:name: test_illegal_automatic_task_variable_monitored
:description: a variable of an automatic task cannot be traced with $monitor (IEEE 1800-2023 Section 13.3.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $monitor traces the automatic task variable v
:expected_stderr_regex: test_illegal_automatic_task_variable_monitored\.sv:25:
*/
// IEEE 1800-2023 §13.3.2: variables of an automatic task shall not be traced
// with system tasks such as $monitor and $dumpvars. $display reads v once,
// which is legal; $monitor would trace it after the call has ended.
// Icarus Verilog 13.0 accepts the design, and the 5.052 release of Verilator
// stops with an internal error on this line, which does not count.

module test_illegal_automatic_task_variable_monitored;
  task automatic t(input int a);
    int v;
    v = a;
    $display("%0d", v);
    $monitor("%0d", v);   // illegal
  endtask
  initial t(1);
endmodule
