/*
:name: test_illegal_constraint_function_cycle
:description: Random variables used as function arguments establish an implicit ordering, and a circular dependency created by that ordering shall result in an error (IEEE 1800-2023 Section 18.5.11)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: c1 orders y before x and c2 orders x before y through the function arguments
:expected_stderr_regex: test_illegal_constraint_function_cycle\.sv:(25|26):
*/
// IEEE 1800-2023 §18.5.11: a random variable used as a function argument gets
// the higher priority, so c1 solves y before x and c2 solves x before y. The
// circular dependency shall result in an error.

class c_function_cycle;
  rand int x, y;

  function automatic int f(int v);
    return v;
  endfunction

  constraint c1 { x <= f(y); }   // illegal: y before x
  constraint c2 { y <= f(x); }   // illegal: x before y, a cycle
endclass

module test_illegal_constraint_function_cycle;
  c_function_cycle o = new;
  initial $display("randomize=%0d", o.randomize());
endmodule
