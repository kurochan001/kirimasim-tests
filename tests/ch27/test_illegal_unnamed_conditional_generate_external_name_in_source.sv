/*
:name: test_illegal_unnamed_conditional_generate_external_name_in_source
:description: The external name of an unnamed conditional generate block cannot form a source path
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.6 27.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the source attempts to use the external-only name genblk2
:expected_stderr_regex: test_illegal_unnamed_conditional_generate_external_name_in_source\.sv:21:(?:\d+:)?[^\n]*(?i:(?:unable|could not|cannot|can.t find|unknown|not found|undeclared)[^\n]*genblk2|genblk2[^\n]*(?:undeclared|not found))
*/
module test_illegal_unnamed_conditional_generate_external_name_in_source;
  if (0) begin : omitted
    int marker = 99;
  end
  if (1) begin
    int marker = 47;
  end
  initial $display("marker=%0d", genblk2.marker); // illegal
endmodule
