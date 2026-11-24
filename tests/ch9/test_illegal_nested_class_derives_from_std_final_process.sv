/*
:name: test_illegal_nested_class_derives_from_std_final_process
:description: A nested class cannot derive from the standard final process class
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.7 G.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: std::process is final even when selected through a typedef alias
:expected_stderr_regex: test_illegal_nested_class_derives_from_std_final_process\.sv:17:(?:\d+:)?[^\n]*(?i:final|cannot[^\n]*extend|deriv[^\n]*process)
*/
package process_derived_scope;
  typedef std::process builtin_process;

  class derived_process extends builtin_process;
  endclass
endpackage

module test_illegal_nested_class_derives_from_std_final_process;
  initial $display("unexpected process subtype");
endmodule
