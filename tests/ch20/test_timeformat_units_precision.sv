/*
:name: test_timeformat_units_precision
:description: $timeformat sets the unit, the number of fractional digits and the suffix that %t uses (IEEE 1800-2023 Section 20.4.3)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.4.3 21.2.1.3 3.14.2.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeformat_units_precision.expected
*/
// IEEE 1800-2023 §20.4.3: $timeformat(units, precision, suffix, width) makes %t
// print times in the given unit (-9 for ns, -12 for ps, -6 for us), with the
// given number of digits after the decimal point and the suffix after the
// number. A minimum width of 0 adds no padding. The delay #12.3456 with a time
// precision of 1 ps waits 12.346 ns (3.14.2.1).

`timescale 1ns/1ps

module test_timeformat_units_precision;
  initial begin
    #12.3456;
    $timeformat(-9, 2, " ns", 0);
    $display("[%t]", $realtime);
    $timeformat(-12, 0, "ps", 0);
    $display("[%t]", $realtime);
    $timeformat(-6, 5, " us", 0);
    $display("[%t]", $realtime);
    $timeformat(-9, 3, "", 0);
    $display("[%t]", $realtime);
  end
endmodule
