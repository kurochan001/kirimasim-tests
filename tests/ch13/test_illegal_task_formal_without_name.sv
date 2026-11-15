/*
:name: test_illegal_task_formal_without_name
:description: A formal of a task declaration with a body has to have a name, so a formal given only by its direction and the type int is an error (IEEE 1800-2023 Section 13.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second formal of the task declaration report is written as input int, with no port identifier, outside a task prototype
:expected_stderr_regex: test_illegal_task_formal_without_name\.sv:29:
*/
// IEEE 1800-2023 §13.3, footnote 28 of Syntax 13-1: the port identifier of a
// tf_port_item may be left out only in a function or task prototype. A task
// declaration with a body is not a prototype, so each of its formals needs a
// name.
//
// The task report has the formals input int a and input int, and the second
// has no name. int is a keyword, so it cannot be read as the name of a formal
// of an implicit type. With a name for the second formal the design is legal
// and prints "report 1".
// Icarus Verilog 13.0 and the 5.054 release of the Verilator simulator stop
// with a syntax error at the missing name, but they reject an unnamed formal
// in a prototype as well, where the name may be left out, so their errors
// cannot be told apart from this rule and are not counted.

module test_illegal_task_formal_without_name;
  task automatic report(input int a, input int);   // illegal: unnamed formal
    $display("report %0d", a);
  endtask

  initial report(1, 2);
endmodule
