/*
:name: test_vpi_time_callback_rejects_zero_delay_read_write_registration_from_read_only
:description: Read-only synchronization rejects zero-delay read-write registration while a later read-write control runs
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.2 38.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +time_read_only
:vpi_c: @vpi_time_registration_boundaries.c
:expected_stdout: @test_vpi_time_callback_rejects_zero_delay_read_write_registration_from_read_only.expected
:expected_stderr_regex: (?m)^read-only write rejected=1 vpi-error=1$
*/
`timescale 1ps/1ps
module test_vpi_time_callback_rejects_zero_delay_read_write_registration_from_read_only;
  initial begin
    #9 $display("fixture t=%0d", $time);
    $finish(0);
  end
endmodule
