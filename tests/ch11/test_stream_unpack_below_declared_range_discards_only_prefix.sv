/*
:name: test_stream_unpack_below_declared_range_discards_only_prefix
:description: A streaming destination below the start of a fixed array consumes the out-of-range byte and reports an error
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stream_unpack_below_declared_range_discards_only_prefix.expected
:expected_stderr_regex: (?im)^(?=[^\r\n]*\berror\b)(?=[^\r\n]*(?:stream|with\s*\[))(?=[^\r\n]*(?:range|bounds|index|extent))[^\r\n]+
:args: +stream_start=0
*/
module test_stream_unpack_below_declared_range_discards_only_prefix;
  byte unsigned entries[1:4] = '{8'he1, 8'he2, 8'he3, 8'he4};
  int base;
  logic [31:0] raw_data;

  initial begin
    if (!$value$plusargs("stream_start=%d", base)) $fatal(1, "missing stream start");
    raw_data = 32'hb1b2b3b4;
    // The first byte's destination is missing. The remaining bytes retain
    // their positions in the requested range, and element 4 is untouched.
    {>>{entries with [base:3]}} = raw_data;
    $display("first three: %h %h %h remainder=%h",
             entries[1], entries[2], entries[3], entries[4]);
  end
endmodule
