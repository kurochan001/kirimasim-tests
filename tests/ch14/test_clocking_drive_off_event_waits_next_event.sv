/*
:name: test_clocking_drive_off_event_waits_next_event
:description: A synchronous drive executed between clocking events does not block and evaluates its right-hand side at once, but drives only as if it had been executed at the next clocking event (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_drive_off_event_waits_next_event.expected
*/
// IEEE 1800-2023 §14.16: a drive statement can execute at a time that is
// not that of a clocking event. It does not block and its right-hand side
// is evaluated immediately, but the drive is processed as if it had been
// executed at the next clocking event.
//
// The posedges are at 5, 15, 25. At 8, r = 3, then cb.v <= r, then r = 9.
// The process is still at 8 after the drive. At 14, after the time of the
// drive and before the next clocking event, v has not changed; at 16 it
// has the captured 3, driven at 15 (zero output skew), and not the later
// value 9 of r.

`timescale 1ns/1ns

module test_clocking_drive_off_event_waits_next_event;
  logic clk = 0;
  int v = 0;
  int r;

  always #5 clk = ~clk;

  default clocking cb @(posedge clk);
    output v;
  endclocking

  initial begin
    #8;
    r = 3;
    cb.v <= r;
    $display("t=%0t after the drive", $time);
    r = 9;
    #6 $display("t=%0t v=%0d", $time, v);
    #2 $display("t=%0t v=%0d", $time, v);
    #10 $display("t=%0t v=%0d", $time, v);
    $finish;
  end
endmodule
