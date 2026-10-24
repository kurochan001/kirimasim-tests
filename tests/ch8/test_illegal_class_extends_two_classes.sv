/*
:name: test_illegal_class_extends_two_classes
:description: a class extends a single base class; extending two classes, multiple inheritance, is illegal (IEEE 1800-2023 Section 8.13)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.13
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class both_c names two base classes after extends
:expected_stderr_regex: test_illegal_class_extends_two_classes\.sv:32:
*/
// IEEE 1800-2023 §8.13: a class can extend one base class only; SystemVerilog
// has no multiple inheritance of classes (a class can implement several
// interface classes, §8.26, which is not used here). one_c extends left_c
// legally; both_c names two base classes.
// The grammar admits one class type after extends, so a syntax error on that
// line is a right rejection.

class left_c;
  int l = 1;
endclass

class right_c;
  int r = 2;
endclass

class one_c extends left_c;
endclass

class both_c extends left_c, right_c;   // illegal: two base classes
endclass

module test_illegal_class_extends_two_classes;
  one_c o = new;
  initial $display("l=%0d", o.l);
endmodule
