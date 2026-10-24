/*
:name: test_rcmos_switch_rnmos_rpmos_equivalence
:description: an rcmos switch drives what an rnmos and an rpmos switch with the same data input and output and its two controls drive together, with the strength reduced to pull, for all 64 values of data and controls (IEEE 1800-2023 Section 28.9)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.9 28.7 28.14 28.12.2 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_rcmos_switch_rnmos_rpmos_equivalence.expected
*/
// IEEE 1800-2023 §28.9: the terminals of an rcmos switch are its output,
// its data input, its n-channel control and its p-channel control, in this
// order, and the switch is treated as an rnmos switch and an rpmos switch
// that share the data input and the output and have separate controls
// (Table 28-6 in 28.7). All three are resistive and reduce the strong data
// to pull (Table 28-8 in 28.14). The output of the rcmos switch sw and the
// net pair, driven by an rnmos with the n-channel control and an rpmos with
// the p-channel control, are shown with %v (21.2.1.4) for every value 0, 1,
// x and z of the data and of both controls. Both channels pass the same
// data, so their outputs combine on pair without a conflict of opposite
// values: a channel that is on and one that may be on (L or H) give the
// known value, and two that may be on give L or H (28.12.2).
// Icarus Verilog 13.0 passes the strong strength through rcmos and rpmos,
// and Verilator 5.052 does not support these switches.

module test_rcmos_switch_rnmos_rpmos_equivalence;
  logic data, nctrl, pctrl;
  wire sw, pair;

  rcmos g_rcmos(sw, data, nctrl, pctrl);
  rnmos g_rnmos(pair, data, nctrl);
  rpmos g_rpmos(pair, data, pctrl);

  logic vals[4] = '{1'b0, 1'b1, 1'bx, 1'bz};

  initial begin
    for (int i = 0; i < 4; i++)
      for (int j = 0; j < 4; j++)
        for (int k = 0; k < 4; k++) begin
          data = vals[i];
          nctrl = vals[j];
          pctrl = vals[k];
          #1 $display("data=%b n=%b p=%b: rcmos=%v rnmos+rpmos=%v", data, nctrl, pctrl, sw, pair);
        end
  end
endmodule
