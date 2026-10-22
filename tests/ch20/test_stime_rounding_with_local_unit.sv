/*
:name: test_stime_rounding_with_local_unit
:description: Stime is a 32 bit time value rounded in the calling scope time unit (IEEE 1800-2023 Section 20.3.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stime_rounding_with_local_unit.expected
*/
// IEEE 1800-2023 20.3.2: A fractional delay rounds the returned time to the
// nearest integer local unit; realtime retains the fractional part.

`timescale 10ns/1ns
module test_stime_rounding_with_local_unit;
  initial begin
    #1.6 $display("stime=%0d bits=%0d realtime=%0.1f", $stime, $bits($stime), $realtime);
  end
endmodule
