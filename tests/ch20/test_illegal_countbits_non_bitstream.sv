/*
:name: test_illegal_countbits_non_bitstream
:description: $countbits is applied to an object of a class with a real member, which is not bit-stream typed (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $countbits is called on the class object obj, whose real member makes it not bit-stream typed
:expected_stderr_regex: test_illegal_countbits_non_bitstream\.sv:30:
*/
// The expression argument of $countbits shall be of a bit-stream type,
// because it is flattened to a vector as if by {>>{expression}}. A class is
// a bit-stream type only when its members are (6.24.3): with an int member
// the call would be legal, but the member v of class c is a real, which is
// not integral, packed or string, so obj is not bit-stream typed.
// The 5.052 release of Verilator rejects the call on this line, but it also
// rejects the legal call on an object with only an int member, so its error
// does not count.

module test_illegal_countbits_non_bitstream;
  class c;
    real v = 1.0;
  endclass
  c obj;
  initial begin
    obj = new;
    $display("%0d", $countbits(obj, 1'b1));   // illegal: not bit-stream
  end
endmodule
