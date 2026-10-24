/*
:name: test_resistive_pass_switch_reduction_each_level
:description: rtran, rtranif0 and rtranif1 reduce supply and strong to pull, pull to weak, weak to medium and medium and small to small, and leave high impedance, for 0 and 1 (IEEE 1800-2023 Section 28.14)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.14 28.8 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_resistive_pass_switch_reduction_each_level.expected
*/
// IEEE 1800-2023 §28.14, Table 28-8: a resistive device reduces the strength
// of what passes through it: supply and strong become pull, pull becomes
// weak, weak and large become medium, medium becomes small, small stays
// small and high impedance stays high impedance; the rtran, rtranif0 and
// rtranif1 switches (28.8) are such devices. One source net per strength
// carries the value v: supply, strong, pull and weak come from continuous
// assignments with these strengths, medium and small from a weak assignment
// through one and two other rtran switches, and the last net is not driven.
// Each source reaches a net of its own through an rtran, an rtranif0 that
// is on and an rtranif1 that is on, and %v (21.2.1.4) shows the source and
// the three nets for v = 1 and v = 0.

module test_resistive_pass_switch_reduction_each_level;
  logic v;
  wire s_su, s_st, s_pu, s_we, s_me, s_sm, s_hz;
  assign (supply0, supply1) s_su = v;
  assign (strong0, strong1) s_st = v;
  assign (pull0, pull1) s_pu = v;
  assign (weak0, weak1) s_we = v;
  wire w_me, w_sm, m_sm;
  assign (weak0, weak1) w_me = v;
  rtran src_me(w_me, s_me);
  assign (weak0, weak1) w_sm = v;
  rtran src_sm1(w_sm, m_sm);
  rtran src_sm2(m_sm, s_sm);

  wire r_su, r0_su, r1_su;
  rtran g_r_su(s_su, r_su);
  rtranif0 g_r0_su(s_su, r0_su, 1'b0);
  rtranif1 g_r1_su(s_su, r1_su, 1'b1);
  wire r_st, r0_st, r1_st;
  rtran g_r_st(s_st, r_st);
  rtranif0 g_r0_st(s_st, r0_st, 1'b0);
  rtranif1 g_r1_st(s_st, r1_st, 1'b1);
  wire r_pu, r0_pu, r1_pu;
  rtran g_r_pu(s_pu, r_pu);
  rtranif0 g_r0_pu(s_pu, r0_pu, 1'b0);
  rtranif1 g_r1_pu(s_pu, r1_pu, 1'b1);
  wire r_we, r0_we, r1_we;
  rtran g_r_we(s_we, r_we);
  rtranif0 g_r0_we(s_we, r0_we, 1'b0);
  rtranif1 g_r1_we(s_we, r1_we, 1'b1);
  wire r_me, r0_me, r1_me;
  rtran g_r_me(s_me, r_me);
  rtranif0 g_r0_me(s_me, r0_me, 1'b0);
  rtranif1 g_r1_me(s_me, r1_me, 1'b1);
  wire r_sm, r0_sm, r1_sm;
  rtran g_r_sm(s_sm, r_sm);
  rtranif0 g_r0_sm(s_sm, r0_sm, 1'b0);
  rtranif1 g_r1_sm(s_sm, r1_sm, 1'b1);
  wire r_hz, r0_hz, r1_hz;
  rtran g_r_hz(s_hz, r_hz);
  rtranif0 g_r0_hz(s_hz, r0_hz, 1'b0);
  rtranif1 g_r1_hz(s_hz, r1_hz, 1'b1);

  task show;
    $display("su %v: rtran=%v rtranif0=%v rtranif1=%v", s_su, r_su, r0_su, r1_su);
    $display("st %v: rtran=%v rtranif0=%v rtranif1=%v", s_st, r_st, r0_st, r1_st);
    $display("pu %v: rtran=%v rtranif0=%v rtranif1=%v", s_pu, r_pu, r0_pu, r1_pu);
    $display("we %v: rtran=%v rtranif0=%v rtranif1=%v", s_we, r_we, r0_we, r1_we);
    $display("me %v: rtran=%v rtranif0=%v rtranif1=%v", s_me, r_me, r0_me, r1_me);
    $display("sm %v: rtran=%v rtranif0=%v rtranif1=%v", s_sm, r_sm, r0_sm, r1_sm);
    $display("hz %v: rtran=%v rtranif0=%v rtranif1=%v", s_hz, r_hz, r0_hz, r1_hz);
  endtask

  initial begin
    v = 1'b1;
    #1 show;
    v = 1'b0;
    #1 show;
  end
endmodule
