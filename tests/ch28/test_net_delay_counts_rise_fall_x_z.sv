/*
:name: test_net_delay_counts_rise_fall_x_z
:description: a net without a delay changes at once, one net delay is used for every change, and with two the first is used for a change to 1, the second for a change to 0 and the smaller one for a change to x or z (IEEE 1800-2023 Section 28.16)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.16
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_delay_counts_rise_fall_x_z.expected
*/
// IEEE 1800-2023 §28.16: a net delay is the time from a change of a driver of
// the net to the update of the net. For nets as for gates, there is no delay
// when none is given; one delay value is used for every change; with two,
// the first is the delay of a change to 1, the second that of a change to 0,
// and the smaller one is used for a change to z or to x (Table 28-9).
//
// Four nets are driven by the same continuous assignment of s, which has no
// delay of its own: w_none has no net delay, w_one has #5, w_37 has #(3, 7)
// and w_73 has #(7, 3), so that each of the two values is once the smaller.
// s goes through nine changes 20 time units apart, to 1, 0, x and z from
// different values. For each net an always procedure records the time of its
// last change; 19 time units after each change of s the delay since that
// change and the value of the net are printed. The delays are net delays
// (wire #5 w_one; and a separate assign), not delays of a net declaration
// assignment, which 10.3.3 makes delays of the continuous assignment.
// Icarus Verilog 13.0 does not support net delays, and Verilator 5.054 does
// not support the z values driven here.

`timescale 1ns/1ns
module test_net_delay_counts_rise_fall_x_z;
  logic s = 1'b0;
  wire w_none;
  wire #5 w_one;
  wire #(3, 7) w_37;
  wire #(7, 3) w_73;

  assign w_none = s;
  assign w_one = s;
  assign w_37 = s;
  assign w_73 = s;

  time t_none, t_one, t_37, t_73;
  always @(w_none) t_none = $time;
  always @(w_one) t_one = $time;
  always @(w_37) t_37 = $time;
  always @(w_73) t_73 = $time;

  task automatic step(string what, logic v);
    time t;
    s = v;
    t = $time;
    #19;
    $display("%s: none=+%0d %b one=+%0d %b (3,7)=+%0d %b (7,3)=+%0d %b", what,
             t_none - t, w_none, t_one - t, w_one, t_37 - t, w_37, t_73 - t, w_73);
    #1;
  endtask

  initial begin
    #20;
    step("0->1", 1'b1);
    step("1->0", 1'b0);
    step("0->x", 1'bx);
    step("x->1", 1'b1);
    step("1->z", 1'bz);
    step("z->0", 1'b0);
    step("0->z", 1'bz);
    step("z->x", 1'bx);
    step("x->0", 1'b0);
  end
endmodule
