/*
:name: test_time_value_rounding
:description: delays are rounded to the time precision of the design element that contains them, also when another element of the design has a finer precision (IEEE 1800-2023 Section 3.14.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.1 3.14.2.2 20.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_time_value_rounding.expected
*/
// IEEE 1800-2023 §3.14.1: the time precision of a design element says how its
// delay values are rounded: with a time unit of 1ns and a precision of 100ps,
// to one decimal place of a nanosecond, even though another element has a
// finer precision. §3.14.2.2: timeunit and timeprecision declare them.
// coarse waits 2.74, 0.04, 0.06 and a real variable holding 1.06, which are
// rounded to 2.7, 0, 0.1 and 1.1; fine, with a precision of 1ps, waits
// 2.7461, rounded to 2.746. Each prints $realtime (§20.3.3) in nanoseconds.

module coarse;
  timeunit 1ns;
  timeprecision 100ps;
  real d = 1.06;
  initial begin
    #2.74 $display("coarse: after #2.74, %.4f", $realtime);
    #0.04 $display("coarse: after #0.04, %.4f", $realtime);
    #0.06 $display("coarse: after #0.06, %.4f", $realtime);
    #d $display("coarse: after #d (1.06), %.4f", $realtime);
  end
endmodule

module fine;
  timeunit 1ns;
  timeprecision 1ps;
  initial begin
    #10;
    #2.7461 $display("fine: after #10 and #2.7461, %.4f", $realtime);
  end
endmodule

module test_time_value_rounding;
  timeunit 1ns;
  timeprecision 1ps;
  coarse c();
  fine f();
endmodule
