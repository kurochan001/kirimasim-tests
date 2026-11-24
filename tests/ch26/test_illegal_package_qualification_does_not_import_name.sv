/*
:name: test_illegal_package_qualification_does_not_import_name
:description: Reading a qualified package constant does not make its simple name visible
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.5 26.3
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: unqualified step has no local declaration or import
:expected_stderr_regex: test_illegal_package_qualification_does_not_import_name\.sv:20:(?:\d+:)?[^\n]*(?i:(?:unbound|undeclared|unknown|undefined|not found|cannot|unable|can't)[^\n]*step|step[^\n]*(?:unbound|undeclared|unknown|undefined|not found))
*/
package unimported;
  localparam int step = 12;
endpackage

module test_illegal_package_qualification_does_not_import_name;
  localparam int qualified_step = unimported::step;
  localparam int unqualified_step = step;
  initial $display("%0d %0d", qualified_step, unqualified_step);
endmodule
