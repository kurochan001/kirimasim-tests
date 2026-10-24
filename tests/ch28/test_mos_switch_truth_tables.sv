/*
:name: test_mos_switch_truth_tables
:description: nmos, rnmos, pmos and rpmos give the output of Table 28-6 for every data and control value 0, 1, x and z, the resistive ones with the strength reduced (IEEE 1800-2023 Section 28.7)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.7 28.14 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_mos_switch_truth_tables.expected
*/
// IEEE 1800-2023 §28.7: the MOS switches nmos, pmos, rnmos and rpmos take
// their output, data input and control input in this order. nmos and rnmos
// pass their data while the control is 1, pmos and rpmos while it is 0, and
// otherwise drive z (Table 28-6). A control that is x or z gives L (0 or z)
// for data 0 and H (1 or z) for data 1, data x gives x unless the switch is
// off, and data z always gives z. nmos and pmos keep the strong strength of
// the data variable, and rnmos and rpmos reduce it to pull (28.14). The four
// switches share one data and one control variable, each drives its own
// net, and every one of the 16 input pairs is shown with %v (21.2.1.4).
// Icarus Verilog 13.0 shows the outputs of rnmos and rpmos here with strong
// strength, and StX where Table 28-6 gives L or H; the standard requires
// pull strength and PuL and PuH.

module test_mos_switch_truth_tables;
  logic data, ctrl;
  wire o_nmos, o_rnmos, o_pmos, o_rpmos;

  nmos g_nmos(o_nmos, data, ctrl);
  rnmos g_rnmos(o_rnmos, data, ctrl);
  pmos g_pmos(o_pmos, data, ctrl);
  rpmos g_rpmos(o_rpmos, data, ctrl);

  logic vals[4] = '{1'b0, 1'b1, 1'bx, 1'bz};

  initial begin
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        data = vals[i];
        ctrl = vals[j];
        #1 $display("data=%b ctrl=%b: nmos=%v rnmos=%v pmos=%v rpmos=%v",
                    data, ctrl, o_nmos, o_rnmos, o_pmos, o_rpmos);
      end
    end
  end
endmodule
