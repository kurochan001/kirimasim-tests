/*
:name: test_illegal_checker_function_rand_argument
:description: a formal argument of a function used in a checker cannot be declared as a free variable with rand (IEEE 1800-2023 Section 17.8)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.8
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the formal argument x of the function plus_one, declared in the checker fra_chk and called there, is declared with rand
:expected_stderr_regex: test_illegal_checker_function_rand_argument\.sv:32:
*/
// IEEE 1800-2023 §17.8: the formal arguments and internal variables of a
// function used in a checker shall not be declared as free variables. A free
// variable is a checker variable declared with rand (17.7), and rand is
// allowed only on declarations in the checker body, not on the ports of a
// function (the function port syntax of A.2.7 has no rand).
// fra_chk declares two automatic functions without side effects and calls both
// on the right-hand side of a nonblocking assignment to a checker variable.
// The formal of twice is an ordinary argument; the formal of plus_one is
// declared with rand, which is the only error.
// The 5.054 release of Verilator builds the design without rand and rejects
// rand on that line. Icarus Verilog 13.0 does not support checkers, so its
// error does not count.

checker fra_chk(logic clk, logic [7:0] v, output int r);
  function automatic int twice(bit [7:0] x);
    return 2 * x;
  endfunction

  function automatic int plus_one(rand bit [7:0] x);   // illegal
    return x + 1;
  endfunction

  int q = 0;
  always_ff @(posedge clk) q <= twice(v) + plus_one(v);
  assign r = q;
endchecker : fra_chk

module test_illegal_checker_function_rand_argument;
  logic clk = 1'b0;
  logic [7:0] v = 8'd3;
  int r;

  fra_chk u_chk(clk, v, r);

  initial begin
    #1 clk = 1'b1;
    #1 $display("r=%0d", r);
  end
endmodule
