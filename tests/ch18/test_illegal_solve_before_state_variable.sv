/*
:name: test_illegal_solve_before_state_variable
:description: A variable that is not rand cannot appear in a solve-before constraint (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the solve-before constraint orders a property that is not declared rand
:expected_stderr_regex: test_illegal_solve_before_state_variable\.sv:24:
*/
// IEEE 1800-2023 §18.5.9: the variables of a solve-before constraint shall be
// random variables declared rand; limit is a state variable of the class.
// Icarus Verilog 13.0 does not support constraints, so the syntax error it
// reports on that line does not count. Verilator 5.052 accepts the design
// (docs/simulator-differences.md).

class test_illegal_solve_before_state_variable_c;
  int limit = 8;
  rand int v;
  constraint c { v < limit; v >= 0; }
  constraint order { solve limit before v; }   // illegal: limit is not rand
endclass

module test_illegal_solve_before_state_variable;
  test_illegal_solve_before_state_variable_c o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
