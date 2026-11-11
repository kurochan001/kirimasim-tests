/*
:name: test_illegal_bitstream_cast_fixed_size_mismatch
:description: a bit-stream cast between fixed-size types of different sizes, one of them unpacked, is a compile-time error (IEEE 1800-2023 Section 6.24.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked array t3 of three bytes, 24 bits, is cast to int, 32 bits
:expected_stderr_regex: test_illegal_bitstream_cast_fixed_size_mismatch\.sv:38:
*/
// IEEE 1800-2023 §6.24.3: an explicit cast can convert between bit-stream types
// (integral, packed and string types, and unpacked arrays, structures, classes
// and dynamically sized arrays of them) by packing the source into a stream of
// bits and unpacking it into the destination, the first element or field taking
// the most significant bits. If both types have fixed sizes that differ and
// either of them is unpacked, the cast is a compile-time error.
// The array type bytes4_t of four bytes has 32 bits, as int has: the int
// 32'h11223344 is cast to it and back, and the legal design prints the first
// and last elements and the value cast back: 11 44 11223344. The cast of the
// 24-bit unpacked array t3 to int has different sizes.
// Neither Icarus Verilog 13.0 nor the 5.052 release supports these casts: they
// report the casts of the legal part as not supported, or stop with a failed
// internal assertion, and their errors do not count.

module test_illegal_bitstream_cast_fixed_size_mismatch;
  typedef byte bytes4_t [4];
  typedef byte bytes3_t [3];
  bytes4_t q;
  bytes3_t t3 = '{1, 2, 3};
  int v;
  initial begin
    q = bytes4_t'(32'h11223344);
    v = int'(q);
    $display("%h %h %h", q[0], q[3], v);
    v = int'(t3);   // illegal: 24-bit unpacked source for a 32-bit destination
  end
endmodule
