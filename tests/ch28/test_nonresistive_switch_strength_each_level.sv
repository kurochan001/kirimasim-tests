/*
:name: test_nonresistive_switch_strength_each_level
:description: nmos, pmos, cmos, tran, tranif0 and tranif1 pass supply, strong, pull, weak, medium, small and high impedance 0 and 1 with their strength, except that supply becomes strong (IEEE 1800-2023 Section 28.13)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.13 28.7 28.8 28.9 28.14 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_nonresistive_switch_strength_each_level.expected
*/
// IEEE 1800-2023 §28.13: the nmos, pmos and cmos switches pass the strength
// of their data input to their output, and tran, tranif0 and tranif1 keep
// the strength of a signal across their terminals, except that a supply
// strength becomes strong (also 28.7, 28.8 and 28.9). One source net per
// strength carries the value v: supply, strong, pull and weak come from
// continuous assignments with these strengths, medium and small from a weak
// assignment through one and two rtran switches, which reduce weak to
// medium and medium to small (Table 28-8 in 28.14), and the last net is not
// driven. Each source feeds an nmos and a cmos that are on, a pmos that is
// on, and a tran, a tranif0 and a tranif1 that are on, each to a net of its
// own, and %v (21.2.1.4) shows the source and the six nets for v = 1 and
// v = 0.

module test_nonresistive_switch_strength_each_level;
  logic v;
  wire s_su, s_st, s_pu, s_we, s_me, s_sm, s_hz;
  assign (supply0, supply1) s_su = v;
  assign (strong0, strong1) s_st = v;
  assign (pull0, pull1) s_pu = v;
  assign (weak0, weak1) s_we = v;
  wire w_me, w_sm, m_sm;
  assign (weak0, weak1) w_me = v;
  rtran r_me(w_me, s_me);
  assign (weak0, weak1) w_sm = v;
  rtran r_sm1(w_sm, m_sm);
  rtran r_sm2(m_sm, s_sm);

  wire n_su, p_su, c_su, t_su, t0_su, t1_su;
  nmos g_n_su(n_su, s_su, 1'b1);
  pmos g_p_su(p_su, s_su, 1'b0);
  cmos g_c_su(c_su, s_su, 1'b1, 1'b0);
  tran g_t_su(s_su, t_su);
  tranif0 g_t0_su(s_su, t0_su, 1'b0);
  tranif1 g_t1_su(s_su, t1_su, 1'b1);
  wire n_st, p_st, c_st, t_st, t0_st, t1_st;
  nmos g_n_st(n_st, s_st, 1'b1);
  pmos g_p_st(p_st, s_st, 1'b0);
  cmos g_c_st(c_st, s_st, 1'b1, 1'b0);
  tran g_t_st(s_st, t_st);
  tranif0 g_t0_st(s_st, t0_st, 1'b0);
  tranif1 g_t1_st(s_st, t1_st, 1'b1);
  wire n_pu, p_pu, c_pu, t_pu, t0_pu, t1_pu;
  nmos g_n_pu(n_pu, s_pu, 1'b1);
  pmos g_p_pu(p_pu, s_pu, 1'b0);
  cmos g_c_pu(c_pu, s_pu, 1'b1, 1'b0);
  tran g_t_pu(s_pu, t_pu);
  tranif0 g_t0_pu(s_pu, t0_pu, 1'b0);
  tranif1 g_t1_pu(s_pu, t1_pu, 1'b1);
  wire n_we, p_we, c_we, t_we, t0_we, t1_we;
  nmos g_n_we(n_we, s_we, 1'b1);
  pmos g_p_we(p_we, s_we, 1'b0);
  cmos g_c_we(c_we, s_we, 1'b1, 1'b0);
  tran g_t_we(s_we, t_we);
  tranif0 g_t0_we(s_we, t0_we, 1'b0);
  tranif1 g_t1_we(s_we, t1_we, 1'b1);
  wire n_me, p_me, c_me, t_me, t0_me, t1_me;
  nmos g_n_me(n_me, s_me, 1'b1);
  pmos g_p_me(p_me, s_me, 1'b0);
  cmos g_c_me(c_me, s_me, 1'b1, 1'b0);
  tran g_t_me(s_me, t_me);
  tranif0 g_t0_me(s_me, t0_me, 1'b0);
  tranif1 g_t1_me(s_me, t1_me, 1'b1);
  wire n_sm, p_sm, c_sm, t_sm, t0_sm, t1_sm;
  nmos g_n_sm(n_sm, s_sm, 1'b1);
  pmos g_p_sm(p_sm, s_sm, 1'b0);
  cmos g_c_sm(c_sm, s_sm, 1'b1, 1'b0);
  tran g_t_sm(s_sm, t_sm);
  tranif0 g_t0_sm(s_sm, t0_sm, 1'b0);
  tranif1 g_t1_sm(s_sm, t1_sm, 1'b1);
  wire n_hz, p_hz, c_hz, t_hz, t0_hz, t1_hz;
  nmos g_n_hz(n_hz, s_hz, 1'b1);
  pmos g_p_hz(p_hz, s_hz, 1'b0);
  cmos g_c_hz(c_hz, s_hz, 1'b1, 1'b0);
  tran g_t_hz(s_hz, t_hz);
  tranif0 g_t0_hz(s_hz, t0_hz, 1'b0);
  tranif1 g_t1_hz(s_hz, t1_hz, 1'b1);

  task show;
    $display("su %v: nmos=%v pmos=%v cmos=%v tran=%v tranif0=%v tranif1=%v",
             s_su, n_su, p_su, c_su, t_su, t0_su, t1_su);
    $display("st %v: nmos=%v pmos=%v cmos=%v tran=%v tranif0=%v tranif1=%v",
             s_st, n_st, p_st, c_st, t_st, t0_st, t1_st);
    $display("pu %v: nmos=%v pmos=%v cmos=%v tran=%v tranif0=%v tranif1=%v",
             s_pu, n_pu, p_pu, c_pu, t_pu, t0_pu, t1_pu);
    $display("we %v: nmos=%v pmos=%v cmos=%v tran=%v tranif0=%v tranif1=%v",
             s_we, n_we, p_we, c_we, t_we, t0_we, t1_we);
    $display("me %v: nmos=%v pmos=%v cmos=%v tran=%v tranif0=%v tranif1=%v",
             s_me, n_me, p_me, c_me, t_me, t0_me, t1_me);
    $display("sm %v: nmos=%v pmos=%v cmos=%v tran=%v tranif0=%v tranif1=%v",
             s_sm, n_sm, p_sm, c_sm, t_sm, t0_sm, t1_sm);
    $display("hz %v: nmos=%v pmos=%v cmos=%v tran=%v tranif0=%v tranif1=%v",
             s_hz, n_hz, p_hz, c_hz, t_hz, t0_hz, t1_hz);
  endtask

  initial begin
    v = 1'b1;
    #1 show;
    v = 1'b0;
    #1 show;
  end
endmodule
