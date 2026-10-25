/*
:name: test_illegal_hierarchical_ref_automatic_task_variable
:description: Objects declared in an automatic task cannot be referenced by hierarchical names (IEEE 1800-2023 Section 23.6)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.6 13.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial procedure reads count, a variable of the automatic task bump, through the hierarchical name bump.count
:expected_stderr_regex: test_illegal_hierarchical_ref_automatic_task_variable\.sv:29:
*/
// IEEE 1800-2023 §23.6: objects declared in automatic tasks and functions
// (§13.3) cannot be accessed by hierarchical name references. count is
// declared in the automatic task bump, and the initial procedure reads
// bump.count; the same reference to a static task would be legal.
// The 5.052 release of Verilator stops at the reference with an internal
// error, not with a diagnostic of the rule, so it is not listed as an oracle.

module test_illegal_hierarchical_ref_automatic_task_variable;
  task automatic bump(input int d);
    int count;
    count = d + 1;
  endtask

  initial begin
    bump(1);
    $display("count=%0d", bump.count);   // illegal
  end
endmodule
