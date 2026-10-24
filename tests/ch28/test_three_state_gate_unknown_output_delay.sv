/*
:name: test_three_state_gate_unknown_output_delay
:description: a bufif1 gate whose control becomes unknown changes its output to H or L after the delay of a change to x, not the rise, fall or turn-off delay, and keeps the H or L (IEEE 1800-2023 Section 28.6)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.6 28.16 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_three_state_gate_unknown_output_delay.expected
*/
// IEEE 1800-2023 §28.6: with data 1 or 0 and a control that is x, bufif1
// drives H (1 or z) or L (0 or z), and a change of the output to H or L
// takes the delay of a change to x: the smallest of three delays, or the
// smaller of two (28.16). Other changes take the rise, fall or turn-off
// delay. Four bufif1 gates share their data and control inputs: (5,2,7)
// and (5,2), whose rise delay differs from their x delay, and (2,5,7) and
// (2,5), whose fall delay differs from it, while the turn-off delay 7
// differs from it too. For each gate an always procedure records the time
// of the last change of the output; every change here also changes its
// logic value (H and L are x). 9 time units after each input change the
// delay since that change and the output with its strength (%v, 21.2.1.4)
// are printed, which shows that the output is still H or L.

`timescale 1ns/1ns
module test_three_state_gate_unknown_output_delay;
  logic [1:0] dc;  // {data, control}
  wire o_h3, o_l3, o_h2, o_l2;

  bufif1 #(5, 2, 7) g_h3(o_h3, dc[1], dc[0]);
  bufif1 #(2, 5, 7) g_l3(o_l3, dc[1], dc[0]);
  bufif1 #(5, 2) g_h2(o_h2, dc[1], dc[0]);
  bufif1 #(2, 5) g_l2(o_l2, dc[1], dc[0]);

  time t_h3, t_l3, t_h2, t_l2;
  always @(o_h3) t_h3 = $time;
  always @(o_l3) t_l3 = $time;
  always @(o_h2) t_h2 = $time;
  always @(o_l2) t_l2 = $time;

  task automatic step(string what, logic [1:0] v);
    time t;
    dc = v;
    t = $time;
    #9;
    $display("%s: (5,2,7)=+%0d %v (2,5,7)=+%0d %v (5,2)=+%0d %v (2,5)=+%0d %v", what,
             t_h3 - t, o_h3, t_l3 - t, o_l3, t_h2 - t, o_h2, t_l2 - t, o_l2);
    #1;
  endtask

  initial begin
    dc = 2'b11;  // output 1
    #10;
    step("1->H", 2'b1x);
    step("H->1", 2'b11);
    step("1->L", 2'b0x);
    step("L->1", 2'b11);
    step("1->0", 2'b01);
    step("0->L", 2'b0x);
    step("L->0", 2'b01);
    step("0->H", 2'b1x);
    step("H->0", 2'b01);
    step("0->z", 2'b00);
    step("z->H", 2'b1x);
    step("H->z", 2'b10);
    step("z->L", 2'b0x);
    step("L->z", 2'b00);
  end
endmodule
