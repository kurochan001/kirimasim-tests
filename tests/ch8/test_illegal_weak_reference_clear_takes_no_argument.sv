/*
:name: test_illegal_weak_reference_clear_takes_no_argument
:description: The weak reference clear method rejects an argument
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.30.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: clear is declared with no formal arguments
:expected_stderr_regex: test_illegal_weak_reference_clear_takes_no_argument\.sv:24:(?:\d+:)?[^\n]*(?i:(?:too many|no\s+(?:formal|argument)|expected\s+(?:0|zero)|(?:argument|parameter)[^\n]*clear|clear[^\n]*(?:argument|parameter)))
*/
module test_illegal_weak_reference_clear_takes_no_argument;
  class token;
    int value = 17;
  endclass

  initial begin
    token object;
    std::weak_reference #(token) reference_handle;
    object = new();
    reference_handle = new(object);
    reference_handle.clear(1); // illegal
    $display("unexpected clear");
  end
endmodule
