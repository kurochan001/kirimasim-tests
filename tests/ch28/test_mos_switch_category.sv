/*
:name: test_mos_switch_category
:description: nmos, pmos, rnmos, rpmos, cmos and rcmos are MOS switches that pass their data input to their output while their control turns them on and drive z while it is off (IEEE 1800-2023 Section 28.3.1)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.1 28.7 28.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_mos_switch_category.expected
*/
// IEEE 1800-2023 §28.3.1, Table 28-1: cmos, nmos, pmos, rcmos, rnmos and rpmos
// are the MOS switches. §28.7: nmos, pmos, rnmos and rpmos have an output, a
// data input and a control input, in that order; nmos and rnmos conduct
// while their control is 1, pmos and rpmos while it is 0, and the output is
// z while the switch is off. §28.9: cmos and rcmos have an output, a data
// input, an n-channel control and a p-channel control, in that order, and
// conduct while the n-channel control is 1 or the p-channel control is 0.
// Each switch drives a net of its own. The four steps turn every switch on
// and off with each data value; the first and last steps have the n-channel
// control at 0 and the p-channel control at 1, so cmos and rcmos are off
// only if their third and fourth terminals are taken in that order.

module test_mos_switch_category;
  logic d, c, nc, pc;
  wire o_nmos, o_pmos, o_rnmos, o_rpmos, o_cmos, o_rcmos;

  nmos  m1 (o_nmos, d, c);
  pmos  m2 (o_pmos, d, c);
  rnmos m3 (o_rnmos, d, c);
  rpmos m4 (o_rpmos, d, c);
  cmos  m5 (o_cmos, d, nc, pc);
  rcmos m6 (o_rcmos, d, nc, pc);

  task automatic show;
    $display("d=%b c=%b nc=%b pc=%b: nmos=%b pmos=%b rnmos=%b rpmos=%b cmos=%b rcmos=%b",
             d, c, nc, pc, o_nmos, o_pmos, o_rnmos, o_rpmos, o_cmos, o_rcmos);
  endtask

  initial begin
    d = 1; c = 1; nc = 0; pc = 1;
    #1 show;
    d = 0; c = 0; nc = 1; pc = 1;
    #1 show;
    d = 1; c = 0; nc = 0; pc = 0;
    #1 show;
    d = 0; c = 1; nc = 0; pc = 1;
    #1 show;
  end
endmodule
