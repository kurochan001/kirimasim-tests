/*
:name: test_packed_tagged_union_read_rejects_previous_member_after_tag_change
:description: Reading the previous packed union member after a tag change reports a runtime error
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.2 11.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_tagged_union_read_rejects_previous_member_after_tag_change.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal)\b)(?=[^\n]*(?:tagged|tag mismatch|inactive member))(?=[^\n]*(?:\bBig\b|read|access))[^\n]+
*/
`timescale 1ns/1ns
module test_packed_tagged_union_read_rejects_previous_member_after_tag_change;
  typedef union tagged packed {
    logic [3:0] Small;
    logic [7:0] Big;
  } tagged_word;

  tagged_word word_value;
  logic [7:0] unused;

  initial begin
    word_value = tagged Big 8'ha6;
    $display("before change Big=%h", word_value.Big);
    #1 word_value = tagged Small 4'hb;
    $display("after change Small=%h", word_value.Small);
    #1 unused = word_value.Big;
  end
endmodule
