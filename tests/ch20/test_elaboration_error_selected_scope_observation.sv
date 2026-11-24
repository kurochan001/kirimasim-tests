/*
:name: test_elaboration_error_selected_scope_observation
:description: A selected elaboration error rejects the design before simulation
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.10.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a selected generate branch issues an elaboration error
:expected_stderr_regex: test_elaboration_error_selected_scope_observation\.sv:18:(?:\d+:)?[^\n]*(?i:error)[^\n]*ELAB_ERROR_LIMIT
*/
// Only one child selects the branch that reports an elaboration error.
// The initial block would print a marker if simulation started.
module severity_error_cell #(parameter bit ENABLED = 1);
  if (ENABLED) begin : selected
    $error("ELAB_ERROR_LIMIT");
  end else begin : dormant
    wire unused = 1'b0;
  end
endmodule

module test_elaboration_error_selected_scope_observation;
  severity_error_cell #(.ENABLED(0)) disabled_instance();
  severity_error_cell selected_instance();
  initial $display("SIMULATION_STARTED");
endmodule
