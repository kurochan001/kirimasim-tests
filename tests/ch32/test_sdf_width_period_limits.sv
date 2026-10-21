/*
:name: test_sdf_width_period_limits
:description: WIDTH and PERIOD entries in the TIMINGCHECK section of an SDF file set the limits of the matching $width and $period checks (IEEE 1800-2023 Section 32.4.2)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.2 31.4.4 31.4.5 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_width_period_limits.expected
*/
// IEEE 1800-2023 §32.4.2, Table 32-2: (WIDTH v1) annotates v1 as the limit of
// $width, and (PERIOD v1) as the limit of $period. The checks of the cell have
// limits 2 and 4; the SDF file raises them to 6 and 12. So the high pulse of
// width 5 that ends at 15 violates $width (31.4.4), and the rising edges at 10
// and 20 violate $period (31.4.5), while the later pulse of width 7 and
// period 15 do not. §31.6: each violation toggles the notifier, and the test
// prints the notifiers when they change.
// Icarus Verilog 13.0 skips timing checks (docs/simulator-differences.md).

`timescale 1ns/1ns

module sdf_width_period_cell(input clk);
  reg nw = 0, np = 0;
  specify
    $width(posedge clk, 2, 0, nw);
    $period(posedge clk, 4, np);
  endspecify
endmodule

module test_sdf_width_period_limits;
  reg clk = 0;
  integer f;

  sdf_width_period_cell u(clk);

  initial begin
    f = $fopen("test_sdf_width_period_limits.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_width_period_cell\") (INSTANCE u)");
    $fdisplay(f, "    (TIMINGCHECK");
    $fdisplay(f, "      (WIDTH (posedge clk) (6))");
    $fdisplay(f, "      (PERIOD (posedge clk) (12)))))");
    $fclose(f);
    $sdf_annotate("test_sdf_width_period_limits.sdf");
    #10 clk = 1;   // 10
    #5 clk = 0;    // 15: width 5
    #5 clk = 1;    // 20: period 10
    #7 clk = 0;    // 27: width 7
    #8 clk = 1;    // 35: period 15
    #10 $finish;
  end

  always @(u.nw or u.np) $display("%0d: nw=%b np=%b", $time, u.nw, u.np);
endmodule
