/*
:name: test_illegal_bitstream_cast_to_assoc_array
:description: an associative array type cannot be the destination type of a bit-stream cast (IEEE 1800-2023 Section 6.24.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the int value 32'h01020304 is cast to the associative array type aa_t
:expected_stderr_regex: test_illegal_bitstream_cast_to_assoc_array\.sv:36:
*/
// IEEE 1800-2023 §6.24.3: an explicit cast can convert between bit-stream types
// (integral, packed and string types, and unpacked arrays, structures, classes
// and dynamically sized arrays of them) by packing the source into a stream of
// bits and unpacking it into the destination, the first element or field taking
// the most significant bits. An associative array type or a class shall not be
// the destination type.
// The int 32'h01020304 is cast to the dynamic array type dyn_t of bytes, which
// takes four elements, and the legal design prints the size and the first and
// last elements: 4 1 4. The last cast has the associative array type aa_t as
// its destination.
// Neither Icarus Verilog 13.0 nor the 5.052 release supports these casts: they
// report the casts of the legal part as not supported, or stop with a failed
// internal assertion, and their errors do not count.

module test_illegal_bitstream_cast_to_assoc_array;
  typedef byte dyn_t [];
  typedef byte aa_t [int];
  dyn_t d;
  aa_t m;
  initial begin
    d = dyn_t'(32'h01020304);
    $display("%0d %0d %0d", d.size(), d[0], d[3]);
    m = aa_t'(32'h01020304);   // illegal: associative array as the destination type
  end
endmodule
