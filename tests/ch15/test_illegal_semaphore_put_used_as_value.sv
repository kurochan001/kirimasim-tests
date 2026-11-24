/*
:name: test_illegal_semaphore_put_used_as_value
:description: Semaphore put is a void function and cannot supply an expression value
:tags: ch15
:type: elaboration
:lrm: 1800-2023 15.3.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a void semaphore put call is used as the right-hand value
:expected_stderr_regex: test_illegal_semaphore_put_used_as_value\.sv:20:(?:\d+:)?[^\n]*(?i:(?:void|return type|nonvalue|assign)[^\n]*)
*/
module test_illegal_semaphore_put_used_as_value;
  std::semaphore available = new(0);
  int count;

  initial begin
    available.put();
    count = available.put(.keyCount(1)); // illegal
  end
endmodule
