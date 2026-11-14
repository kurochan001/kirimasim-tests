/*
:name: test_illegal_stream_real_item
:description: a stream_expression that is neither of a bit-stream type nor an unpacked array, structure, union or class handle is skipped with an error (IEEE 1800-2023 Section 11.4.14.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.14.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the real variable r is an item of the streaming concatenation {>>{i, r}}, and a real value is none of the kinds of item that can be streamed
:expected_stderr_regex: test_illegal_stream_real_item\.sv:32:
*/
// IEEE 1800-2023 §11.4.14.1: each stream_expression is turned into bits by
// a recursive procedure that knows streaming concatenations and bit-stream
// types (§6.24.3: integral, packed and string types and unpacked
// aggregates, classes and dynamically sized arrays of them), unpacked
// arrays, structures, untagged unions and class handles. Any other item is
// skipped and an error is issued. A real is not a bit-stream type and is
// none of the other kinds, so the item r of {>>{i, r}} reaches that last
// case. Without it, {>>{i}} streams the int i into the 32-bit t and is
// legal.
// Icarus Verilog 13.0 does not support streaming concatenations.

module test_illegal_stream_real_item;
  int i = 32'h1234_5678;
  real r = 1.5;
  bit [31:0] t, u;

  initial begin
    t = {>>{i}};
    u = {>>{i, r}};   // illegal: a real item in a streaming concatenation
  end
endmodule
