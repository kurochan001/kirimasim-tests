/*
:name: test_illegal_anonymous_struct_not_equivalent
:description: Anonymous unpacked structures from different declarations are not equivalent, so one cannot be assigned to the other (IEEE 1800-2023 Section 6.22.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.22.2 6.22.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: s3, of an anonymous struct type declared on its own, is assigned to s1
:expected_stderr_regex: test_illegal_anonymous_struct_not_equivalent\.sv:24:
*/
// IEEE 1800-2023 §6.22.2: an anonymous unpacked struct type is equivalent only
// to itself among the variables of the same declaration. s1 and s2 share one;
// s3 has another of the same shape, which is not equivalent, so it cannot be
// assigned to s1.

module test_illegal_anonymous_struct_not_equivalent;
  struct {int a; int b;} s1, s2;
  struct {int a; int b;} s3;
  initial begin
    s2 = s1;
    s1 = s3;           // illegal: types not equivalent
  end
endmodule
