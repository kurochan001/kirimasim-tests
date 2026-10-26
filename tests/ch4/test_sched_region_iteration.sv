/*
:name: test_sched_region_iteration
:description: a time slot runs Active, then Inactive, then NBA, and reaches Postponed only after the iterative work settles, with the next slot after Postponed (IEEE 1800-2023 4.3, 4.4, 4.4.1, 4.4.2, 4.4.3.10)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.3 4.4 4.4.1 4.4.2 4.4.3.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_region_iteration.expected
*/
// IEEE 1800-2023 §4.3 and §4.4: the events of one time slot are ordered by
// their regions, Active, Inactive, Pre-NBA, NBA, Post-NBA and the rest up to
// Postponed, and the scheduler iterates until no work remains before time
// advances. §4.4.1: the active-region set is Active, Inactive, Pre-NBA, NBA
// and Post-NBA. §4.4.2 lists the simulation regions. §4.4.3.10: Postponed is
// reached after the iterative work stabilizes and the next slot follows it.
// The test writes a with a blocking assignment, schedules a nonblocking
// update, prints before and after a #0, and registers $strobe. Both #0
// resumptions are in Inactive, before the NBA update, so a is still 0; the
// postponed $strobe then sees the NBA value 1, and time advances to the next
// slot only after that. A scheduler that applies NBA before Inactive, or that
// advances time before Postponed, prints a different line.

`timescale 1ns/1ps

module test_sched_region_iteration;
  logic a;

  initial begin
    a = 0;
    $display("t0 a=%0d", a);
    a <= 1;
    $display("active a=%0d", a);
    #0 $display("inactive1 a=%0d t=%0d", a, $time);
    #0 $display("inactive2 a=%0d t=%0d", a, $time);
    $strobe("strobe a=%0d t=%0d", a, $time);
    #1 $display("next a=%0d t=%0d", a, $time);
    $finish;
  end
endmodule
