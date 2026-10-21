/*
:name: test_illegal_solve_before_randc
:description: A randc variable cannot appear in a solve-before constraint (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.9 18.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the solve-before constraint orders a randc variable
:expected_stderr_regex: test_illegal_solve_before_randc\.sv:24:
*/
// IEEE 1800-2023 §18.5.9: only rand variables can be ordered with solve and
// before; randc variables are not allowed there, since they are always solved
// before any other variable.
// Icarus Verilog 13.0 does not support constraints, so the syntax error it
// reports on that line does not count.

class test_illegal_solve_before_randc_c;
  randc bit [1:0] k;
  rand bit [3:0] v;
  constraint c { v > k; }
  constraint order { solve k before v; }   // illegal: k is randc
endclass

module test_illegal_solve_before_randc;
  test_illegal_solve_before_randc_c o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
