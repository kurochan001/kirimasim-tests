/*
:name: test_illegal_automatic_task_item_hierarchical_reference
:description: an item of an automatic task cannot be accessed by a hierarchical reference (IEEE 1800-2023 Section 13.3.1)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the local variable v of the automatic task t is referenced as t.v from the initial procedure
:expected_stderr_regex: test_illegal_automatic_task_item_hierarchical_reference\.sv:32:
*/
// IEEE 1800-2023 §13.3.1: the items declared in an automatic task cannot be
// accessed by hierarchical references, but the automatic task itself can be
// called through its hierarchical name. The initial procedure calls t by the
// hierarchical name test_illegal_automatic_task_item_hierarchical_reference.t,
// which is legal, and then reads t.v, a variable of the automatic task.
// The 5.052 release of Verilator stops with an internal error on this line,
// which does not count.

module test_illegal_automatic_task_item_hierarchical_reference;
  int seen;
  task automatic t(input int a);
    int v;
    v = a + 1;
    seen = v;
  endtask
  initial begin
    test_illegal_automatic_task_item_hierarchical_reference.t(4);
    $display("%0d", seen);
    $display("%0d", t.v);   // illegal
  end
endmodule
