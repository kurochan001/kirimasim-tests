/*
:name: test_sdf_recrem_limits
:description: A RECREM entry of an SDF file sets the recovery and removal limits of the matching $recrem check (IEEE 1800-2023 Section 32.4.2)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.2 31.3.6 31.3.4 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_recrem_limits.expected
*/
// IEEE 1800-2023 §32.4.2, Table 32-2: (RECREM d (posedge clk) (4) (3))
// sets the recovery limit 4 and the removal limit 3 of $recrem and also
// annotates $recovery and $removal for the same events. §31.3.6: the reference
// event is the asynchronous control d and the data event is posedge clk. d
// changes at 7, three before the edge at 10, a recovery violation at 10, and
// at 12, two after the edge, a removal violation at 12. §31.6: each toggles
// its notifier, so nrec goes 1 then 0. The separate $removal check gets the
// same removal limit 3, so its notifier nrem also changes at 12. Icarus
// Verilog 13.0 supports neither timing checks nor the TIMINGCHECK section;
// The 5.052 release ignores both and $sdf_annotate.

`timescale 1ns/1ns

module sdf_recrem_cell(input clk, input d);
  reg nrec = 0, nrem = 0;
  specify
    $recrem(d, posedge clk, 1, 1, nrec);
    $removal(d, posedge clk, 1, nrem);
  endspecify
endmodule

module test_sdf_recrem_limits;
  reg clk = 0, d = 0;
  integer f;

  sdf_recrem_cell u(clk, d);

  always @(u.nrec or u.nrem)
    $display("%0d: recrem=%b removal=%b", $time, u.nrec, u.nrem);

  initial begin
    f = $fopen("test_sdf_recrem_limits.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_recrem_cell\") (INSTANCE u)");
    $fdisplay(f, "    (TIMINGCHECK");
    $fdisplay(f, "      (RECREM d (posedge clk) (4) (3)))))");
    $fclose(f);
    $sdf_annotate("test_sdf_recrem_limits.sdf");
    #7 d = 1;       // 7: in the recovery window; the edge at 10 reports it
    #3 clk = 1;     // 10: recovery violation
    #2 d = 0;       // 12: 2 after the edge, a removal violation
    #8 clk = 0;     // 20
    #5 $display("end: recrem=%b removal=%b", u.nrec, u.nrem);
    $finish;
  end
endmodule
