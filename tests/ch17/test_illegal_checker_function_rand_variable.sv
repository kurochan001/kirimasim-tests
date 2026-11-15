/*
:name: test_illegal_checker_function_rand_variable
:description: an internal variable of a function used in a checker cannot be declared as a free variable with rand (IEEE 1800-2023 Section 17.8)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.8
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the internal variable t of the function plus_one, declared in the checker frv_chk and called there, is declared with rand
:expected_stderr_regex: test_illegal_checker_function_rand_variable\.sv:35:
*/
// IEEE 1800-2023 §17.8: the formal arguments and internal variables of a
// function used in a checker shall not be declared as free variables. A free
// variable is a checker variable declared with rand (17.7), and rand is
// allowed only on declarations in the checker body, not on the declarations
// inside a function (a data declaration of A.2.1.3 has no rand).
// frv_chk declares two automatic functions without side effects and calls both
// on the right-hand side of a nonblocking assignment to a checker variable.
// twice keeps its intermediate value in an ordinary variable u; plus_one
// declares its variable t with rand, which is the only error.
// The 5.054 release of Verilator builds the design without rand and rejects
// rand on that line. Icarus Verilog 13.0 does not support checkers, so its
// error does not count.

checker frv_chk(logic clk, logic [7:0] v, output int r);
  function automatic int twice(bit [7:0] x);
    int u;
    u = 2 * x;
    return u;
  endfunction

  function automatic int plus_one(bit [7:0] x);
    rand int t;   // illegal
    t = x + 1;
    return t;
  endfunction

  int q = 0;
  always_ff @(posedge clk) q <= twice(v) + plus_one(v);
  assign r = q;
endchecker : frv_chk

module test_illegal_checker_function_rand_variable;
  logic clk = 1'b0;
  logic [7:0] v = 8'd3;
  int r;

  frv_chk u_chk(clk, v, r);

  initial begin
    #1 clk = 1'b1;
    #1 $display("r=%0d", r);
  end
endmodule
