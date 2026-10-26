/*
:name: test_illegal_constraint_increment
:description: Operators with side effects such as ++ and -- shall not occur in a constraint expression (IEEE 1800-2023 Section 18.5)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constraint applies the increment operator ++ to the random variable x
:expected_stderr_regex: test_illegal_constraint_increment\.sv:20:
*/
// IEEE 1800-2023 §18.5: the declarative nature of constraints forbids
// operators with side effects, such as ++ and --. The constraint uses x++ and
// is illegal.

class c_increment;
  rand int x;
  constraint c { x++ == 3; }   // illegal: side effect
endclass

module test_illegal_constraint_increment;
  c_increment o = new;
  initial $display("randomize=%0d", o.randomize());
endmodule
