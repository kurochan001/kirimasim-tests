/*
:name: test_syntax_mos_cmos_switches
:description: nmos, pmos and cmos switches declared with and without three delays, with several named and unnamed instances in the terminal orders output, data, control and output, data, n-control, p-control (IEEE 1800-2023 Section 28.7)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.7 28.9 28.13 28.16 A.3.1 A.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_syntax_mos_cmos_switches.expected
*/
// IEEE 1800-2023 §28.7, A.3.1, A.3.4: a MOS switch declaration has up to
// three delays and one or more instances; an instance has an optional name
// and the terminals output, data, control. nmos conducts when the control is
// 1, pmos when it is 0, and an open switch outputs z. §28.9: cmos has the
// terminals output, data, n-channel control, p-channel control, and conducts
// when the n-control is 1 or the p-control is 0. §28.13: these switches pass
// a pull strength unchanged and reduce a supply strength to strong. §28.16:
// three delays are the rise, fall and turn-off delays. The resistive
// switches are in test_syntax_resistive_mos_switches.
//
// The data comes from a net driven with pull strength or from a supply1 net,
// and the outputs are printed with %v for each control value, so a wrong
// control polarity or swapped n- and p-controls change a line. An nmos and a
// cmos declaration with #(2, 4, 6) and #(4, 6, 8) and two instances each are
// printed between the delays of each transition.

`timescale 1ns/1ns

module test_syntax_mos_cmos_switches;
  reg dv, c, nc, pc, td, tc, tpc;
  wire pd;
  supply1 vdd;
  wire m_n, m_n2, m_p, m_s, c1, c2, c3;
  wire dn1, dn2, dc1, dc2;

  assign (pull0, pull1) pd = dv;

  nmos  g_n (m_n, pd, c), (m_n2, pd, c);
  pmos  (m_p, pd, c);
  pmos  g_s (m_s, vdd, c);
  cmos  g_c (c1, pd, nc, pc), (c2, pd, nc, pc);
  cmos  (c3, vdd, nc, pc);

  nmos #(2, 4, 6) g_dn (dn1, td, tc), (dn2, td, tc);
  cmos #(4, 6, 8) g_dc (dc1, td, tc, tpc), (dc2, td, tc, tpc);

  task mos;
    $display("dv=%b c=%b nmos=%v %v pmos=%v pmos_vdd=%v", dv, c, m_n, m_n2, m_p, m_s);
  endtask

  task cm;
    $display("dv=%b nc=%b pc=%b cmos=%v %v cmos_vdd=%v", dv, nc, pc, c1, c2, c3);
  endtask

  task timed;
    $display("t=%0t nmos=%v %v cmos=%v %v", $time, dn1, dn2, dc1, dc2);
  endtask

  initial begin
    td = 0; tc = 1; tpc = 1;
    dv = 0; c = 1; nc = 0; pc = 1;
    #1 mos;
    dv = 1;
    #1 mos;
    c = 0;
    #1 mos;
    dv = 0;
    #1 mos;
    cm;
    nc = 1;
    #1 cm;
    nc = 0; pc = 0;
    #1 cm;
    dv = 1; nc = 1;
    #1 cm;
    #3 timed;        // t=10
    td = 1;          // nmos rises at 12, cmos at 14
    #1 timed;        // t=11
    #2 timed;        // t=13
    #2 timed;        // t=15
    tc = 0;          // nmos turns off at 21, cmos at 23
    #5 timed;        // t=20
    #2 timed;        // t=22
    #2 timed;        // t=24
    tc = 1;          // nmos rises at 26, cmos at 28
    #3 timed;        // t=27
    #2 timed;        // t=29
    #1 td = 0;       // t=30: nmos falls at 34, cmos at 36
    #3 timed;        // t=33
    #2 timed;        // t=35
    #2 timed;        // t=37
  end
endmodule
