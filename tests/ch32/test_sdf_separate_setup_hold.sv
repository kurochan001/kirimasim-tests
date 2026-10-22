/*
:name: test_sdf_separate_setup_hold
:description: SETUP and HOLD entries of an SDF file set the limits of the matching $setup and $hold checks separately (IEEE 1800-2023 Section 32.4.2)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.2 31.3.1 31.3.2 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_separate_setup_hold.expected
*/
// IEEE 1800-2023 §32.4.2, Table 32-2: (SETUP d (posedge clk) (4)) sets the
// limit of $setup for data d and the reference posedge clk, and (HOLD d
// (posedge clk) (5)) sets that of $hold. The specify limits are 1. d changes
// 3 before the edge at 10, so the data event at 7 is in the setup window and
// the reference event at 10 reports the violation (31.3.1); d changes 2 after
// the edge, a hold violation at 12 (31.3.2). §31.6: each violation toggles its
// notifier. The setup violation leaves the hold notifier alone, and the hold
// violation leaves the setup notifier alone. Icarus Verilog 13.0 supports
// neither timing checks nor the TIMINGCHECK section; Verilator 5.052 ignores
// both and $sdf_annotate.

`timescale 1ns/1ns

module sdf_sh_cell(input clk, input d);
  reg ns = 0, nh = 0;
  specify
    $setup(d, posedge clk, 1, ns);
    $hold(posedge clk, d, 1, nh);
  endspecify
endmodule

module test_sdf_separate_setup_hold;
  reg clk = 0, d = 0;
  integer f;

  sdf_sh_cell u(clk, d);

  always @(u.ns or u.nh)
    $display("%0d: setup=%b hold=%b", $time, u.ns, u.nh);

  initial begin
    f = $fopen("test_sdf_separate_setup_hold.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_sh_cell\") (INSTANCE u)");
    $fdisplay(f, "    (TIMINGCHECK");
    $fdisplay(f, "      (SETUP d (posedge clk) (4))");
    $fdisplay(f, "      (HOLD d (posedge clk) (5)))))");
    $fclose(f);
    $sdf_annotate("test_sdf_separate_setup_hold.sdf");
    #7 d = 1;       // 7: in the setup window; the edge at 10 reports it
    #3 clk = 1;     // 10: setup violation
    #2 d = 0;       // 12: 2 after the edge, a hold violation
    #8 clk = 0;     // 20
    #5 $display("end: setup=%b hold=%b", u.ns, u.nh);
    $finish;
  end
endmodule
