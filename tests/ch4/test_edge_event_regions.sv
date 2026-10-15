/*
:name: test_edge_event_regions
:description: Blocking, nonblocking and #0 updates seen from Active, Inactive and NBA regions, and $strobe
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.2 4.4.2.3 4.4.2.4 21.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_edge_event_regions.expected
*/
module test_edge_event_regions;
  timeunit 1ns/1ps;
  logic a = 0;

  initial begin
    // Active region: assignments happen immediately
    a = 0;
    if (a !== 0) $fatal(1, "initial assignment should be visible immediately");

    // Schedule NBA update
    a <= 1;
    if (a !== 0) $fatal(1, "NBA update must not be visible before #0");

    // Generate diagnostic output (strobe should see 1)
    $display("T%0t display-before a=%0d", $time, a);
    $strobe("T%0t strobe-end   a=%0d", $time, a);

    // Inactive region, which executes BEFORE the NBA region. The NBA update is
    // therefore NOT yet visible immediately after #0.
    #0;
    if (a !== 0) $fatal(1, "NBA update must NOT be visible after #0 (Inactive precedes NBA)");

    // Advancing time runs the NBA region of time 0; the update is now visible.
    #1;
    if (a !== 1) $fatal(1, "NBA update should be visible after the NBA region runs");

    $display("PASS: event region ordering verified");
    $finish;
  end
endmodule
