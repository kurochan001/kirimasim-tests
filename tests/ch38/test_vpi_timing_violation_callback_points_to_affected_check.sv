/*
:name: test_vpi_timing_violation_callback_points_to_affected_check
:description: Setup and hold violation callbacks identify the distinct timing checks that were violated
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.3 31.3.1 31.3.2 37.40
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_timing_violation_callback_points_to_affected_check.c
:expected_stdout: @test_vpi_timing_violation_callback_points_to_affected_check.expected
*/
`timescale 1ns/1ns
module violation_callback_path(input wire setup_ref, setup_data, hold_ref, hold_data,
                              output reg setup_notifier = 0, hold_notifier = 0);
  specify
    $setup(posedge setup_data, posedge setup_ref, 3, setup_notifier);
    $hold(posedge hold_ref, posedge hold_data, 3, hold_notifier);
  endspecify
endmodule

module test_vpi_timing_violation_callback_points_to_affected_check;
  bit setup_ref, setup_data, hold_ref, hold_data;
  wire setup_notifier, hold_notifier;
  violation_callback_path dut(setup_ref, setup_data, hold_ref, hold_data,
                              setup_notifier, hold_notifier);

  initial begin
    #1 $watch_timing_violations;
    #3 setup_data = 1;
    #4 setup_ref = 1; // No violation on the first setup check.
    #1;
    setup_data = 0;
    setup_ref = 0;
    #1 setup_data = 1;
    #2 setup_ref = 1;
    #8 hold_ref = 1;
    #2 hold_data = 1;
    #3;
    $display("notifiers setup=%b hold=%b", setup_notifier, hold_notifier);
    $report_timing_violations;
    $finish(0);
  end
endmodule
