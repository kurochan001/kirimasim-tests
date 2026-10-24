/*
:name: test_illegal_automatic_task_variable_in_nonblocking_event
:description: a variable of an automatic task cannot be in the event control of a nonblocking assignment (IEEE 1800-2023 Section 13.3.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the intra-assignment event control of a nonblocking assignment waits on the automatic task variable v
:expected_stderr_regex: test_illegal_automatic_task_variable_in_nonblocking_event\.sv:27:
*/
// IEEE 1800-2023 §13.3.2: variables of an automatic task shall not be
// referenced in intra-assignment event controls of nonblocking assignments. The
// first nonblocking assignment waits on the static variable clk, which is
// legal; the second waits on the automatic v.
// The 5.052 release of Verilator accepts the design.

module test_illegal_automatic_task_variable_in_nonblocking_event;
  logic clk;
  int s;
  task automatic t(input int a);
    logic v;
    v = 0;
    s <= @(posedge clk) 1;
    s <= @(posedge v) 2;   // illegal
  endtask
  initial t(1);
endmodule
