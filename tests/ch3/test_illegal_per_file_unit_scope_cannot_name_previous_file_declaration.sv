/*
:name: test_illegal_per_file_unit_scope_cannot_name_previous_file_declaration
:description: An explicit compilation-unit name cannot reach a declaration in a different file unit
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the named value exists only in the preceding, separate compilation unit
:expected_stderr_regex: test_illegal_per_file_unit_scope_cannot_name_previous_file_declaration\.sv:17:(?:\d+:)?[^\n]*(?i:(?:undeclared|unknown|find|not found|missing|no member)[^\n]*mode_visible_value|mode_visible_value[^\n]*(?:undeclared|unknown|not found))
:files: unit_visibility_provider.sv
:args: --compilation-unit=per-file
*/
module test_illegal_per_file_unit_scope_cannot_name_previous_file_declaration;
  initial $display("unexpected accessible value=%0d", $unit::mode_visible_value);
endmodule
