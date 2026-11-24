/*
:name: test_stream_unpack_reports_fixed_range_overflow_and_preserves_overlap
:description: A run-time streaming slice that exceeds a fixed array writes only in-range entries and reports the bounds error
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stream_unpack_reports_fixed_range_overflow_and_preserves_overlap.expected
:expected_stderr_regex: (?im)^(?=[^\r\n]*\berror\b)(?=[^\r\n]*(?:stream|with\s*\[))(?=[^\r\n]*(?:range|bounds|index|extent))[^\r\n]+
:args: +stream_start=2
*/
module test_stream_unpack_reports_fixed_range_overflow_and_preserves_overlap;
  byte unsigned entries[1:4] = '{8'h80, 8'h81, 8'h82, 8'h83};
  int base;
  logic [31:0] payload;

  initial begin
    base = 1;
    payload = 32'ha1a2a3a4;
    {>>{entries with [base +: 4]}} = payload;
    $display("in range: %h %h %h %h", entries[1], entries[2], entries[3], entries[4]);

    // Get the new start dynamically. The invalid last index follows every
    // real destination, so its byte cannot shift any of the legal writes.
    if (!$value$plusargs("stream_start=%d", base)) $fatal(1, "missing stream start");
    payload = 32'hb1b2b3b4;
    {>>{entries with [base +: 4]}} = payload;
    $display("overlap: %h %h %h %h", entries[1], entries[2], entries[3], entries[4]);
  end
endmodule
