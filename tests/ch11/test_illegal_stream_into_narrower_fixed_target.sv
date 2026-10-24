/*
:name: test_illegal_stream_into_narrower_fixed_target
:description: a streaming concatenation assigned to a fixed-size target that has fewer bits than the stream is an error, not a truncation (IEEE 1800-2023 Section 11.4.14)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the 24-bit stream {>>{x, y, z}} is assigned to the 16-bit variable narrow
:expected_stderr_regex: test_illegal_stream_into_narrower_fixed_target\.sv:32:
*/
// IEEE 1800-2023 §11.4.14: when a streaming concatenation is the source of an
// assignment to a fixed-size variable, a wider target gets the stream
// left-aligned and filled with zero bits on the right, but a target with
// fewer bits than the stream shall give an error. The three bytes give a
// stream of 24 bits, fixed at elaboration: the 24-bit and 32-bit targets are
// legal; the 16-bit shortint is not.
// Icarus Verilog 13.0 does not support streaming concatenations.
// The design is accepted by the 5.052 release of Verilator.

module test_illegal_stream_into_narrower_fixed_target;
  byte x = 8'h11, y = 8'h22, z = 8'h33;
  bit [23:0] exact;
  bit [31:0] wide;
  shortint narrow;

  initial begin
    exact = {>>{x, y, z}};
    wide = {>>{x, y, z}};
    narrow = {>>{x, y, z}};   // illegal: 16 bits for a 24-bit stream
    $display("%h %h", exact, wide);
  end
endmodule
