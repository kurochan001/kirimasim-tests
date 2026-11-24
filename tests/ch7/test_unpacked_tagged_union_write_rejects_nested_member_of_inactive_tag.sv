/*
:name: test_unpacked_tagged_union_write_rejects_nested_member_of_inactive_tag
:description: Writing a nested field through an inactive tagged union member reports a runtime error
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.2 11.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unpacked_tagged_union_write_rejects_nested_member_of_inactive_tag.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal)\b)(?=[^\n]*(?:tagged|tag mismatch|inactive member))(?=[^\n]*(?:\bColor\b|writ|access))[^\n]+
*/
`timescale 1ns/1ns
module test_unpacked_tagged_union_write_rejects_nested_member_of_inactive_tag;
  typedef struct {
    byte red;
    byte green;
  } color_t;
  typedef union tagged {
    int Count;
    color_t Color;
  } tagged_record;

  tagged_record item;

  initial begin
    item = tagged Color '{red: 3, green: 5};
    item.Color.green = 7;
    $display("before change Color=%0d,%0d", item.Color.red, item.Color.green);
    #1 item = tagged Count 22;
    $display("after change Count=%0d", item.Count);
    #1 item.Color.green = 13;
  end
endmodule
