/*
:name: test_illegal_forward_class_scope_variable_before_completion_in_package
:description: A variable cannot use a class-scoped type directly before the forward class is complete
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.18
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the package declares a variable through the incomplete class prefix
:expected_stderr_regex: test_illegal_forward_class_scope_variable_before_completion_in_package\.sv:17:(?:\d+:)?[^\n]*(?i:incomplete|forward|declared before|not yet)
*/
package incomplete_type_pkg;
  typedef class owner;
  typedef owner::payload deferred_name;
  owner::payload too_early;

  class owner;
    typedef logic [12:0] payload;
  endclass

  owner::payload legal_value;
endpackage

module test_illegal_forward_class_scope_variable_before_completion_in_package;
  initial $display("unexpected completed type");
endmodule
