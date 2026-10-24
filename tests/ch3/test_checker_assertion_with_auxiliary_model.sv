/*
:name: test_checker_assertion_with_auxiliary_model
:description: A checker between checker and endchecker holds a concurrent assertion together with modeling code, a checker variable counted by an always_ff procedure and given out through an output; two instances check and count their own inputs (IEEE 1800-2023 Section 3.6)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.6 17.2 17.5 17.7.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_assertion_with_auxiliary_model.expected
*/
// IEEE 1800-2023 §3.6: a checker, enclosed by checker and endchecker, is a
// verification block that holds assertions together with modeling code.
// §17.2: its formal arguments take the actuals of each instance; §17.5 and
// §17.7.1: an always_ff procedure of the checker assigns its checker
// variable with nonblocking assignments, and the expressions in it other
// than the clock are sampled.
// cc_chk counts the clock edges at which its input a is 1 in its variable
// count, which a continuous assignment gives to the output seen, and
// asserts that a is not 1 on two edges in a row; the failure action prints
// the time and the id input of the instance. The clock rises at 5, 15, 25,
// 35 and 45; the inputs change only between edges:
// - c1 has a1 = 1 at the edges 5 and 15, so its assertion fails at 15 and
//   it counts 2;
// - c2 has a2 = 1 at the edges 15, 35 and 45, so its assertion fails only
//   at 45 and it counts 3.
// The top module prints the outputs at time 50 and ends the simulation.
// Icarus Verilog 13.0 does not support checkers (syntax error at the
// checker declaration).

`timescale 1ns/1ns

checker cc_chk(input logic clk, input logic a, input int id, output int seen);
  int count = 0;

  always_ff @(posedge clk) count <= count + a;
  assign seen = count;

  a_no_repeat: assert property (@(posedge clk) a |=> !a)
    else $display("t=%0t checker %0d: a was 1 on two edges in a row", $time, id);
endchecker : cc_chk

module test_checker_assertion_with_auxiliary_model;
  logic clk = 0, a1 = 0, a2 = 0;
  int n1, n2;

  always #5 clk = ~clk;

  cc_chk c1(clk, a1, 1, n1);
  cc_chk c2(clk, a2, 2, n2);

  initial begin
    a1 = 1;
    #10 a2 = 1;
    #10 a1 = 0;
    a2 = 0;
    #10 a2 = 1;
    #20 $display("t=%0t counts: c1=%0d c2=%0d", $time, n1, n2);
    $finish;
  end
endmodule
