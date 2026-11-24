/*
:name: test_illegal_weak_reference_without_required_type_parameter
:description: The weak reference class requires an explicit referent class type even if its variable is null
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.30.1 G.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the standard weak reference class has no default referent type
:expected_stderr_regex: test_illegal_weak_reference_without_required_type_parameter\.sv:19:(?:\d+:)?[^\n]*(?i:(?:NoDefaultSpecialization|no default[^\n]*(?:specialization|type)|missing[^\n]*type parameter))
*/
module test_illegal_weak_reference_without_required_type_parameter;
  class referent_type;
  endclass

  std::weak_reference #(referent_type) valid_reference;
  std::weak_reference missing_type; // illegal
endmodule
