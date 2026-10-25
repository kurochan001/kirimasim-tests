/*
:name: test_checker_assume_stability
:description: Free checker variables keep their values between the clock events of the assume set, and the sampled value of an active free variable is its current value (IEEE 1800-2023 Section 17.7.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.2 17.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_assume_stability.expected
*/
// IEEE 1800-2023 17.7.2: the assumption u1 references the free variable x, so
// the assume set of the instance is not empty and its clock event is the
// rising edge of clk. Solving is triggered by that event, and once updated the
// free variables stay constant until the next such event or the end of the
// time step. The free variable y is active too but no assumption mentions it;
// it is unconstrained yet explicitly clocked, so it may be updated only at the
// same events. A sampled value of an active free variable is its current
// value, so the always_ff procedure that records x and y at an event records
// the values the solver chose there. tick rises at 8, 18 and 28, three time
// units after the clock edges at 5, 15 and 25, and the assertion at those
// times must find both variables where the last event left them.

`timescale 1ns/1ns

checker assume_stability(input logic clk, input logic tick,
                         output int checks, output int changed);
  rand bit [7:0] x;      // active, mentioned by the assumption
  rand bit [7:0] y;      // active, mentioned by no assumption
  bit [7:0] last_x = 8'd0, last_y = 8'd0;

  u1: assume property (@(posedge clk) x != 8'hff);

  always_ff @(posedge clk) begin
    last_x <= x;
    last_y <= y;
  end

  a_tick: assert property (@(posedge tick) x == last_x && y == last_y)
    checks = checks + 1;
    else changed = changed + 1;
endchecker : assume_stability

module test_checker_assume_stability;
  logic clk = 1'b0, tick = 1'b0;
  int checks, changed;

  always #5 clk = ~clk;      // rising edges at 5, 15 and 25

  assume_stability u(.clk(clk), .tick(tick), .checks(checks), .changed(changed));

  initial begin
    #8 tick = 1'b1;          // 8
    #2 tick = 1'b0;          // 10
    #8 tick = 1'b1;          // 18
    #2 tick = 1'b0;          // 20
    #8 tick = 1'b1;          // 28
    #2 $display("checks=%0d changed=%0d", checks, changed);
    $finish;                 // 30
  end
endmodule
