/*
:name: test_illegal_stream_with_on_two_dimensional_array
:description: the expression before with in a streaming concatenation has to be a one-dimensional unpacked array, not a two-dimensional one (IEEE 1800-2023 Section 11.4.14.4)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.14.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the with range [0 +: 1] is applied to the two-dimensional unpacked array m
:expected_stderr_regex: test_illegal_stream_with_on_two_dimensional_array\.sv:31:
*/
// IEEE 1800-2023 §11.4.14.4: the expression before with can be any
// one-dimensional unpacked array, including a queue. A with range on the
// one-dimensional array fa, and on the row m[1] of the two-dimensional array
// m, is legal; one on m itself is not.
// Icarus Verilog 13.0 gives syntax errors also on the legal streaming
// concatenations, so its error does not count.
// The 5.052 release of Verilator reports with ranges in streaming
// concatenations as unsupported.

module test_illegal_stream_with_on_two_dimensional_array;
  byte fa [4] = '{1, 2, 3, 4};
  byte m [2][2] = '{'{1, 2}, '{3, 4}};
  bit [15:0] r1, r2, r3;

  initial begin
    r1 = {>>{fa with [0 +: 2]}};
    r2 = {>>{m[1] with [0 +: 2]}};
    r3 = {>>{m with [0 +: 1]}};   // illegal: m has two unpacked dimensions
    $display("%h %h", r1, r2);
  end
endmodule
