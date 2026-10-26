/*
:name: test_illegal_solve_parentheses
:description: Parentheses in a solve before list are allowed only for an array built-in method such as size(), not around a plain random variable (IEEE 1800-2023 Section 18.5)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5 18.5.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the solve before list writes (x), a parenthesized plain variable
:expected_stderr_regex: test_illegal_solve_parentheses\.sv:20:
*/
// IEEE 1800-2023 §18.5: parentheses are allowed in a constraint_primary only
// when it is an array built-in method such as size(). The solve before list
// here parenthesizes the variable x and is illegal.

class c_solve_parens;
  rand int x, y;
  constraint c { solve (x) before y; }   // illegal: parentheses on a variable
endclass

module test_illegal_solve_parentheses;
  c_solve_parens o = new;
  initial $display("randomize=%0d", o.randomize());
endmodule
