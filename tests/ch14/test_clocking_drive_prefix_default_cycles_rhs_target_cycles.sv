/*
:name: test_clocking_drive_prefix_default_cycles_rhs_target_cycles
:description: A cycle delay written before a synchronous drive blocks for cycles of the default clocking, while a cycle delay on the right-hand side of the drive counts cycles of the clocking block of the driven clockvar (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16 14.11 14.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_drive_prefix_default_cycles_rhs_target_cycles.expected
*/
// IEEE 1800-2023 §14.16: a procedural cycle delay used as a prefix of a
// synchronous drive blocks for its number of cycles of the default clocking,
// as before any other statement (14.11, 14.12). A cycle delay on the
// right-hand side postpones the update by cycles of the clocking block of
// the target clockvar.
//
// The default clocking dc is clocked by fast (posedges at 2, 4, 6, ...),
// and the clocking block sc, which has the output s, by slow (posedges at
// 5, 15, 25, 35). From the event of sc at 5, ##2 sc.s <= 1 waits two dc
// cycles, until 8, and then drives between sc events, so s changes at the
// next sc event, 15. At the sc event at 25, sc.s <= ##1 0 changes s one sc
// cycle later, at 35, not at the next dc event. A separate process shows s
// at fixed times.

`timescale 1ns/1ns

module test_clocking_drive_prefix_default_cycles_rhs_target_cycles;
  logic fast = 1;
  logic slow = 0;
  logic s = 0;
  int t_drive = -1;

  always #1 fast = ~fast;
  always #5 slow = ~slow;

  default clocking dc @(posedge fast);
  endclocking

  clocking sc @(posedge slow);
    output s;
  endclocking

  initial begin
    @(sc);
    ##2 sc.s <= 1'b1;
    t_drive = $time;
    @(sc);
    @(sc);
    sc.s <= ##1 1'b0;
  end

  initial begin
    #14 $display("t=%0t s=%b (drive executed at %0d)", $time, s, t_drive);
    #2 $display("t=%0t s=%b", $time, s);
    #12 $display("t=%0t s=%b", $time, s);
    #6 $display("t=%0t s=%b", $time, s);
    #2 $display("t=%0t s=%b", $time, s);
    $finish;
  end
endmodule
