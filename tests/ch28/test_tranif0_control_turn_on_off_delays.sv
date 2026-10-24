/*
:name: test_tranif0_control_turn_on_off_delays
:description: tranif0 switches with no delay, one and two delays turn on after the first delay when their control falls to 0 and off after the second when it rises to 1, and react to a control that becomes x or z after the smaller delay (IEEE 1800-2023 Section 28.8)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.8 4.9.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_tranif0_control_turn_on_off_delays.expected
*/
// IEEE 1800-2023 §28.8: tranif0, tranif1, rtranif0 and rtranif1 take zero,
// one or two delays, which act on their control input. Without a delay the
// switch turns on and off at once, one delay is used for both, and with two
// delays the first is the turn-on delay and the second the turn-off delay;
// for switches between built-in nets the smaller of the two is used when
// the control changes to x or z. A tranif0 is on while its control is 0, so
// its turn-on delay, the first, applies when the control falls to 0 and its
// turn-off delay when it rises to 1. Four tranif0 switches with the delays
// none, 4, (3,6) and (6,3) share one control and connect a net driven to a
// strong 1 to a net with a pulldown of its own: that net is 1 while the
// switch is on, 0 while it is off, and x while the control is x or z, since
// the two cases give it different values (4.9.5). For every switch an
// always procedure records the time of the last change of the far net, and
// 9 time units after each control change the delay since that change and
// the value are printed. The control returns from x and z to 0 or 1 in
// steps that are not printed.
// Icarus Verilog 13.0 uses the first delay of a tranif0 when its control
// rises (the switch turns off) and the second when it falls (the switch
// turns on); the standard ties the first delay to turning on.

`timescale 1ns/1ns
module test_tranif0_control_turn_on_off_delays;
  logic c;
  wire near;
  assign near = 1'b1;
  wire far_0, far_4, far_36, far_63;
  pulldown (far_0);
  pulldown (far_4);
  pulldown (far_36);
  pulldown (far_63);

  tranif0 g_0(near, far_0, c);
  tranif0 #4 g_4(near, far_4, c);
  tranif0 #(3, 6) g_36(near, far_36, c);
  tranif0 #(6, 3) g_63(near, far_63, c);

  time t_0, t_4, t_36, t_63;
  always @(far_0) t_0 = $time;
  always @(far_4) t_4 = $time;
  always @(far_36) t_36 = $time;
  always @(far_63) t_63 = $time;

  task automatic step(string what, logic v, bit show);
    time t;
    c = v;
    t = $time;
    #9;
    if (show)
      $display("%s: none=+%0d %b one=+%0d %b (3,6)=+%0d %b (6,3)=+%0d %b", what,
               t_0 - t, far_0, t_4 - t, far_4, t_36 - t, far_36, t_63 - t, far_63);
    #1;
  endtask

  initial begin
    c = 1'b1;
    #10;
    step("1->0", 1'b0, 1);
    step("0->1", 1'b1, 1);
    step("1->x", 1'bx, 1);
    step("x->1", 1'b1, 0);
    step("1->z", 1'bz, 1);
    step("z->0", 1'b0, 0);
    step("0->x", 1'bx, 1);
    step("x->0", 1'b0, 0);
    step("0->z", 1'bz, 1);
  end
endmodule
