/*
:name: test_sdf_timing_check_limits
:description: SETUPHOLD in the TIMINGCHECK section sets the limits of the matching $setup and $hold checks, and checks of other signals keep theirs (IEEE 1800-2023 Section 32.4.2)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.2 31.3.1 31.3.2 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_timing_check_limits.expected
*/
// IEEE 1800-2023 §32.4.2, Table 32-2: (SETUPHOLD d (posedge clk) v1 v2)
// annotates v1 to $setup and v2 to $hold for data d and reference posedge clk.
// The limits of 1 become 4 and 3: d changes 3 before the edge at 20 (a setup
// violation, 31.3.1) and 2 after it (a hold violation, 31.3.2). The setup check
// of e is not in the file and keeps its limit of 1, so e changing 3 before the
// edge at 40 is not a violation. §31.6: a violation toggles the notifier, which
// starts at 0. Icarus Verilog 13.0 supports neither timing checks nor the
// TIMINGCHECK section; Verilator 5.052 ignores both and $sdf_annotate.

`timescale 1ns/1ns

module sdf_tchk_cell(input clk, input d, input e);
  reg nsd = 0, nhd = 0, nse = 0;
  specify
    $setup(d, posedge clk, 1, nsd);
    $hold(posedge clk, d, 1, nhd);
    $setup(e, posedge clk, 1, nse);
  endspecify
endmodule

module test_sdf_timing_check_limits;
  reg clk = 0, d = 0, e = 0;
  integer f;

  sdf_tchk_cell u(clk, d, e);

  always @(u.nsd or u.nhd or u.nse)
    $display("%0d: setup d=%b hold d=%b setup e=%b", $time, u.nsd, u.nhd, u.nse);

  initial begin
    f = $fopen("test_sdf_timing_check_limits.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_tchk_cell\") (INSTANCE u)");
    $fdisplay(f, "    (TIMINGCHECK");
    $fdisplay(f, "      (SETUPHOLD d (posedge clk) (4) (3)))))");
    $fclose(f);
    $sdf_annotate("test_sdf_timing_check_limits.sdf");
    #17 d = 1;      // 17: 3 before the edge
    #3 clk = 1;     // 20
    #2 d = 0;       // 22: 2 after the edge
    #8 clk = 0;     // 30
    #7 e = 1;       // 37: 3 before the edge
    #3 clk = 1;     // 40
    #10 clk = 0;
    $display("end: setup d=%b hold d=%b setup e=%b", u.nsd, u.nhd, u.nse);
    $finish;
  end
endmodule
