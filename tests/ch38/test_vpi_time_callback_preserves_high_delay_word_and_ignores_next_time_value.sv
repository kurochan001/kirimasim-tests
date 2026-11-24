/*
:name: test_vpi_time_callback_preserves_high_delay_word_and_ignores_next_time_value
:description: A callback retains the high word of its delay and a next-time callback ignores its supplied time value
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.2 38.13
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +time_high_word
:vpi_c: @vpi_time_registration_boundaries.c
:expected_stdout: @test_vpi_time_callback_preserves_high_delay_word_and_ignores_next_time_value.expected
*/
`timescale 1ps/1ps
module test_vpi_time_callback_preserves_high_delay_word_and_ignores_next_time_value;
  initial begin
    #4 $display("fixture t=%0d", $time);
    #(64'd4294967321) $display("fixture t=%0d", $time);
    $finish(0);
  end
endmodule
