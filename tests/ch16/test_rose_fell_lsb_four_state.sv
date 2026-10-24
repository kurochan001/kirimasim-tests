/*
:name: test_rose_fell_lsb_four_state
:description: $rose is true exactly when the sampled least significant bit becomes 1, from 0, x or z, and $fell exactly when it becomes 0, from 1, x or z; a change to x or z, between x and z, or in the other bits makes neither true (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.3 16.5.1 16.14.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_rose_fell_lsb_four_state.expected
*/
// IEEE 1800-2023 §16.9.3: $rose returns 1 if the least significant bit of
// the sampled value of its expression changed to 1 since the previous tick of
// its clocking event, and $fell if it changed to 0; otherwise they return 0.
// So a change from 0, x or z to 1 is a rise and one from 1, x or z to 0 a
// fall, while a change to x or z, or between x and z, is neither, and the
// upper bit of v plays no part. The functions are called in an always
// procedure clocked by posedge clk, which gives them its clock (§16.14.6).
// v changes between the ticks, at the falling edges, so the sampled values
// (§16.5.1) are the values set half a period before each tick; v starts as
// 2'b00, which is also its default sampled value at the first tick.

`timescale 1ns/1ns

module test_rose_fell_lsb_four_state;
  logic clk = 0;
  logic [1:0] v = 2'b00;
  logic [1:0] vals[18] = '{2'b00, 2'b01, 2'b01, 2'b00, 2'b0x, 2'b01, 2'b0x, 2'b00, 2'b0z,
                           2'b01, 2'b0z, 2'b00, 2'b0x, 2'b0z, 2'b0x, 2'b10, 2'b01, 2'b11};
  int tick = 0;

  always #5 clk = ~clk;   // rising edges at 5, 15, 25, ...

  always @(posedge clk) begin
    tick++;
    $display("tick %0d: v=%b rose=%b fell=%b", tick, $sampled(v), $rose(v), $fell(v));
  end

  initial begin
    foreach (vals[i]) begin
      v = vals[i];
      @(negedge clk);
    end
    #1 $finish;
  end
endmodule
