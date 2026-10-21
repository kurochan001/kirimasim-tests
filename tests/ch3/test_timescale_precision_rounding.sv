/*
:name: test_timescale_precision_rounding
:description: A `timescale with a unit of 10ns and a precision of 1ns rounds delays to a tenth of its unit, and $realtime reports them in that unit (IEEE 1800-2023 Sections 3.14.1, 3.14.2.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.1 3.14.2.1 20.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timescale_precision_rounding.expected
*/
// IEEE 1800-2023 §3.14.2.1: a `timescale directive gives the design elements
// after it a time unit of 10ns and a time precision of 1ns. §3.14.1: each
// delay is rounded to that precision, one tenth of the unit, before it is
// scheduled. #1.26 is 1.3 units, 13ns, and #2.66 is 2.7 units, so the second
// delay ends at 4.0 units, 40ns. §20.3.3: $realtime reports those times in
// the time unit of the module, 1.3 and 4.0.

`timescale 10ns / 1ns

module test_timescale_precision_rounding;
  initial begin
    #1.26 $display("%0.1f", $realtime);
    #2.66 $display("%0.1f", $realtime);
  end
endmodule
