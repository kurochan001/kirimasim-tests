/*
:name: test_illegal_weak_reference_clear_value_from_void_method
:description: The weak reference clear method cannot be used as a value in an assignment
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.30.4 13.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: clear returns void and its call is used as an assignment value
:expected_stderr_regex: test_illegal_weak_reference_clear_value_from_void_method\.sv:25:(?:\d+:)?[^\n]*(?i:(?:void[^\n]*(?:value|expression|assign|conversion|context)|(?:value|expression|assign|conversion|context)[^\n]*void))
*/
module test_illegal_weak_reference_clear_value_from_void_method;
  class token;
    int value = 17;
  endclass

  initial begin
    token object;
    std::weak_reference #(token) reference_handle;
    int result;
    object = new();
    reference_handle = new(object);
    result = reference_handle.clear(); // illegal
    $display("result=%0d", result);
  end
endmodule
