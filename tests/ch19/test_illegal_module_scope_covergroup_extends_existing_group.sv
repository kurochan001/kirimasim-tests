/*
:name: test_illegal_module_scope_covergroup_extends_existing_group
:description: A module cannot use the class-only covergroup extends declaration
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.4.1 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the derived covergroup declaration is outside any class despite a visible group
:expected_stderr_regex: test_illegal_module_scope_covergroup_extends_existing_group\.sv:19:(?:\d+:)?[^\n]*(?i:covergroup[^\n]*(?:class|extend|inheri)|(?:outside|extend|inheri)[^\n]*class|unexpected[^\n]*extends)
*/
module test_illegal_module_scope_covergroup_extends_existing_group;
  bit sample_value;
  covergroup known_group;
    coverpoint sample_value;
  endgroup
  covergroup extends known_group;
    coverpoint sample_value;
  endgroup
  initial $display("unexpected module-scope covergroup inheritance");
endmodule
