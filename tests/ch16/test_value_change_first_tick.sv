/*
:name: test_value_change_first_tick
:description: At the first clock tick $rose, $fell, $stable, $changed and $past compare with the default sampled value, which is the declaration's initial value or the type's default (x for logic, 0 for bit); at later ticks they compare with the previous tick (IEEE 1800-2023 Sections 16.9.3 and 16.5.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.3 16.5.1 16.14.6 6.8
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_value_change_first_tick.expected
*/
// IEEE 1800-2023 §16.9.3: called in the time step of the first clocking event,
// the value change functions compare the sampled value with the default
// sampled value, and $past returns that default value. §16.5.1: the default
// sampled value of a static variable is the value of its declaration
// assignment, or else the default value of its type (6.8): x for u (logic),
// 0 for b (bit), 1 for one and zero_now's 0. Before the first tick at 5, u,
// b and zero_now become 1 and one_then_0 becomes 0. The functions are called
// in an always procedure clocked by posedge clk, which gives them their
// clocking event (16.14.6). At the second tick nothing has changed.

`timescale 1ns/1ns

module test_value_change_first_tick;
  logic clk = 0;
  logic u;
  bit b;
  logic one = 1'b1;
  logic zero_now = 1'b0;
  logic one_then_0 = 1'b1;
  int tick = 0;

  always #5 clk = ~clk;   // ticks at 5 and 15

  always @(posedge clk) begin
    tick++;
    $display("tick %0d: u rose %b fell %b stable %b changed %b past %b", tick,
             $rose(u), $fell(u), $stable(u), $changed(u), $past(u));
    $display("tick %0d: b rose %b stable %b past %b, one rose %b stable %b past %b", tick,
             $rose(b), $stable(b), $past(b), $rose(one), $stable(one), $past(one));
    $display("tick %0d: zero_now rose %b past %b, one_then_0 fell %b past %b", tick,
             $rose(zero_now), $past(zero_now), $fell(one_then_0), $past(one_then_0));
  end

  initial begin
    #1 u = 1'b1;
    b = 1'b1;
    zero_now = 1'b1;
    one_then_0 = 1'b0;
    #19 $finish;
  end
endmodule
