/*
:name: test_recrem_negative_limits_apply_timestamp_and_timecheck_conditions
:description: Negative recovery and removal limits apply both condition arguments inside their respective timing windows
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.6 31.9.2 31.9.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_recrem_negative_limits_apply_timestamp_and_timecheck_conditions.expected
*/
// The expected results require negative timing checks to be enabled.
`timescale 1ns/1ns
module gated_recrem #(parameter int REC = -2, REM = 6)
                     (input wire reset_n, clock, timestamp_enabled, check_enabled);
  reg notifier = 0;
  specify
    $recrem(posedge reset_n, posedge clock, REC, REM, notifier,
            timestamp_enabled, check_enabled);
  endspecify
endmodule
module test_recrem_negative_limits_apply_timestamp_and_timecheck_conditions;
  bit reset_n, early_clock, late_clock, near_before, near_after;

  gated_recrem #(-2, 6) recovery(reset_n, early_clock, 1'b1, 1'b1);
  gated_recrem #(-2, 6) recovery_no_stamp(reset_n, early_clock, 1'b0, 1'b1);
  gated_recrem #(-2, 6) recovery_no_check(reset_n, early_clock, 1'b1, 1'b0);
  gated_recrem #(-2, 6) recovery_near(reset_n, near_before, 1'b1, 1'b1);
  gated_recrem #(6, -2) removal(reset_n, late_clock, 1'b1, 1'b1);
  gated_recrem #(6, -2) removal_no_stamp(reset_n, late_clock, 1'b0, 1'b1);
  gated_recrem #(6, -2) removal_no_check(reset_n, late_clock, 1'b1, 1'b0);
  gated_recrem #(6, -2) removal_near(reset_n, near_after, 1'b1, 1'b1);

  initial begin
    #16 early_clock = 1;
    #3 near_before = 1;
    #1 reset_n = 1;
    #1 near_after = 1;
    #3 late_clock = 1;
    #10;
    $display("negative recovery=%b stamp_off=%b check_off=%b outside=%b",
             recovery.notifier, recovery_no_stamp.notifier, recovery_no_check.notifier,
             recovery_near.notifier);
    $display("negative removal=%b stamp_off=%b check_off=%b outside=%b",
             removal.notifier, removal_no_stamp.notifier, removal_no_check.notifier,
             removal_near.notifier);
  end
endmodule
