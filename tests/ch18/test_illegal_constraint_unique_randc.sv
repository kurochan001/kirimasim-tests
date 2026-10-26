/*
:name: test_illegal_constraint_unique_randc
:description: No randc variable may appear in a uniqueness constraint, so unique {a, b} with randc a and rand b is an error while unique {c, d} of two rand variables is legal (IEEE 1800-2023 Section 18.5.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the randc variable a is a member of the uniqueness group of u_bad
:expected_stderr_regex: test_illegal_constraint_unique_randc\.sv:28:
*/
// IEEE 1800-2023 §18.5.4: all members of a uniqueness group shall have
// equivalent types, and no randc variable shall appear in the group. The
// group of u_ok contains two rand bit variables of equivalent type and is
// legal. The group of u_bad contains the randc variable a and the rand
// variable b, so it is illegal: a randc variable already cycles through its
// values and cannot take part in a uniqueness constraint.

class c_unique;
  randc bit [3:0] a;
  rand bit [3:0] b;
  rand bit [3:0] c;
  rand bit [3:0] d;

  constraint u_ok { unique {c, d}; }
  constraint u_bad { unique {a, b}; }   // illegal: randc member a
endclass

module test_illegal_constraint_unique_randc;
  c_unique o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
