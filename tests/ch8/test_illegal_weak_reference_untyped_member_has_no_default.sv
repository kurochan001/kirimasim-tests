/*
:name: test_illegal_weak_reference_untyped_member_has_no_default
:description: An untyped weak-reference class member needs an explicit referent specialization
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.30.1 G.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: std::weak_reference has a required type parameter and no default
:expected_stderr_regex: test_illegal_weak_reference_untyped_member_has_no_default\.sv:22:(?:\d+:)?[^\n]*(?i:NoDefaultSpecialization|no default[^\n]*(?:specialization|type)|missing[^\n]*type parameter)
*/
module test_illegal_weak_reference_untyped_member_has_no_default;
  class entry;
    int value = 1;
  endclass
  class typed_holder;
    std::weak_reference #(entry) typed_slot;
  endclass
  class missing_type_holder extends typed_holder;
    std::weak_reference missing_type;
  endclass

  initial $display("unexpected weak reference type");
endmodule
