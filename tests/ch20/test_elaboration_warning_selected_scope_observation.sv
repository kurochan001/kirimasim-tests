/*
:name: test_elaboration_warning_selected_scope_observation
:description: A selected elaboration warning and info report before the simulation can run
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_elaboration_warning_selected_scope_observation.expected
:expected_exit: 0
:expected_stderr_regex: (?s)\A(?=.*test_elaboration_warning_selected_scope_observation\.sv:19:\d*:?[^\n]*(?i:warning)[^\n]*ELAB_WARNING_LIMIT line=19)(?=.*test_elaboration_warning_selected_scope_observation\.sv:20:\d*:?[^\n]*(?i:info|note)[^\n]*ELAB_INFO_SIBLING line=20)
*/
// The selected branch reports at elaboration. The dormant branch contains
// a fatal task, so choosing it erroneously cannot satisfy the oracle.
module severity_warning_cell #(parameter bit ENABLED = 1);
  if (ENABLED) begin : selected
    $warning("ELAB_WARNING_LIMIT line=%0d", `__LINE__);
    $info("ELAB_INFO_SIBLING line=%0d", `__LINE__);
  end else begin : dormant
    $fatal(0, "ELAB_DORMANT");
  end
endmodule

module test_elaboration_warning_selected_scope_observation;
  severity_warning_cell selected_instance();
  initial $display("SIMULATION_STARTED");
endmodule
