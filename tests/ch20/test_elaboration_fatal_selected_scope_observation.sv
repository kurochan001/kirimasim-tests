/*
:name: test_elaboration_fatal_selected_scope_observation
:description: A selected elaboration fatal prevents the initial block from running
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.10.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a selected generate branch issues an elaboration fatal
:expected_stderr_regex: test_elaboration_fatal_selected_scope_observation\.sv:18:(?:\d+:)?[^\n]*(?i:fatal)[^\n]*ELAB_FATAL_LIMIT
*/
// The selected branch reports at elaboration. The dormant branch contains
// a fatal task, so choosing it erroneously cannot satisfy the oracle.
module severity_fatal_cell #(parameter bit ENABLED = 1);
  if (ENABLED) begin : selected
    $fatal(0, "ELAB_FATAL_LIMIT");
  end else begin : dormant
    $fatal(0, "ELAB_DORMANT");
  end
endmodule

module test_elaboration_fatal_selected_scope_observation;
  severity_fatal_cell selected_instance();
  initial $display("SIMULATION_STARTED");
endmodule
