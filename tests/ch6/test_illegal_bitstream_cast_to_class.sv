/*
:name: test_illegal_bitstream_cast_to_class
:description: a class type cannot be the destination type of a bit-stream cast (IEEE 1800-2023 Section 6.24.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the 64-bit value 64'h1 is cast to the class type pair_c
:expected_stderr_regex: test_illegal_bitstream_cast_to_class\.sv:38:
*/
// IEEE 1800-2023 §6.24.3: an explicit cast can convert between bit-stream types
// (integral, packed and string types, and unpacked arrays, structures, classes
// and dynamically sized arrays of them) by packing the source into a stream of
// bits and unpacking it into the destination, the first element or field taking
// the most significant bits. An associative array type or a class shall not be
// the destination type.
// The 64-bit value 64'h0000000300000004 is cast to the unpacked array type
// i2_t of two int elements, and the legal design prints the elements, the
// first from the upper half: 3 4. The last cast has the class type pair_c as
// its destination.
// Neither Icarus Verilog 13.0 nor the 5.052 release supports these casts: they
// report the casts as not supported, and their errors do not count.

module test_illegal_bitstream_cast_to_class;
  class test_illegal_bitstream_cast_to_class_pair_c;
    int a = 3;
    int b = 4;
  endclass
  typedef int i2_t [2];
  test_illegal_bitstream_cast_to_class_pair_c g;
  i2_t w;
  initial begin
    w = i2_t'(64'h0000000300000004);
    $display("%0d %0d", w[0], w[1]);
    g = test_illegal_bitstream_cast_to_class_pair_c'(64'h1);   // illegal: class destination
  end
endmodule
