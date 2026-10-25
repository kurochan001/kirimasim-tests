/*
:name: test_illegal_cast_real_array_to_unpacked_array
:description: an unpacked array of real elements cannot be cast to another type, even to an unpacked array of the same size, because real is not valid for a packed representation (IEEE 1800-2023 Section 6.24.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.24.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked array r of real elements is cast to the unpacked array type l2_t of longint elements
:expected_stderr_regex: test_illegal_cast_real_array_to_unpacked_array\.sv:37:
*/
// IEEE 1800-2023 §6.24.1: when unpacked data are converted to the packed
// representation, the data items take the bits in order, like a concatenation,
// and the type of the elements of an unpacked structure or array shall be valid
// for a packed representation for the structure or array to be cast to any
// other type, packed or unpacked.
// The unpacked array w of two int elements is cast to the unpacked array type
// s4_t of four shortint elements, the same 64 bits; the legal design prints the
// first and last elements: 0 6. The unpacked array r of two real elements, 128
// bits like l2_t, is cast to l2_t.
// Neither Icarus Verilog 13.0 nor the 5.052 release supports these casts: they
// report the casts of the legal part as not supported, or stop with a failed
// internal assertion, and their errors do not count.

module test_illegal_cast_real_array_to_unpacked_array;
  typedef shortint s4_t [4];
  typedef longint l2_t [2];
  int w [2] = '{5, 6};
  real r [2] = '{1.0, 2.0};
  s4_t s;
  l2_t l;
  initial begin
    s = s4_t'(w);
    $display("%0d %0d", s[0], s[3]);
    l = l2_t'(r);   // illegal: real elements cannot be packed
  end
endmodule
