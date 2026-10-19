/*
:name: test_expect_statement
:description: expect blocks the process until its property succeeds or fails, starting one evaluation at the next clock tick after it is executed, runs the pass or fail statement and then the next statement in the same time step, and can refer to automatic variables (IEEE 1800-2023 Section 16.17)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expect_statement.expected
*/
// IEEE 1800-2023 §16.17: an expect statement starts a single evaluation of its
// property at the next clocking event, blocks the process until the property
// succeeds or fails, runs the pass or the fail statement of its action block,
// and lets the next statement run after the Observed region of that time step.
// As a blocking statement, it can refer to automatic variables. The first
// expect, executed at 12, sees a at 15, b at 25 and c at 35. The second is
// executed at 35 and starts at 45, where a is low; from 35 it would have
// passed, as a is high at 35 and b at 45. wait_for(7), called at 52, starts
// at 55 and sees data == 7 at 75, two ticks later; wait_for(9), called at 75,
// starts at 85 and fails at 115, when no 9 came at 95, 105 or 115.

`timescale 1ns/1ns

module test_expect_statement;
  logic clk = 0, a = 0, b = 0, c = 0;
  int data = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  task automatic wait_for(int value, output bit ok);
    expect (@(posedge clk) ##[1:3] data == value) ok = 1; else ok = 0;
  endtask

  initial begin
    // Values sampled at 15, 25, ...
    #10 a = 1;
    #10 a = 0; b = 1;
    #10 a = 1; b = 0; c = 1;
    #10 a = 0; b = 1; c = 0;
    #10 b = 0;
    #20 data = 7;
    #10 data = 0;
  end

  initial begin
    bit ok;
    #12;
    expect (@(posedge clk) a ##1 b ##1 c) $display("%0d: first passed", $time);
    else $display("%0d: first failed", $time);
    $display("%0d: after the first", $time);
    expect (@(posedge clk) a ##1 b) $display("%0d: second passed", $time);
    else $display("%0d: second failed", $time);
    $display("%0d: after the second", $time);
    #7;
    wait_for(7, ok);
    $display("%0d: wait_for(7) %0d", $time, ok);
    wait_for(9, ok);
    $display("%0d: wait_for(9) %0d", $time, ok);
    $finish;
  end
endmodule
