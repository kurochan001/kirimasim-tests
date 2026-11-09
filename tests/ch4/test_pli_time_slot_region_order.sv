/*
:name: test_pli_time_slot_region_order
:description: The regions of one time slot come in their defined order, with the PLI regions between the simulation regions: Preponed, Pre-Active, Active, Inactive, Pre-NBA, NBA, Observed, Reactive, Re-Inactive, Re-NBA, the active region set again, Pre-Postponed and Postponed (IEEE 1800-2023 Section 4.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4 4.4.2 4.4.3 4.5 4.10 38.36.2 16.13.6 24.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_time_slot_region_order.c
:expected_stdout: @test_pli_time_slot_region_order.expected
*/
// IEEE 1800-2023 §4.4: a time slot is divided into ordered regions, from
// Preponed through Pre-Active, Active, Inactive, Pre-NBA, NBA, Post-NBA,
// Pre-Observed, Observed, Post-Observed, Reactive, Re-Inactive, Pre-Re-NBA,
// Re-NBA, Post-Re-NBA and Pre-Postponed to Postponed, and §4.5 loops over
// them. §4.10, Table 4-1, and §38.36.2: a cbAtStartOfSimTime callback runs in
// the Pre-Active region, cbNBASynch in the Pre-NBA region, cbAtEndOfSimTime
// in the Pre-Postponed region and cbReadOnlySynch in the Postponed region.
// $vt_register, called at 0, registers these four callbacks for time 10;
// each prints the values of the design. No callback reason is placed in
// Post-NBA alone or in Pre-Observed, Post-Observed, Pre-Re-NBA or
// Post-Re-NBA, so those five regions leave no mark.
// At 10, in region order:
// - Preponed (4.4.2.1, 16.5.1): a1 samples v=0, the value before the slot.
// - Pre-Active: the cbAtStartOfSimTime callback sees v=0.
// - Active: the initial procedure prints v=0, sets v = 1, schedules v <= 2,
//   raises clk (the clock of a1 and of the sequence s) and executes #0.
// - Inactive (4.4.2.3): it resumes and sees v=1.
// - Pre-NBA: the cbNBASynch callback sees v=1, before the update.
// - NBA: the update to 2 wakes the always procedure, which prints.
// - Observed (4.4.2.5, 16.13.6): s ends and its triggered state is set, so
//   it reads 0 in the lines above and 1 below; a1 passes and its action is
//   scheduled in the Reactive region.
// - Reactive (24.3.1): the action prints and sets go, which wakes the
//   program process waiting for go.
// - Re-Inactive: the program's #0 resumes it with p still 0.
// - Re-NBA: p <= 1 updates p; the program process woken by it runs first
//   (back=0), and the module process woken by it runs when the scheduler
//   comes back to the active region set (back=1).
// - Pre-Postponed: the cbAtEndOfSimTime callback sees the final values.
// - Postponed: the cbReadOnlySynch callback runs last.
// The design prints nothing else at 10, and the second program process
// waits once more so that the end of the program does not end the
// simulation inside the slot (24.3).
// Icarus Verilog 13.0 does not support concurrent assertions or cbNBASynch,
// and the release 5.052 of Verilator does not support user-defined system
// tasks.

`timescale 1ns/1ns

module test_pli_time_slot_region_order;
  logic clk = 0;
  int v = 0, go = 0, p = 0, back = 0;

  sequence s;
    @(posedge clk) 1'b1;
  endsequence

  initial begin
    $vt_register;
    #10;
    $display("Active: v=%0d", v);
    v = 1;
    v <= 2;
    clk = 1;
    #0 $display("Inactive: v=%0d triggered=%0d", v, s.triggered);
  end

  always @(v)
    if (v == 2) $display("NBA: v=%0d triggered=%0d", v, s.triggered);

  a1: assert property (@(posedge clk) v == 0)
        begin
          $display("Reactive (a1 action): sampled v=%0d, v=%0d, triggered=%0d",
                   $sampled(v), v, s.triggered);
          go = 1;
        end
      else $display("a1 failed");

  always @(p) begin
    back = p;
    $display("Active again: back=%0d", back);
  end

  order_prog prg();
endmodule

program order_prog;
  initial begin
    @(test_pli_time_slot_region_order.go);
    $display("Reactive (program): go=%0d", test_pli_time_slot_region_order.go);
    #0 $display("Re-Inactive: p=%0d", test_pli_time_slot_region_order.p);
    test_pli_time_slot_region_order.p <= 1;
  end

  initial begin
    @(test_pli_time_slot_region_order.p);
    $display("Re-NBA: p=%0d back=%0d", test_pli_time_slot_region_order.p,
             test_pli_time_slot_region_order.back);
    #10;
  end
endprogram
