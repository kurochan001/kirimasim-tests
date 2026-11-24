/*
:name: test_illegal_foreach_index_assignment_in_body
:description: The loop index implicit in foreach is read only
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.7.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the foreach body writes the implicitly declared loop index
:expected_stderr_regex: test_illegal_foreach_index_assignment_in_body\.sv:20:(?:\d+:)?[^\n]*(?i:(?:read[ -]?only|cannot|not allowed|assignment)[^\n]*(?:index|variable)|(?:index|variable)[^\n]*(?:read[ -]?only|cannot|not allowed))
*/
module test_illegal_foreach_index_assignment_in_body;
  int values[3];

  initial begin
    foreach (values[index]) begin
      values[index] = index + 10;
      index = 1; // illegal
    end
  end
endmodule
