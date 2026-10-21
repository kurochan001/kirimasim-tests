/*
:name: test_timeunit_repeated_matching
:description: A timeunit or timeprecision declaration can be repeated later in its time scope when it matches the first one (IEEE 1800-2023 Section 3.14.2.2)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.2 3.14.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_repeated_matching.expected
*/
// IEEE 1800-2023 §3.14.2.2: timeunit and timeprecision come before the other
// items of their time scope, and they can be repeated as later items as long
// as they match the first declarations. The module keeps a unit of 1 ns and a
// precision of 100 ps, so a delay of 1.25 is rounded to 1.3 ns (3.14.1) and
// $realtime then gives 1.3.

`timescale 1ns / 1ns

module test_timeunit_repeated_matching;
  timeunit 1ns;
  timeprecision 100ps;
  int n;
  timeunit 1ns;
  timeprecision 100ps;
  initial begin
    #1.25;
    $display("$realtime=%0.2f", $realtime);
  end
endmodule
