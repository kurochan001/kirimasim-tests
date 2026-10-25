/*
:name: test_syntax_resistive_mos_switches
:description: rnmos, rpmos and rcmos switches conduct like nmos, pmos and cmos and reduce supply and strong to pull and pull to weak (IEEE 1800-2023 Section 28.7)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.7 28.9 28.14 A.3.1 A.3.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_syntax_resistive_mos_switches.expected
*/
// IEEE 1800-2023 §28.7, A.3.4: rnmos and rpmos are the resistive forms of
// nmos and pmos (conducting when the control is 1 and 0); §28.9: rcmos is the
// resistive form of cmos (conducting when the n-control is 1 or the
// p-control is 0). §28.14, Table 28-8: the resistive switches reduce a supply
// or strong drive to pull and a pull drive to weak. Each switch here has
// instances whose data input is a strong variable, a pull-driven net and a
// supply1 net, and the outputs are printed with %v.
//
// Icarus Verilog 13.0 gives the outputs of rnmos, rpmos and rcmos strong
// strength whatever the strength of their data input (St1 for a strong, pull
// or supply 1); the standard requires the reductions of Table 28-8 shown in
// the expected output.

`timescale 1ns/1ns

module test_syntax_resistive_mos_switches;
  reg dv, c, nc, pc;
  wire pd;
  supply1 vdd;
  wire r1, r2, r3, p1, p2, rc1, rc2, rc3;

  assign (pull0, pull1) pd = dv;

  rnmos g_rn (r1, dv, c), (r2, pd, c), (r3, vdd, c);
  rpmos g_rp (p1, dv, c), (p2, pd, c);
  rcmos g_rc (rc1, dv, nc, pc), (rc2, pd, nc, pc), (rc3, vdd, nc, pc);

  task mos;
    $display("dv=%b c=%b rnmos=%v %v %v rpmos=%v %v", dv, c, r1, r2, r3, p1, p2);
  endtask

  task cm;
    $display("dv=%b nc=%b pc=%b rcmos=%v %v %v", dv, nc, pc, rc1, rc2, rc3);
  endtask

  initial begin
    dv = 1; c = 1; nc = 0; pc = 1;
    #1 mos;
    c = 0;
    #1 mos;
    dv = 0;
    #1 mos;
    cm;
    nc = 1;
    #1 cm;
    dv = 1; nc = 0; pc = 0;
    #1 cm;
  end
endmodule
