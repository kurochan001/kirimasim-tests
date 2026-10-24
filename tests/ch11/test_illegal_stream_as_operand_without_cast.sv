/*
:name: test_illegal_stream_as_operand_without_cast
:description: a streaming concatenation cannot be an operand of an expression unless it is first cast to a bit-stream type (IEEE 1800-2023 Section 11.4.14)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the streaming concatenation {<<8{x, y}} is an operand of + without a cast
:expected_stderr_regex: test_illegal_stream_as_operand_without_cast\.sv:32:
*/
// IEEE 1800-2023 §11.4.14: a streaming concatenation shall be used as the
// target or the source of an assignment, as the operand of a bit-stream
// cast, or inside another streaming concatenation; using it as an operand in
// an expression without first casting it to a bit-stream type shall be an
// error. The assignment of {<<8{x, y}}, its cast to w16_t followed by + 1,
// and a nested streaming concatenation are legal; {<<8{x, y}} + 1 is not.
// Icarus Verilog 13.0 gives syntax errors also on the legal streaming
// concatenations, so its error does not count.

module test_illegal_stream_as_operand_without_cast;
  typedef bit [15:0] w16_t;
  byte x = 8'h12, y = 8'h34;
  w16_t swapped, sum, again;

  initial begin
    swapped = {<<8{x, y}};
    sum = w16_t'({<<8{x, y}}) + 1;
    again = {<<8{{<<8{x, y}}}};
    sum = {<<8{x, y}} + 1;   // illegal: a streaming concatenation as an operand
    $display("%h %h %h", swapped, sum, again);
  end
endmodule
