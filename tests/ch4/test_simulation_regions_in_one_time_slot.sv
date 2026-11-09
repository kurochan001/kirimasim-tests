/*
:name: test_simulation_regions_in_one_time_slot
:description: One time slot runs its simulation regions in order: values sampled in the Preponed region, then the Active, Inactive and NBA regions, the Observed region where a sequence end point is recorded, the Reactive, Re-Inactive and Re-NBA regions, the active region set again, and the Postponed region last (IEEE 1800-2023 Section 4.4.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2 4.4 4.5 4.4.2.1 4.4.2.5 16.13.6 24.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_simulation_regions_in_one_time_slot.expected
*/
// IEEE 1800-2023 §4.4.2: the simulation regions of a time slot are Preponed,
// Active, Inactive, NBA, Observed, Reactive, Re-Inactive, Re-NBA and
// Postponed, and §4.4 and §4.5 give their order and how the scheduler loops
// over them. Every region leaves a mark in the output at time 1:
// - Preponed (4.4.2.1, 16.5.1): the assertion a1 uses the value v had before
//   the time slot, so $sampled(v) is 0 in its action block.
// - Active: the initial procedure prints v=0, sets v = 1, schedules v <= 2
//   and raises clk, the clock of a1 and of the sequence s.
// - Inactive (4.4.2.3): after #0 it sees v=1, as the NBA update is pending.
// - NBA (4.4.2.4): the update to 2 wakes the always procedure, which prints.
// - Observed (4.4.2.5, 16.13.6): s ends at the edge, and its triggered state
//   is set in the Observed region, so it reads 0 in the active region set
//   above and 1 in the reactive region set below; a1 is evaluated there and
//   its pass action is scheduled in the Reactive region.
// - Reactive (4.4.2.6, 24.3.1): the action of a1 prints and sets go, which
//   wakes the program process waiting for go, also in the Reactive region.
// - Re-Inactive (4.4.2.7): the program's #0 resumes it with p still 0.
// - Re-NBA (4.4.2.8): the program's p <= 1 updates p, which wakes a second
//   program process and a module process. The program process runs first
//   and sees back=0, since the reactive region set is emptied before the
//   scheduler returns to the Active region (4.5), where the module process
//   then sets back = 1.
// - Postponed (4.4.2.9): $strobe prints the final values of the slot.
// The design prints nothing else at time 1, so the order of the lines is the
// order of the regions. The second program process waits once more so that
// the end of the program does not stop the simulation inside the slot
// (24.3).
// Icarus Verilog 13.0 does not support sequence declarations and concurrent
// assertions, and the release 5.052 of Verilator has no triggered method
// for a sequence in procedural code.

module test_simulation_regions_in_one_time_slot;
  logic clk = 0;
  int v = 0, go = 0, p = 0, back = 0;

  sequence s;
    @(posedge clk) 1'b1;
  endsequence

  initial begin
    #1;
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

  initial #1 $strobe("Postponed: v=%0d p=%0d back=%0d", v, p, back);

  regions_prog prg();
endmodule

program regions_prog;
  initial begin
    @(test_simulation_regions_in_one_time_slot.go);
    $display("Reactive (program): go=%0d", test_simulation_regions_in_one_time_slot.go);
    #0 $display("Re-Inactive: p=%0d", test_simulation_regions_in_one_time_slot.p);
    test_simulation_regions_in_one_time_slot.p <= 1;
  end

  initial begin
    @(test_simulation_regions_in_one_time_slot.p);
    $display("Re-NBA: p=%0d back=%0d", test_simulation_regions_in_one_time_slot.p,
             test_simulation_regions_in_one_time_slot.back);
    #5;
  end
endprogram
