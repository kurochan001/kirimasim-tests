/*
:name: test_illegal_stream_slice_size_zero
:description: the slice size of a streaming concatenation given as a constant expression cannot be zero (IEEE 1800-2023 Section 11.4.14.2)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.14.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the slice size of {<<S{w}} is the constant S, whose value is 0
:expected_stderr_regex: test_illegal_stream_slice_size_zero\.sv:30:
*/
// IEEE 1800-2023 §11.4.14.2: the slice size of a streaming concatenation is a
// constant integral expression or a simple type, whose number of bits is
// then the block size; it shall be an error for the value of a constant
// expression to be zero or negative. The slice sizes 4 and byte are legal;
// the parameter S with the value 0 is not.
// Icarus Verilog 13.0 gives syntax errors also on the legal streaming
// concatenations, so its error does not count.

module test_illegal_stream_slice_size_zero;
  localparam int S = 0;
  bit [15:0] w = 16'h1234;
  bit [15:0] r1, r2, r3;

  initial begin
    r1 = {<<4{w}};
    r2 = {<<byte{w}};
    r3 = {<<S{w}};   // illegal: a slice size that is not positive
    $display("%h %h", r1, r2);
  end
endmodule
