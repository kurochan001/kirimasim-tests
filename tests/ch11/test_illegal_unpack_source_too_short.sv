/*
:name: test_illegal_unpack_source_too_short
:description: when a streaming concatenation is the target of an assignment, a source with fewer bits than the target needs is an error (IEEE 1800-2023 Section 11.4.14.3)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the 16-bit source s16 is unpacked into {>>{x, y, z}}, which needs 24 bits
:expected_stderr_regex: test_illegal_unpack_source_too_short\.sv:31:
*/
// IEEE 1800-2023 §11.4.14.3: if the source of an unpack has more bits than
// needed, the bits are taken from its left end, but if more bits are needed
// than the source provides, an error shall be generated. The target
// {>>{x, y, z}} needs 24 bits, fixed at elaboration: the 24-bit and 32-bit
// sources are legal; the 16-bit source s16 is not.
// Icarus Verilog 13.0 does not support streaming concatenations.
// The design is accepted by the 5.052 release of Verilator.

module test_illegal_unpack_source_too_short;
  bit [23:0] s24 = 24'h123456;
  bit [31:0] s32 = 32'h789abcde;
  bit [15:0] s16 = 16'h1111;
  byte x, y, z;

  initial begin
    {>>{x, y, z}} = s24;
    {>>{x, y, z}} = s32;
    {>>{x, y, z}} = s16;   // illegal: 16 bits for a 24-bit target
    $display("%h %h %h", x, y, z);
  end
endmodule
