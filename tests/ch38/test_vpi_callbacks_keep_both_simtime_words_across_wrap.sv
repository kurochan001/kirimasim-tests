/*
:name: test_vpi_callbacks_keep_both_simtime_words_across_wrap
:description: VPI timers and value-change callbacks preserve both simulated time words across two wrap boundaries
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.2 38.36.1 38.13 4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_callbacks_keep_both_simtime_words_across_wrap.expected
:vpi_c: @vpi_simtime_notifications.c
*/
`timescale 1ps/1ps

module test_vpi_callbacks_keep_both_simtime_words_across_wrap;
  logic observed = 0;

  initial begin
    #5 $vt_high_time_setup(observed);
    #(64'd4294967304) observed = 1;
    #(64'd4294967283) observed = 0;
    #2;
    $display("HDL time=%0d observed=%b", $time, observed);
    $vt_high_time_report;
  end
endmodule
