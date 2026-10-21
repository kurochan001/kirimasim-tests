/*
:name: test_delay_time_unit_suffix
:description: A delay may carry its own time unit, which is converted to the time unit and precision of the scope, independent of `timescale (IEEE 1800-2023 Sections 3.14.1, 5.8)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.1 5.8 20.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_delay_time_unit_suffix.expected
*/
// IEEE 1800-2023 §5.8: a time literal has a number with a time unit, such as
// 2ns or 1500ps, and §3.14.1: a delay with such a literal is that amount of
// time, whatever the time unit of its scope, rounded to the time precision
// of the scope. The module has a unit of 1ns and a precision of 100ps, so
// #2ns, #1500ps and #0.25us end at 2.0, 3.5 and 253.5, and #160ps rounds to
// 200ps, ending at 253.7. §20.3.3: $realtime reports the times in ns.

`timescale 1ns / 100ps

module test_delay_time_unit_suffix;
  initial begin
    #2ns $display("%0.1f", $realtime);
    #1500ps $display("%0.1f", $realtime);
    #0.25us $display("%0.1f", $realtime);
    #160ps $display("%0.1f", $realtime);
  end
endmodule
