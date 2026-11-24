/*
:name: test_vpi_readonly_callback_cannot_reschedule_current_timestep
:description: A read only callback cannot schedule a read write synchronization callback in the same timestep
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_readonly_callback_cannot_reschedule_current_timestep.expected
:vpi_c: @test_vpi_readonly_callback_cannot_reschedule_current_timestep.c
*/
`timescale 1ns/1ns
module test_vpi_readonly_callback_cannot_reschedule_current_timestep;
  logic sample;
  initial begin
    sample = 0;
    #2 sample = 1;
    #1 $display("sample=%b", sample);
  end
endmodule
