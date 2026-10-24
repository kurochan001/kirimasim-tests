/*
:name: test_builtin_primitive_categories
:description: One instance or more of each kind of built-in primitive (logic gates, buffers, three-state gates, MOS, CMOS and bidirectional switches, pullup and pulldown) gives the values of its truth table, including z from a disabled gate or switch (IEEE 1800-2023 Section 3.7)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.7 28.4 28.5 28.6 28.7 28.8 28.9 28.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_builtin_primitive_categories.expected
*/
// IEEE 1800-2023 §3.7: the language has built-in primitives for gates and
// switches, whose behavior clauses 28.4 to 28.10 define. The test
// instantiates each kind and prints the values (not the strengths) at
// time 1:
// - and, nand, or, nor, xor, xnor with the inputs 1 and 0, and a three-input
//   and with 1, 1, 1 (§28.4): 0 1 1 0 1 0 and 1;
// - buf with two outputs and the input 0, not with 0, and buf whose input
//   is a variable holding z, which gives x (§28.5): 0 0, 1, x;
// - bufif1, bufif0, notif1, notif0 with data and control as given; a gate
//   whose control disables it gives z (§28.6);
// - nmos, pmos and rnmos with data and gate; a switch that is off gives z
//   (§28.7);
// - cmos with the n-channel gate on, the p-channel gate on, and both off
//   (§28.9): 1, 0, z;
// - tran passes the 1 driven on one terminal to the other; tranif1 that is
//   off leaves its undriven terminal at z; tranif0 that is on passes 0
//   (§28.8);
// - pullup gives 1 and pulldown gives 0 on otherwise undriven nets
//   (§28.10).

`timescale 1ns/1ns

module test_builtin_primitive_categories;
  wire y_and, y_nand, y_or, y_nor, y_xor, y_xnor, y_and3;
  wire b1, b2, y_not, y_bufz;
  wire t_bufif1_on, t_bufif1_off, t_bufif0_on, t_notif1_on, t_notif0_off;
  wire m_nmos_on, m_nmos_off, m_pmos_on, m_pmos_off, m_rnmos_on;
  wire c_n_on, c_p_on, c_off;
  wire s_a, s_b, s_c, s_d, s_e, s_f;
  wire p_up, p_down;
  logic z_in = 1'bz;

  and  g_and (y_and, 1'b1, 1'b0);
  nand g_nand (y_nand, 1'b1, 1'b0);
  or   g_or (y_or, 1'b1, 1'b0);
  nor  g_nor (y_nor, 1'b1, 1'b0);
  xor  g_xor (y_xor, 1'b1, 1'b0);
  xnor g_xnor (y_xnor, 1'b1, 1'b0);
  and  g_and3 (y_and3, 1'b1, 1'b1, 1'b1);

  buf  g_buf2 (b1, b2, 1'b0);
  not  g_not (y_not, 1'b0);
  buf  g_bufz (y_bufz, z_in);

  bufif1 g_bufif1_on (t_bufif1_on, 1'b1, 1'b1);
  bufif1 g_bufif1_off (t_bufif1_off, 1'b1, 1'b0);
  bufif0 g_bufif0_on (t_bufif0_on, 1'b0, 1'b0);
  notif1 g_notif1_on (t_notif1_on, 1'b1, 1'b1);
  notif0 g_notif0_off (t_notif0_off, 1'b1, 1'b1);

  nmos  g_nmos_on (m_nmos_on, 1'b1, 1'b1);
  nmos  g_nmos_off (m_nmos_off, 1'b1, 1'b0);
  pmos  g_pmos_on (m_pmos_on, 1'b0, 1'b0);
  pmos  g_pmos_off (m_pmos_off, 1'b0, 1'b1);
  rnmos g_rnmos_on (m_rnmos_on, 1'b1, 1'b1);

  cmos g_cmos_n (c_n_on, 1'b1, 1'b1, 1'b1);
  cmos g_cmos_p (c_p_on, 1'b0, 1'b0, 1'b0);
  cmos g_cmos_off (c_off, 1'b1, 1'b0, 1'b1);

  assign s_a = 1'b1;
  tran g_tran (s_a, s_b);
  assign s_c = 1'b1;
  tranif1 g_tranif1_off (s_c, s_d, 1'b0);
  assign s_e = 1'b0;
  tranif0 g_tranif0_on (s_e, s_f, 1'b0);

  pullup   g_up (p_up);
  pulldown g_down (p_down);

  initial begin
    #1;
    $display("gates: and=%b nand=%b or=%b nor=%b xor=%b xnor=%b and3=%b", y_and, y_nand, y_or,
             y_nor, y_xor, y_xnor, y_and3);
    $display("buffers: buf=%b%b not=%b buf(z)=%b", b1, b2, y_not, y_bufz);
    $display("three-state: bufif1 on=%b off=%b bufif0 on=%b notif1 on=%b notif0 off=%b",
             t_bufif1_on, t_bufif1_off, t_bufif0_on, t_notif1_on, t_notif0_off);
    $display("mos: nmos on=%b off=%b pmos on=%b off=%b rnmos on=%b", m_nmos_on, m_nmos_off,
             m_pmos_on, m_pmos_off, m_rnmos_on);
    $display("cmos: n on=%b p on=%b off=%b", c_n_on, c_p_on, c_off);
    $display("bidirectional: tran=%b tranif1 off=%b tranif0 on=%b", s_b, s_d, s_f);
    $display("pull: pullup=%b pulldown=%b", p_up, p_down);
  end
endmodule
