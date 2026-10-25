/*
:name: test_illegal_solve_before_circular
:description: Ordering constraints with a circular dependency are an error (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: solve a before b together with solve b before c and solve c before a orders the three variables in a circle
:expected_stderr_regex: test_illegal_solve_before_circular\.sv:(24|25|26):
*/
// IEEE 1800-2023 §18.5.9: there shall be no circular dependencies in the
// ordering, such as solve a before b with solve b before a. Here a, b and c
// are ordered in a circle by three ordering constraints, each legal alone. A
// tool can report the error at any of them.
// Icarus Verilog 13.0 does not support constraints, so the syntax error it
// reports does not count; Verilator 5.052 accepts the design.

class sbc_obj;
  rand bit [3:0] a, b, c;
  constraint c_val { a < b; b < c; }
  constraint o1 { solve a before b; }
  constraint o2 { solve b before c; }
  constraint o3 { solve c before a; }   // illegal: closes the circle
endclass

module test_illegal_solve_before_circular;
  sbc_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
