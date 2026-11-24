/*
:name: test_vpi_transport_put_emits_one_callback_before_and_after_high_time_word
:description: A delayed VPI write to each variable emits one callback before or after the simulated time high word changes
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 38.36.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_transport_put_emits_one_callback_before_and_after_high_time_word.expected
:vpi_c: @vpi_simtime_notifications.c
*/
`timescale 1ps/1ps

module test_vpi_transport_put_emits_one_callback_before_and_after_high_time_word;
  logic early = 0, late = 0;

  initial begin
    #5 $vt_high_put_setup(early, late);
    #(64'd4294967298);
    $display("HDL time=%0d early=%b late=%b", $time, early, late);
    $vt_high_put_report;
  end
endmodule
