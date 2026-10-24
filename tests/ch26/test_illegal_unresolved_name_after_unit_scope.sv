/*
:name: test_illegal_unresolved_name_after_unit_scope
:description: a name that is not found up to the compilation-unit scope is an error, while a task call that is not found there goes on with upward hierarchical resolution (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.3 23.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the name nowhere_declared is declared neither in module ls_child nor in the compilation unit, and it is not a task or function call
:expected_stderr_regex: test_illegal_unresolved_name_after_unit_scope\.sv:28:
*/
// IEEE 1800-2023 §26.3: the search for a name goes through the outer lexical
// scopes up to the compilation-unit scope, the last one. A reference that is
// not a task or function call is illegal if nothing matches; a task or
// function call that is not found goes on by upward hierarchical name
// resolution (§23.8.1). Module ls_child reads unit_val of the compilation
// unit and calls ls_report, a task of the module that instantiates it,
// which are both legal, and reads nowhere_declared. The call of ls_report
// is also rejected by the 5.052 release of Verilator.

localparam int unit_val = 9;

module ls_child;
  initial #1 $display("%0d", unit_val);
  initial #2 ls_report();
  initial #3 $display("%0d", nowhere_declared);   // illegal
endmodule

module test_illegal_unresolved_name_after_unit_scope;
  ls_child c ();

  task ls_report;
    $display("upward call");
  endtask
endmodule
