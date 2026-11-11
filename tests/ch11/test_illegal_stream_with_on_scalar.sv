/*
:name: test_illegal_stream_with_on_scalar
:description: the expression before with in a streaming concatenation has to be a one-dimensional unpacked array, not an integral variable (IEEE 1800-2023 Section 11.4.14.4)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.14.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the with range [0 +: 2] is applied to the int variable n
:expected_stderr_regex: test_illegal_stream_with_on_scalar\.sv:31:
*/
// IEEE 1800-2023 §11.4.14.4: the expression before with can be any
// one-dimensional unpacked array, including a queue. A with range on the
// fixed-size array fa and on the queue q is legal; one on the int n is not.
// Icarus Verilog 13.0 gives syntax errors also on the legal streaming
// concatenations, so its error does not count.
// The 5.052 release of Verilator reports with ranges in streaming
// concatenations as unsupported.

module test_illegal_stream_with_on_scalar;
  byte fa [4] = '{1, 2, 3, 4};
  byte q [$] = '{5, 6, 7};
  int n = 32'h01020304;
  bit [15:0] r1, r2, r3;

  initial begin
    r1 = {>>{fa with [1 +: 2]}};
    r2 = {>>{q with [0 +: 2]}};
    r3 = {>>{n with [0 +: 2]}};   // illegal: n is not an unpacked array
    $display("%h %h", r1, r2);
  end
endmodule
