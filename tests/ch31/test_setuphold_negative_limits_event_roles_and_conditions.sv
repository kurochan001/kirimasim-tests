/*
:name: test_setuphold_negative_limits_event_roles_and_conditions
:description: Negative setup and hold limits assign distinct event roles and honor both condition arguments
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.3 31.9.2 31.9.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_setuphold_negative_limits_event_roles_and_conditions.expected
*/
// The expected results require the negative timing-check mode from 31.9.4.
`timescale 1ns/1ns
module negative_check #(parameter int SETUP = -2, HOLD = 6)
                       (input wire clk, data, timestamp_enabled, check_enabled);
  reg notifier = 0;
  specify
    $setuphold(posedge clk, posedge data, SETUP, HOLD, notifier,
               timestamp_enabled, check_enabled);
  endspecify
endmodule

module test_setuphold_negative_limits_event_roles_and_conditions;
  bit clk, early_data, late_data, near_before, near_after;
  negative_check #(-2, 6) negative_setup(clk, late_data, 1'b1, 1'b1);
  negative_check #(6, -2) negative_hold(clk, early_data, 1'b1, 1'b1);
  negative_check #(-2, 6) no_timestamp(clk, late_data, 1'b0, 1'b1);
  negative_check #(6, -2) no_timecheck(clk, early_data, 1'b1, 1'b0);
  negative_check #(-2, 6) before_setup_window(clk, near_after, 1'b1, 1'b1);
  negative_check #(6, -2) after_hold_window(clk, near_before, 1'b1, 1'b1);

  initial begin
    #16 early_data = 1;
    #3 near_before = 1;
    #1 clk = 1;
    #1 near_after = 1;
    #3 late_data = 1;
    #10;
    $display("negative_setup=%b negative_hold=%b", negative_setup.notifier,
             negative_hold.notifier);
    $display("no_stamp=%b no_check=%b", no_timestamp.notifier, no_timecheck.notifier);
    $display("outside setup=%b hold=%b", before_setup_window.notifier, after_hold_window.notifier);
  end
endmodule
