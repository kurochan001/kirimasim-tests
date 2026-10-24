/*
:name: test_mos_switch_kinds_unidirectional
:description: the six MOS switches pass a signal only from their data input to their output, and the resistive ones rnmos, rpmos and rcmos reduce its strength (IEEE 1800-2023 Section 28.7)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.7 28.9 28.13 28.14 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_mos_switch_kinds_unidirectional.expected
*/
// IEEE 1800-2023 §28.7: the MOS switches are cmos and rcmos (28.9) and the
// unidirectional nmos, pmos, rnmos and rpmos, which, like the bufif gates,
// pass a signal from their data input to their output only; the r forms
// model resistive channels and reduce the strength of what passes (28.14),
// while the others keep it (28.13). Each switch below is on and has a bufif1
// driver on its data input net and one on its output net. First the input
// is driven to a strong 1 and the output driver is off: the output shows
// St1, or Pu1 through a resistive switch. Then the output is driven to a
// strong 0 and the input driver is off: the output shows St0 and the input
// stays z, as nothing flows back through the switch. %v (21.2.1.4) shows
// both nets.

module test_mos_switch_kinds_unidirectional;
  logic vi, ei, vo, eo;
  wire i_nmos, o_nmos;
  nmos g_nmos(o_nmos, i_nmos, 1'b1);
  bufif1 di_nmos(i_nmos, vi, ei), do_nmos(o_nmos, vo, eo);
  wire i_pmos, o_pmos;
  pmos g_pmos(o_pmos, i_pmos, 1'b0);
  bufif1 di_pmos(i_pmos, vi, ei), do_pmos(o_pmos, vo, eo);
  wire i_rnmos, o_rnmos;
  rnmos g_rnmos(o_rnmos, i_rnmos, 1'b1);
  bufif1 di_rnmos(i_rnmos, vi, ei), do_rnmos(o_rnmos, vo, eo);
  wire i_rpmos, o_rpmos;
  rpmos g_rpmos(o_rpmos, i_rpmos, 1'b0);
  bufif1 di_rpmos(i_rpmos, vi, ei), do_rpmos(o_rpmos, vo, eo);
  wire i_cmos, o_cmos;
  cmos g_cmos(o_cmos, i_cmos, 1'b1, 1'b0);
  bufif1 di_cmos(i_cmos, vi, ei), do_cmos(o_cmos, vo, eo);
  wire i_rcmos, o_rcmos;
  rcmos g_rcmos(o_rcmos, i_rcmos, 1'b1, 1'b0);
  bufif1 di_rcmos(i_rcmos, vi, ei), do_rcmos(o_rcmos, vo, eo);

  task show(string what);
    $display("%s nmos: in=%v out=%v", what, i_nmos, o_nmos);
    $display("%s pmos: in=%v out=%v", what, i_pmos, o_pmos);
    $display("%s rnmos: in=%v out=%v", what, i_rnmos, o_rnmos);
    $display("%s rpmos: in=%v out=%v", what, i_rpmos, o_rpmos);
    $display("%s cmos: in=%v out=%v", what, i_cmos, o_cmos);
    $display("%s rcmos: in=%v out=%v", what, i_rcmos, o_rcmos);
  endtask

  initial begin
    vi = 1'b1; ei = 1'b1; vo = 1'b0; eo = 1'b0;
    #1 show("in driven");
    ei = 1'b0; eo = 1'b1;
    #1 show("out driven");
  end
endmodule
