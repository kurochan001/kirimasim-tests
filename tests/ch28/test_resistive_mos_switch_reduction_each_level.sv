/*
:name: test_resistive_mos_switch_reduction_each_level
:description: rnmos, rpmos and rcmos reduce supply and strong to pull, pull to weak, large and weak to medium and medium and small to small, and leave high impedance; rtran reduces a large charge to medium (IEEE 1800-2023 Section 28.14)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.14 28.7 28.9 28.15.2 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_resistive_mos_switch_reduction_each_level.expected
*/
// IEEE 1800-2023 §28.14, Table 28-8: the resistive switches rnmos, rpmos and
// rcmos (28.7, 28.9) reduce the strength of their data input: supply and
// strong become pull, pull becomes weak, large and weak become medium,
// medium becomes small, small stays small and high impedance stays high
// impedance. One source net per strength carries the value v: supply,
// strong, pull and weak come from continuous assignments with these
// strengths; large is a trireg (large) net that a bufif1 charges and then
// leaves, so that it holds v with its large charge strength (28.15.2);
// medium and small come from a weak assignment through one and two rtran
// switches; the last net is not driven. Each source feeds an rnmos, an
// rpmos and an rcmos that are on, each to a net of its own, and the large
// source also reaches a net through an rtran. %v (21.2.1.4) shows the
// sources and the nets for v = 1 and v = 0.
// Icarus Verilog 13.0 does not support trireg nets, and it shows the output
// of rnmos, rpmos and rcmos without the reduction; Verilator 5.052 does not
// support these switches.

`timescale 1ns/1ns
module test_resistive_mos_switch_reduction_each_level;
  logic v, charge;
  wire s_su, s_st, s_pu, s_we, s_me, s_sm, s_hz;
  trireg (large) s_la;
  assign (supply0, supply1) s_su = v;
  assign (strong0, strong1) s_st = v;
  assign (pull0, pull1) s_pu = v;
  bufif1 drv_la(s_la, v, charge);
  assign (weak0, weak1) s_we = v;
  wire w_me, w_sm, m_sm;
  assign (weak0, weak1) w_me = v;
  rtran src_me(w_me, s_me);
  assign (weak0, weak1) w_sm = v;
  rtran src_sm1(w_sm, m_sm);
  rtran src_sm2(m_sm, s_sm);

  wire rn_su, rp_su, rc_su;
  rnmos g_rn_su(rn_su, s_su, 1'b1);
  rpmos g_rp_su(rp_su, s_su, 1'b0);
  rcmos g_rc_su(rc_su, s_su, 1'b1, 1'b0);
  wire rn_st, rp_st, rc_st;
  rnmos g_rn_st(rn_st, s_st, 1'b1);
  rpmos g_rp_st(rp_st, s_st, 1'b0);
  rcmos g_rc_st(rc_st, s_st, 1'b1, 1'b0);
  wire rn_pu, rp_pu, rc_pu;
  rnmos g_rn_pu(rn_pu, s_pu, 1'b1);
  rpmos g_rp_pu(rp_pu, s_pu, 1'b0);
  rcmos g_rc_pu(rc_pu, s_pu, 1'b1, 1'b0);
  wire rn_la, rp_la, rc_la;
  rnmos g_rn_la(rn_la, s_la, 1'b1);
  rpmos g_rp_la(rp_la, s_la, 1'b0);
  rcmos g_rc_la(rc_la, s_la, 1'b1, 1'b0);
  wire rn_we, rp_we, rc_we;
  rnmos g_rn_we(rn_we, s_we, 1'b1);
  rpmos g_rp_we(rp_we, s_we, 1'b0);
  rcmos g_rc_we(rc_we, s_we, 1'b1, 1'b0);
  wire rn_me, rp_me, rc_me;
  rnmos g_rn_me(rn_me, s_me, 1'b1);
  rpmos g_rp_me(rp_me, s_me, 1'b0);
  rcmos g_rc_me(rc_me, s_me, 1'b1, 1'b0);
  wire rn_sm, rp_sm, rc_sm;
  rnmos g_rn_sm(rn_sm, s_sm, 1'b1);
  rpmos g_rp_sm(rp_sm, s_sm, 1'b0);
  rcmos g_rc_sm(rc_sm, s_sm, 1'b1, 1'b0);
  wire rn_hz, rp_hz, rc_hz;
  rnmos g_rn_hz(rn_hz, s_hz, 1'b1);
  rpmos g_rp_hz(rp_hz, s_hz, 1'b0);
  rcmos g_rc_hz(rc_hz, s_hz, 1'b1, 1'b0);
  wire rt_la;
  rtran g_rt_la(s_la, rt_la);

  task show;
    $display("su %v: rnmos=%v rpmos=%v rcmos=%v", s_su, rn_su, rp_su, rc_su);
    $display("st %v: rnmos=%v rpmos=%v rcmos=%v", s_st, rn_st, rp_st, rc_st);
    $display("pu %v: rnmos=%v rpmos=%v rcmos=%v", s_pu, rn_pu, rp_pu, rc_pu);
    $display("la %v: rnmos=%v rpmos=%v rcmos=%v rtran=%v", s_la, rn_la, rp_la, rc_la, rt_la);
    $display("we %v: rnmos=%v rpmos=%v rcmos=%v", s_we, rn_we, rp_we, rc_we);
    $display("me %v: rnmos=%v rpmos=%v rcmos=%v", s_me, rn_me, rp_me, rc_me);
    $display("sm %v: rnmos=%v rpmos=%v rcmos=%v", s_sm, rn_sm, rp_sm, rc_sm);
    $display("hz %v: rnmos=%v rpmos=%v rcmos=%v", s_hz, rn_hz, rp_hz, rc_hz);
  endtask

  // The bufif1 charges the trireg while charge is 1 and leaves it at 1.
  initial begin
    v = 1'b1;
    charge = 1'b1;
    #1 charge = 1'b0;
    #1 show;
    v = 1'b0;
    charge = 1'b1;
    #1 charge = 1'b0;
    #1 show;
  end
endmodule
