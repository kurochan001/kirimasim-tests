/*
:name: test_intra_assignment_repeat_nonblocking
:description: A nonblocking assignment with an intra-assignment repeat event control takes the right-hand value when it executes and assigns it after the given number of events; the count is evaluated once, and a count of zero or less assigns without waiting (IEEE 1800-2023 Section 9.4.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.5 10.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_intra_assignment_repeat_nonblocking.expected
*/
// IEEE 1800-2023 §9.4.5: in a <= repeat(n) @(posedge clk) data, data is
// evaluated when the statement executes, and a gets the value after n rising
// edges; the process does not wait (10.4.2). The count is evaluated once, so
// changing n afterwards has no effect, and a count less than or equal to zero
// makes the assignment happen as if there were no repeat. Rising edges are at
// 5, 15, 25, 35, 45 and 55: the first assignment, at 1, completes at 25 with
// 11, though data has become 22 by then; the second, at 31 with a count of 2,
// completes at 45 with 22; the third, at 51 with a count of -1, at once.

`timescale 1ns/1ns

module test_intra_assignment_repeat_nonblocking;
  logic clk = 0;
  logic [7:0] a = 8'h00, data = 8'h11;
  int n;

  always #5 clk = ~clk;

  always @(a) $display("%0d: a = %h", $time, a);

  initial begin
    #1 a <= repeat (3) @(posedge clk) data;
    data = 8'h22;
    n = 2;
    #30 a <= repeat (n) @(posedge clk) data;
    n = 5;
    #20 a <= repeat (-1) @(posedge clk) 8'h33;
    #5 $finish;
  end
endmodule
