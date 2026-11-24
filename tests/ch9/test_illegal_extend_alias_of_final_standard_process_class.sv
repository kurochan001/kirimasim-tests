/*
:name: test_illegal_extend_alias_of_final_standard_process_class
:description: A typedef alias of std process preserves the restriction on deriving another class
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.7 G.6 8.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parent of forbidden_child is the final standard process class through a typedef
:expected_stderr_regex: test_illegal_extend_alias_of_final_standard_process_class\.sv:22:(?:\d+:)?[^\n]*(?i:(?:marked.{0,12}final|final[^\n]*class|sealed[^\n]*class))
*/
module test_illegal_extend_alias_of_final_standard_process_class;
  class control;
  endclass
  typedef control extendible_alias;
  class allowed_child extends extendible_alias;
  endclass

  typedef std::process process_alias;
  class forbidden_child extends process_alias; // illegal
  endclass

  allowed_child legal_handle;
  forbidden_child illegal_handle;
endmodule
