/*
:name: test_checker_free_variable_function_actual
:description: a free checker variable can be the actual argument of a function called on the right-hand side of checker variable assignments, and an initialized constant free variable passes its initial value (IEEE 1800-2023 Section 17.8)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_free_variable_function_actual.expected
*/
// IEEE 1800-2023 §17.8: the formal arguments and internal variables of a
// function used in a checker cannot be free variables, but a free variable
// may be passed to such a function as an actual argument; the right-hand side
// of a checker variable assignment may call an automatic function without
// side effects. §17.7: a constant free variable that is initialized keeps its
// initial value forever.
// fva_chk declares rand const k = 7 and passes k to sq_plus, which returns
// x * x + 1, in a continuous assignment to q_cont and in a nonblocking
// assignment to q_ff at each clock edge; q_ff starts at 0. Both results reach
// the module through output arguments. Before the first clock edge q_cont is
// already 50 and q_ff is still 0; after it, both are 50. A wrong value of k,
// such as a random one, would change the 50.
// Icarus Verilog 13.0 does not support checkers, and the 5.054 release
// of Verilator does not support rand checker variables.

`timescale 1ns/1ns

checker fva_chk(event clk, output int r_ff, output int r_cont);
  rand const bit [7:0] k = 8'd7;

  function automatic int sq_plus(bit [7:0] x);
    return x * x + 1;
  endfunction

  int q_ff = 0;
  int q_cont;

  assign q_cont = sq_plus(k);
  always_ff @clk q_ff <= sq_plus(k);

  assign r_ff = q_ff;
  assign r_cont = q_cont;
endchecker : fva_chk

module test_checker_free_variable_function_actual;
  logic clk = 1'b0;
  int r_ff, r_cont;

  fva_chk u_chk(posedge clk, r_ff, r_cont);

  initial begin
    #1 $display("before the clock: r_ff=%0d r_cont=%0d", r_ff, r_cont);
    #4 clk = 1'b1;
    #5 $display("after the clock: r_ff=%0d r_cont=%0d", r_ff, r_cont);
    $finish;
  end
endmodule
