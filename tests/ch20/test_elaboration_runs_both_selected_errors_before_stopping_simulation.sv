/*
:name: test_elaboration_runs_both_selected_errors_before_stopping_simulation
:description: Distinct selected elaboration errors both report before simulation starts
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.10.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: two elaborated parameter guards issue errors before simulation
:expected_stderr_regex: (?i)test_elaboration_runs_both_selected_errors_before_stopping_simulation\.sv:(?:16:(?:\d+:)?[^\n]*\berror\b[^\n]*FIRST_FAILURE_MARKER|19:(?:\d+:)?[^\n]*\berror\b[^\n]*SECOND_FAILURE_MARKER)
*/
module parameter_guard #(parameter int KIND = 0);
  if (KIND == 1) begin : left_error
    $error("FIRST_FAILURE_MARKER"); // illegal
  end
  if (KIND == 2) begin : right_error
    $error("SECOND_FAILURE_MARKER");
  end
endmodule

module test_elaboration_runs_both_selected_errors_before_stopping_simulation;
  parameter_guard #(1) low();
  parameter_guard #(2) high();
  initial $display("SIMULATION_STARTED");
endmodule
