/*
:name: test_always_comb_vs_star_assertion_in_function
:description: the expression of an immediate assertion in a function called by always_comb is in its sensitivity, while always @* calling the same function is sensitive only to assertions written in its own body (IEEE 1800-2023 Section 9.2.2.2.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2.2 9.2.2.2.1 9.4.2.2 16.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_vs_star_assertion_in_function.expected
*/
// IEEE 1800-2023 §9.2.2.2.2: always_comb is sensitive to the expressions of
// immediate assertions in the procedure and in the functions it calls,
// whereas always @* is sensitive to those in the procedure only. 9.4.2.2:
// @* adds the identifiers of its own statement; a function call adds only
// its arguments.
//
// The function chk has the immediate assertion "assert (e > 0)" and no
// arguments. Both procedures call it; the @* body also has its own
// assertion "assert (q > 0)". Every assertion passes. Each procedure counts
// its runs through a task. always_comb runs at time 0 and @* does not:
//   e = 2   reruns always_comb only
//   q = 2   runs @* only (q is in its own assertion; always_comb never reads q)
//
// The 5.052 release of Verilator stops with a settle region that does not
// converge, as for other always_comb blocks that count their runs.

module test_always_comb_vs_star_assertion_in_function;
  int e = 1, q = 1;
  int n_comb = 0, n_star = 0;

  function automatic void chk();
    a_func: assert (e > 0);
  endfunction

  task bump_comb();
    n_comb++;
  endtask

  task bump_star();
    n_star++;
  endtask

  always_comb begin
    bump_comb();
    chk();
  end

  always @* begin
    bump_star();
    chk();
    a_star: assert (q > 0);
  end

  initial begin
    #1 $display("start: comb=%0d star=%0d", n_comb, n_star);
    e = 2;
    #1 $display("e = 2: comb=%0d star=%0d", n_comb, n_star);
    q = 2;
    #1 $display("q = 2: comb=%0d star=%0d", n_comb, n_star);
  end
endmodule
