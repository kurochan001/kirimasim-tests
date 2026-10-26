/*
:name: test_illegal_constraint_unique_expression
:description: Every item of a uniqueness constraint shall denote a singular variable or an unpacked array variable or slice, so the expression b + 1 in unique {a, b + 1} is an error although unique {a, b} is legal (IEEE 1800-2023 Section 18.5.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the uniqueness group bad contains the expression b + 1 instead of a variable
:expected_stderr_regex: test_illegal_constraint_unique_expression\.sv:26:
*/
// IEEE 1800-2023 §18.5.4: the range_list of a uniqueness constraint shall
// contain only expressions that denote singular variables of integral or real
// type, unpacked array variables whose leaf elements are integral or real, or
// slices of them. The group ok contains the singular variables a and b and is
// legal. The group bad contains b + 1, which is a value, not a variable, so
// no variable can be made distinct by the constraint, and it is illegal.

class c_unique;
  rand bit [3:0] a;
  rand bit [3:0] b;

  constraint ok { unique {a, b}; }
  constraint bad { unique {a, b + 1}; }   // illegal: b + 1 is no variable
endclass

module test_illegal_constraint_unique_expression;
  c_unique o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
