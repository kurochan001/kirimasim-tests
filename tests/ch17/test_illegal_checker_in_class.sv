/*
:name: test_illegal_checker_in_class
:description: A checker cannot be instantiated in a method of a class, where a concurrent assertion cannot appear (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3 16.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a checker is instantiated in a task of a class
:expected_stderr_regex: test_illegal_checker_in_class\.sv:28:
*/
// IEEE 1800-2023 §17.3: a checker may be instantiated wherever a concurrent
// assertion may appear. §16.14 lists those places: a module, an interface, a
// program, a generate block, a checker, and an always or initial procedure. A
// method of a class is none of them, so the checker instance in the task run is
// illegal. The 5.052 release reports a syntax error on that line because it
// does not support checker instances in procedural code; Icarus Verilog 13.0
// does not support checkers at all, so its error falls on the declaration.

checker test_illegal_checker_in_class_chk(input logic a);
  p: assert property (@(posedge a) 1);
endchecker

class test_illegal_checker_in_class_c;
  task run();
    test_illegal_checker_in_class_chk c(1'b1);   // illegal
  endtask
endclass

module test_illegal_checker_in_class;
  initial begin
    test_illegal_checker_in_class_c o = new();
    o.run();
  end
endmodule
