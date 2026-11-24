/*
:name: test_vpi_time_callback_rejects_null_and_suppressed_time_fields
:description: Simulation time callback registration rejects null and suppressed time fields beside a valid structure
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.2 38.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +time_structure
:vpi_c: @vpi_time_registration_boundaries.c
:expected_stdout: @test_vpi_time_callback_rejects_null_and_suppressed_time_fields.expected
:expected_stderr_regex: (?m)^null time rejected=1 vpi-error=1$\nsuppressed time rejected=1 vpi-error=1$
*/
`timescale 1ps/1ps
module test_vpi_time_callback_rejects_null_and_suppressed_time_fields;
  initial begin
    #4 $display("fixture t=%0d", $time);
    $finish(0);
  end
endmodule
