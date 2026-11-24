/*
:name: test_illegal_associative_index_contains_nested_real
:description: An associative index type cannot contain a real through a nested unpacked structure
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the nested associative key type contains a real
:expected_stderr_regex: test_illegal_associative_index_contains_nested_real\.sv:17:(?:\d+:)?[^\n]*(?i:(?:associative|index|key)[^\n]*(?:real|floating|element|equality|type)|(?:real|floating)[^\n]*(?:associative|index|key))
*/
module test_illegal_associative_index_contains_nested_real;
  typedef struct { int serial; real gain; } part_key;
  typedef struct { string label_text; part_key part; } invalid_key;
  int data[invalid_key]; // illegal
  initial $display("unexpected associative index");
endmodule
