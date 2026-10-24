/*
:name: test_illegal_unpack_from_real_source
:description: the source of an assignment to a streaming concatenation has to be of a bit-stream type or be a streaming concatenation, so it cannot be real (IEEE 1800-2023 Section 11.4.14.3)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the real variable r is the source of an assignment whose target is the streaming concatenation {>>{x, y}}
:expected_stderr_regex: test_illegal_unpack_from_real_source\.sv:29:
*/
// IEEE 1800-2023 §11.4.14.3: when a streaming concatenation is the target of
// an assignment, it unpacks the bits of the source, and the source shall be
// of a bit-stream type or the result of another streaming concatenation.
// The sources w16 and {<<8{w16}} are legal; the real r is not.
// Icarus Verilog 13.0 does not support streaming concatenations.
// The design is accepted by the 5.052 release of Verilator.

module test_illegal_unpack_from_real_source;
  bit [15:0] w16 = 16'habcd;
  real r = 1.5;
  byte x, y;

  initial begin
    {>>{x, y}} = w16;
    {>>{x, y}} = {<<8{w16}};
    {>>{x, y}} = r;   // illegal: real is not a bit-stream type
    $display("%h %h", x, y);
  end
endmodule
