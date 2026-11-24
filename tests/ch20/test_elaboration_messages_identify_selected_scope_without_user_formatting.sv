/*
:name: test_elaboration_messages_identify_selected_scope_without_user_formatting
:description: Elaboration messages include source and scope even when the user message omits location
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_elaboration_messages_identify_selected_scope_without_user_formatting.expected
:expected_stderr_regex: (?im)\A(?=[\s\S]*^(?=[^\n]*test_elaboration_messages_identify_selected_scope_without_user_formatting\.sv:16(?::|\b))(?=[^\n]*\b(?:warning|warn)\b)[^\n]*\bSELECTED_ONE_MARKER\b(?:[^\n]*\n[ \t]+){0,3}[^\n]*test_elaboration_messages_identify_selected_scope_without_user_formatting\.alpha\.warn_site)(?=[\s\S]*^(?=[^\n]*test_elaboration_messages_identify_selected_scope_without_user_formatting\.sv:19(?::|\b))(?=[^\n]*\b(?:info|note)\b)[^\n]*\bSELECTED_TWO_MARKER\b(?:[^\n]*\n[ \t]+){0,3}[^\n]*test_elaboration_messages_identify_selected_scope_without_user_formatting\.beta\.info_site)
*/
module only_messages #(parameter int KIND = 0);
  if (KIND == 1) begin : warn_site
    $warning("SELECTED_ONE_MARKER");
  end
  if (KIND == 2) begin : info_site
    $info("SELECTED_TWO_MARKER");
  end
  if (KIND == 3) begin : other_site
    $error("DESELECTED_ERROR_MARKER");
  end
endmodule

module test_elaboration_messages_identify_selected_scope_without_user_formatting;
  only_messages #(1) alpha();
  only_messages #(2) beta();
  initial $display("SIMULATION_STARTED");
endmodule
