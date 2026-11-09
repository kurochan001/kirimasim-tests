/*
:name: test_pli_slot_entry_regions_run_once
:description: A time slot passes the Preponed and Pre-Active regions once, on entry, and does not pass them again when work created in the Pre-Postponed region makes it iterate over the Active to Pre-Postponed regions once more, while the Postponed region comes once, at the end (IEEE 1800-2023 Section 4.4.3.10)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.3.10 4.4.1 4.5 4.10 38.36.2 16.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_slot_entry_regions_run_once.c
:expected_stdout: @test_pli_slot_entry_regions_run_once.expected
*/
// IEEE 1800-2023 §4.4.3.10, Figure 4-1, and §4.5: a time slot runs the
// Preponed region and then the Pre-Active region once, and only then loops
// over the iterative regions, which §4.4.1 lists as Active through
// Pre-Postponed; Preponed, Pre-Active and Postponed are not among them, and
// the Postponed region runs once after the loop. §4.10, Table 4-1, and
// §38.36.2: cbAtStartOfSimTime and cbNextSimTime callbacks run in the
// Pre-Active region, cbAtEndOfSimTime in the Pre-Postponed region and
// cbReadOnlySynch in the Postponed region; a cbNextSimTime callback runs
// before the events of the next time slot. §16.5.1: a concurrent assertion
// uses the values sampled in the Preponed region of the slot.
// $vt_register, called at 0, registers cbAtStartOfSimTime, cbAtEndOfSimTime
// and cbReadOnlySynch callbacks for time 10. At 10:
// - Pre-Active: the cbAtStartOfSimTime callback sees v=0 and w=0.
// - Active: the design sets v = 1, and nothing else happens.
// - Pre-Postponed: the cbAtEndOfSimTime callback sees v=1, writes w = 1 and
//   registers a cbNextSimTime callback. The write is new work in the slot, so
//   the scheduler goes back to the Active region: the process waiting for w
//   raises clk, a1 is evaluated in the Observed region and its pass action
//   prints in the Reactive region. $sampled(v) is still 0, the value from
//   the Preponed region on entry; sampling again when the slot iterates
//   would give 1. The Pre-Active region is not passed again either, so the
//   cbNextSimTime callback waits for the slot at 20 instead of running at
//   10.
// - Postponed: the cbReadOnlySynch callback runs once, after the second
//   pass, and sees w=1 and clk=1.
// Icarus Verilog 13.0 does not support concurrent assertions, and the
// release 5.052 of Verilator does not support user-defined system tasks.

`timescale 1ns/1ns

module test_pli_slot_entry_regions_run_once;
  logic clk = 0;
  int v = 0, w = 0;

  always @(w) clk = 1;

  a1: assert property (@(posedge clk) v == 0)
        $display("a1 pass at %0t: sampled v=%0d, v=%0d", $time, $sampled(v), v);
      else
        $display("a1 fail at %0t: sampled v=%0d, v=%0d", $time, $sampled(v), v);

  initial begin
    $vt_register;
    #10 v = 1;
    #10 $display("design at 20: v=%0d w=%0d", v, w);
  end
endmodule
