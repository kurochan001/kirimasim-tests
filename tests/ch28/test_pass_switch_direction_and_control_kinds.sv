/*
:name: test_pass_switch_direction_and_control_kinds
:description: tran and rtran conduct in both directions, and tranif0, tranif1, rtranif0 and rtranif1 conduct in both directions while on and block while off, with a control that is a 4-state net, a 4-state variable or a 2-state variable (IEEE 1800-2023 Section 28.8)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.8 28.13 28.14 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pass_switch_direction_and_control_kinds.expected
*/
// IEEE 1800-2023 §28.8: tran and rtran have two bidirectional terminals and
// always pass signals in both directions. tranif1 and rtranif1 pass while
// their control, the third terminal, is 1, and tranif0 and rtranif0 while it
// is 0; otherwise they block. The control can be a 4-state net, a 4-state
// variable or a 2-state variable. Every switch has a bufif1 driver on each
// of its two terminals; first the driver of terminal a drives 1 and that of
// b is off, then the driver of b drives 0 and that of a is off, each with
// the control 1 and 0. %v (21.2.1.4) shows the undriven terminal: a strong
// value passes as strong through the nonresistive switches (28.13) and as
// pull through the resistive ones (28.14), and a blocked terminal is z.
// Each controlled switch type has three instances, whose controls are a
// wire, a logic variable and a bit variable that all hold the value c.

`timescale 1ns/1ns
module test_pass_switch_direction_and_control_kinds;
  logic va, vb, ea, eb;
  logic c;
  wire c_net;
  logic c_var;
  bit c_bit;
  assign c_net = c;
  always_comb c_var = c;
  always_comb c_bit = c;

  wire a_t, b_t, a_rt, b_rt;
  wire a_t1_net, b_t1_net, a_t1_var, b_t1_var, a_t1_bit, b_t1_bit;
  wire a_t0_net, b_t0_net, a_t0_var, b_t0_var, a_t0_bit, b_t0_bit;
  wire a_r1_net, b_r1_net, a_r1_var, b_r1_var, a_r1_bit, b_r1_bit;
  wire a_r0_net, b_r0_net, a_r0_var, b_r0_var, a_r0_bit, b_r0_bit;

  tran g_t(a_t, b_t);
  rtran g_rt(a_rt, b_rt);
  tranif1 g_t1_net(a_t1_net, b_t1_net, c_net);
  tranif1 g_t1_var(a_t1_var, b_t1_var, c_var);
  tranif1 g_t1_bit(a_t1_bit, b_t1_bit, c_bit);
  tranif0 g_t0_net(a_t0_net, b_t0_net, c_net);
  tranif0 g_t0_var(a_t0_var, b_t0_var, c_var);
  tranif0 g_t0_bit(a_t0_bit, b_t0_bit, c_bit);
  rtranif1 g_r1_net(a_r1_net, b_r1_net, c_net);
  rtranif1 g_r1_var(a_r1_var, b_r1_var, c_var);
  rtranif1 g_r1_bit(a_r1_bit, b_r1_bit, c_bit);
  rtranif0 g_r0_net(a_r0_net, b_r0_net, c_net);
  rtranif0 g_r0_var(a_r0_var, b_r0_var, c_var);
  rtranif0 g_r0_bit(a_r0_bit, b_r0_bit, c_bit);

  // The drivers of the a terminals and of the b terminals.
  bufif1 d_a_t(a_t, va, ea), d_b_t(b_t, vb, eb);
  bufif1 d_a_rt(a_rt, va, ea), d_b_rt(b_rt, vb, eb);
  bufif1 d_a_t1_net(a_t1_net, va, ea), d_b_t1_net(b_t1_net, vb, eb);
  bufif1 d_a_t1_var(a_t1_var, va, ea), d_b_t1_var(b_t1_var, vb, eb);
  bufif1 d_a_t1_bit(a_t1_bit, va, ea), d_b_t1_bit(b_t1_bit, vb, eb);
  bufif1 d_a_t0_net(a_t0_net, va, ea), d_b_t0_net(b_t0_net, vb, eb);
  bufif1 d_a_t0_var(a_t0_var, va, ea), d_b_t0_var(b_t0_var, vb, eb);
  bufif1 d_a_t0_bit(a_t0_bit, va, ea), d_b_t0_bit(b_t0_bit, vb, eb);
  bufif1 d_a_r1_net(a_r1_net, va, ea), d_b_r1_net(b_r1_net, vb, eb);
  bufif1 d_a_r1_var(a_r1_var, va, ea), d_b_r1_var(b_r1_var, vb, eb);
  bufif1 d_a_r1_bit(a_r1_bit, va, ea), d_b_r1_bit(b_r1_bit, vb, eb);
  bufif1 d_a_r0_net(a_r0_net, va, ea), d_b_r0_net(b_r0_net, vb, eb);
  bufif1 d_a_r0_var(a_r0_var, va, ea), d_b_r0_var(b_r0_var, vb, eb);
  bufif1 d_a_r0_bit(a_r0_bit, va, ea), d_b_r0_bit(b_r0_bit, vb, eb);

  initial begin
    for (int i = 1; i >= 0; i--) begin
      c = i;
      va = 1'b1; ea = 1'b1; vb = 1'b0; eb = 1'b0;
      #1;
      $display("a=1 -> b, c=%b: tran=%v rtran=%v tranif1=%v %v %v tranif0=%v %v %v", c,
               b_t, b_rt, b_t1_net, b_t1_var, b_t1_bit, b_t0_net, b_t0_var, b_t0_bit);
      $display("a=1 -> b, c=%b: rtranif1=%v %v %v rtranif0=%v %v %v", c,
               b_r1_net, b_r1_var, b_r1_bit, b_r0_net, b_r0_var, b_r0_bit);
      ea = 1'b0; eb = 1'b1;
      #1;
      $display("b=0 -> a, c=%b: tran=%v rtran=%v tranif1=%v %v %v tranif0=%v %v %v", c,
               a_t, a_rt, a_t1_net, a_t1_var, a_t1_bit, a_t0_net, a_t0_var, a_t0_bit);
      $display("b=0 -> a, c=%b: rtranif1=%v %v %v rtranif0=%v %v %v", c,
               a_r1_net, a_r1_var, a_r1_bit, a_r0_net, a_r0_var, a_r0_bit);
    end
  end
endmodule
