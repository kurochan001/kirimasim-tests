/*
:name: test_cmos_switch_nmos_pmos_equivalence
:description: a cmos switch drives what an nmos and a pmos switch with the same data input and output and its two controls drive together, for all 64 values of data, n-channel and p-channel control (IEEE 1800-2023 Section 28.9)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.9 28.7 28.12.2 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_cmos_switch_nmos_pmos_equivalence.expected
*/
// IEEE 1800-2023 §28.9: the terminals of a cmos switch are its output, its
// data input, its n-channel control and its p-channel control, in this
// order, and the switch is treated as an nmos switch and a pmos switch that
// share the data input and the output and have separate controls (Table
// 28-6 in 28.7). The output of the cmos switch sw and the net pair, driven
// by an nmos with the n-channel control and a pmos with the p-channel
// control, are shown with %v (21.2.1.4) for every value 0, 1, x and z of
// the data and of both controls. Both channels pass the same data, so their
// outputs combine on pair without a conflict of opposite values: a channel
// that is on and one that may be on (L or H) give the known value, and two
// that may be on give L or H (28.12.2).

module test_cmos_switch_nmos_pmos_equivalence;
  logic data, nctrl, pctrl;
  wire sw, pair;

  cmos g_cmos(sw, data, nctrl, pctrl);
  nmos g_nmos(pair, data, nctrl);
  pmos g_pmos(pair, data, pctrl);

  logic vals[4] = '{1'b0, 1'b1, 1'bx, 1'bz};

  initial begin
    for (int i = 0; i < 4; i++)
      for (int j = 0; j < 4; j++)
        for (int k = 0; k < 4; k++) begin
          data = vals[i];
          nctrl = vals[j];
          pctrl = vals[k];
          #1 $display("data=%b n=%b p=%b: cmos=%v nmos+pmos=%v", data, nctrl, pctrl, sw, pair);
        end
  end
endmodule
