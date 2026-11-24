/*
:name: test_elaboration_fatal_reports_logical_location_and_blocks_simulation
:description: A selected elaboration fatal reports its logical source location, scope and message and prevents simulation
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10.1 22.12 22.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_elaboration_fatal_reports_logical_location_and_blocks_simulation.expected
:expected_stderr_regex: (?im)\A(?![\s\S]*^SIMULATION_STARTED$)(?![\s\S]*DORMANT_FATAL_SITE)(?=[\s\S]*^(?=[^\n]*logical_elab_fatal\.sv:427(?::|\b))(?=[^\n]*\bfatal\b)[^\n]*SELECTED_FATAL_SITE FILE=logical_elab_fatal\.sv LINE=427(?:[^\n]*\n[ \t]+){0,3}[^\n]*test_elaboration_fatal_reports_logical_location_and_blocks_simulation\.u\.winner)
*/
module logical_fatal_cell #(parameter bit SELECT = 1);
  if (SELECT) begin : winner
    `line 427 "logical_elab_fatal.sv" 0
    $fatal(0, "SELECTED_FATAL_SITE FILE=%s LINE=%0d", `__FILE__, `__LINE__);
    `line 21 "test_elaboration_fatal_reports_logical_location_and_blocks_simulation.sv" 0
  end else begin : dormant
    $fatal(0, "DORMANT_FATAL_SITE");
  end
endmodule

module test_elaboration_fatal_reports_logical_location_and_blocks_simulation;
  logical_fatal_cell u();
  initial $display("SIMULATION_STARTED");
endmodule
