/*
:name: test_vpi_time_callback_rejects_zero_delay_start_after_entering_time_slice
:description: A zero-delay start-of-time callback is rejected after entering the slice and allowed inside another start callback
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.2 38.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +time_late_start
:vpi_c: @vpi_time_registration_boundaries.c
:expected_stdout: @test_vpi_time_callback_rejects_zero_delay_start_after_entering_time_slice.expected
:expected_stderr_regex: (?m)^late start rejected=1 vpi-error=1$
*/
`timescale 1ps/1ps
module test_vpi_time_callback_rejects_zero_delay_start_after_entering_time_slice;
  initial begin
    #3 $display("active t=%0d", $time);
    #4 $display("fixture t=%0d", $time);
    $finish(0);
  end
endmodule
