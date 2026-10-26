/*
:name: test_checker_always_statement_kinds
:description: checker always procedures take selection and loop statements, subroutine calls, immediate assertions and let declarations; always_comb and always_latch assign with blocking assignments, always_ff has the event control and assigns with nonblocking assignments (IEEE 1800-2023 Section 17.5)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_always_statement_kinds.expected
*/
// IEEE 1800-2023 17.5: the procedures of a checker allow selection and loop
// statements, calls of subroutines, immediate assertions and let
// declarations. A blocking assignment may appear only in always_comb or
// always_latch, an event control only in always_ff, and always_ff may assign
// with nonblocking assignments.
//
// d is 2 and becomes 5 at time 10. The always_comb procedure declares the let
// twice, adds 1 twice in a for loop by calling plus_one, and chooses between
// twice + 2 and d + 2 with an if, so it gives 4 and then 12; its immediate
// assertion must hold. The always_latch procedure assigns with a blocking
// assignment while d is greater than 0, so it follows d. The always_ff
// procedure has the event control and a nonblocking assignment, so at the
// rising edges at 5, 15 and 25 it copies d into ff_state one edge late, and
// the value of ff_out printed at 28 is the 5 that d had before the edge at 15.

`timescale 1ns/1ns

checker always_kinds(input logic clk, input int d,
                     output int comb_out, output int latch_out, output int ff_out);
  function automatic int plus_one(int x);
    return x + 1;
  endfunction

  always_comb begin
    let twice = d * 2;
    int acc;
    acc = 0;
    for (int i = 0; i < 2; i++)
      acc = plus_one(acc);
    if (d > 3)
      comb_out = twice + acc;
    else
      comb_out = d + acc;
    a_comb: assert (comb_out >= 0);
  end

  always_latch begin
    if (d > 0)
      latch_out = d;
  end

  int ff_state = 0;
  always_ff @(posedge clk) begin
    ff_state <= d;
    ff_out <= ff_state;
  end
endchecker : always_kinds

module test_checker_always_statement_kinds;
  logic clk = 1'b0;
  int d = 2;
  int comb_out, latch_out, ff_out;

  always #5 clk = ~clk;      // rising edges at 5, 15 and 25

  always_kinds c(.clk(clk), .d(d), .comb_out(comb_out),
                 .latch_out(latch_out), .ff_out(ff_out));

  initial begin
    #10 d = 5;
    #18 $display("comb=%0d latch=%0d ff=%0d", comb_out, latch_out, ff_out);
    $finish;                 // 28
  end
endmodule
