/*
:name: test_illegal_unnamed_generate_loop_external_name_used_in_source
:description: An unnamed generate loop external name does not form a legal source path
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.6 27.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: genblk1 was assigned only for external use and cannot appear in a source path
:expected_stderr_regex: test_illegal_unnamed_generate_loop_external_name_used_in_source\.sv:19:(?:\d+:)?[^\n]*(?i:(?:unable|unknown|cannot|undeclared|not found|can.t find)[^\n]*genblk1|genblk1[^\n]*(?:not found|undeclared|unknown))
*/
module test_illegal_unnamed_generate_loop_external_name_used_in_source;
  for (genvar i = 0; i < 2; i++) begin
    int marker = 31 + i;
  end

  initial $display("unexpected internal alias=%0d", genblk1[1].marker);
endmodule
