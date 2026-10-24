/*
:name: test_sampled_function_clock_inference
:description: a sampled value function without a clock argument takes the leading clock of the assertion in an action block, the clock inferred from an always procedure there, and the default clocking in a procedure without an inferred clock (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.3 16.14.6 14.12 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sampled_function_clock_inference.expected
*/
// IEEE 1800-2023 §16.9.3: when its clock is not given, a sampled value
// function other than $sampled takes, in an action block, the leading clock
// of the assertion; in a procedure, the clock inferred from it (§16.14.6), if
// any; elsewhere outside an assertion, the default clocking (§14.12). $past(v)
// is then the sampled value of v at the previous tick of that clock, or the
// default sampled value 0 before the first one. clk rises at 5, 15, 25 and
// 35, clk2 at 8, 18 and 28, and v takes the values 1 to 7 at 2, 7, 12, 17,
// 22, 27 and 32, so v is sampled as 1, 3, 5, 7 at the ticks of clk and as 2,
// 4, 6 at those of clk2. The default clocking is clocked by clk2. The always
// procedure, clocked by posedge clk, prints $past(v) of clk; the actions
// (§16.14.1) of a_clk and a_clk2 print it for their own clocks; the initial
// procedure, which waits with delays and so has no inferred clock, prints it
// at 20 and 30 for the default clocking.

`timescale 1ns/1ns

module test_sampled_function_clock_inference;
  logic clk = 0, clk2 = 0;
  int v = 0;

  default clocking dc @(posedge clk2);
  endclocking

  always #5 clk = ~clk;   // rising at 5, 15, 25, 35

  initial begin
    #8;
    forever begin         // rising at 8, 18, 28
      clk2 = 1;
      #5 clk2 = 0;
      #5;
    end
  end

  a_clk: assert property (@(posedge clk) 1'b1)
    $display("t=%0t a_clk action: $past(v)=%0d", $time, $past(v));
  a_clk2: assert property (@(posedge clk2) 1'b1)
    $display("t=%0t a_clk2 action: $past(v)=%0d", $time, $past(v));

  always @(posedge clk) $display("t=%0t always @(posedge clk): $past(v)=%0d", $time, $past(v));

  initial begin
    #2 v = 1;
    #5 v = 2;
    #5 v = 3;
    #5 v = 4;
    #5 v = 5;
    #5 v = 6;
    #5 v = 7;
  end

  initial begin
    #20 $display("t=%0t initial, default clocking: $past(v)=%0d", $time, $past(v));
    #10 $display("t=%0t initial, default clocking: $past(v)=%0d", $time, $past(v));
    #6 $finish;
  end
endmodule
