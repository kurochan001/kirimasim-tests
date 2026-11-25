/*
:name: test_vpi_action_error_callback_information
:description: Runtime error actions deliver the callback reason and let the application retrieve error information
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.3 38.2 20.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_action_error_callback_information.c
:expected_stdout: @test_vpi_action_error_callback_information.expected
*/
// The callback calls vpi_chk_error before any other VPI routine.
// These two errors occur at different times, with a warning between them.
`timescale 1ns/1ns
module test_vpi_action_error_callback_information;
  initial begin
    #1 $error("first run-time error");
    #1 $warning("warning between the two errors");
    #1 $error("second run-time error");
    #1 $display("design completed");
  end
endmodule
