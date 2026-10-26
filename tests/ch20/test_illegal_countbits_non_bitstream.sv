/*
:name: test_illegal_countbits_non_bitstream
:description: $countbits is applied to a class object, which is not bit-stream typed (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $countbits is called on the class object obj
:expected_stderr_regex: test_illegal_countbits_non_bitstream\.sv:25:
*/
// The expression argument of $countbits shall be of a bit-stream type,
// because it is flattened to a vector as if by {>>{expression}}. A class
// object is not bit-stream typed.

module test_illegal_countbits_non_bitstream;
  class c;
    int v = 1;
  endclass
  c obj;
  initial begin
    obj = new;
    $display("%0d", $countbits(obj, 1'b1));   // illegal: not bit-stream
  end
endmodule
