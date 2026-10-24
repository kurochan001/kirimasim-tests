/*
:name: test_illegal_stream_into_real_target
:description: the target of an assignment whose source is a streaming concatenation has to be of a bit-stream type or be a streaming concatenation, so it cannot be real (IEEE 1800-2023 Section 11.4.14)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the streaming concatenation {>>{x, y}} is assigned to the real variable r, which is not of a bit-stream type
:expected_stderr_regex: test_illegal_stream_into_real_target\.sv:33:
*/
// IEEE 1800-2023 §11.4.14: when a streaming concatenation is the source of an
// assignment, the target shall be a data object of a bit-stream type (6.24.3:
// integral, packed or string types and arrays, structures or classes of
// them) or a streaming concatenation. An int, an unpacked array of bytes and
// a streaming concatenation are legal targets; the real r is not.
// Icarus Verilog 13.0 does not support streaming concatenations.
// The design is accepted by the 5.052 release of Verilator.

module test_illegal_stream_into_real_target;
  byte x = 8'h12, y = 8'h34;
  int i;
  byte ba [2];
  byte p, q;
  real r;

  initial begin
    i = {>>{x, y}};
    ba = {>>{x, y}};
    {>>{p, q}} = {<<8{x, y}};
    r = {>>{x, y}};   // illegal: real is not a bit-stream type
    $display("%h %h %h", i, ba[0], p);
  end
endmodule
