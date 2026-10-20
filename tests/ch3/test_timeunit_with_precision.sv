/*
:name: test_timeunit_with_precision
:description: timeunit with a slash sets the time unit and the precision of a module at once, overriding `timescale, and delays are rounded to that precision (IEEE 1800-2023 Section 3.14.2.2)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.2 3.14.2.3 20.4.2 22.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_with_precision.expected
*/
// IEEE 1800-2023 §3.14.2.2: "timeunit 100ps / 10ps;" gives the module a time
// unit of 100ps and a precision of 10ps, which take precedence over the
// `timescale before it (3.14.2.3). #3 waits 300ps, and #0.26 is 26ps, rounded
// to 30ps, 0.3 units. $printtimescale shows the scale (20.4.2).

`timescale 1ns/1ns

module test_timeunit_with_precision;
  timeunit 100ps / 10ps;

  initial begin
    $printtimescale;
    #3 $display("time=%0d realtime=%0.1f", $time, $realtime);
    #0.26 $display("realtime=%0.1f", $realtime);
  end
endmodule
