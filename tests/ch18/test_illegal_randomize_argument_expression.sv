/*
:name: test_illegal_randomize_argument_expression
:description: an expression as an argument of the randomize() method is an error, since its arguments are property names (IEEE 1800-2023 Section 18.11)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call o.randomize(y + 1) passes an expression, but the arguments of randomize() are limited to property names of the object
:expected_stderr_regex: test_illegal_randomize_argument_expression\.sv:35:
*/
// IEEE 1800-2023 §18.11: the arguments of the randomize() method are looked
// up in the class of the object, and they are limited to the names of its
// properties; expressions are not allowed. o.randomize(y) names the non-rand
// property y, which is legal and makes y random for that call; the module
// has a y of its own, which the argument does not denote. o.randomize(y + 1)
// is the error. test_illegal_randomize_argument_local passes a local
// member.
// Icarus Verilog 13.0 does not support randomize(), so its error does not
// count.

class rae_obj;
  rand bit [3:0] x;
  bit [3:0] y;
endclass

module test_illegal_randomize_argument_expression;
  rae_obj o = new;
  int y, r1, r2;

  initial begin
    r1 = o.randomize(y);
    r2 = o.randomize(y + 1);   // illegal: an expression, not a property name
    $display("%0d %0d", r1, r2);
  end
endmodule
