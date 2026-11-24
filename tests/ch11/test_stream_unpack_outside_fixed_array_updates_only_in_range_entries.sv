/*
:name: test_stream_unpack_outside_fixed_array_updates_only_in_range_entries
:description: A streaming range that extends past a fixed array updates the in-range entries and reports an error
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stream_unpack_outside_fixed_array_updates_only_in_range_entries.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal)\b)(?=[^\n]*(?:\bstream|\bunpack|\bfixed array))(?=[^\n]*(?:out of bounds|beyond|outside|outside the range|range exceeds|out.of.range))[^\n]+
*/
`timescale 1ns/1ns
module test_stream_unpack_outside_fixed_array_updates_only_in_range_entries;
  byte values [1:4];
  int start_index, count;
  initial begin
    values[1] = 8'h11;
    values[2] = 8'h22;
    values[3] = 8'h33;
    values[4] = 8'h44;
    if (!$value$plusargs("stream_count=%d", count)) count = 3;
    start_index = 3;
    #1 {>>{values with [start_index +: count]}} = 24'ha1b2c3;
    $display("bytes=%02h/%02h/%02h/%02h", values[1], values[2], values[3], values[4]);
  end
endmodule
