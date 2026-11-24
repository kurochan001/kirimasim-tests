/*
:name: test_illegal_stream_with_negative_index_on_dynamic_array
:description: A streaming range of a dynamic array cannot start at a negative index
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.14.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the streaming range of a dynamic array starts at the negative index FIRST
:expected_stderr_regex: test_illegal_stream_with_negative_index_on_dynamic_array\.sv:19:(?:\d+:)?[^\n]*(?i:(?:stream|range|select|index)[^\n]*(?:negative|positive|out of bounds|out.of.range)|(?:negative|positive)[^\n]*(?:stream|range|select|index))
*/
module test_illegal_stream_with_negative_index_on_dynamic_array;
  byte values [];
  localparam int FIRST = -1;
  initial begin
    values = new[2];
    {>>{values with [FIRST +: 2]}} = 16'ha1b2; // illegal
    $display("unexpected unpack");
  end
endmodule
