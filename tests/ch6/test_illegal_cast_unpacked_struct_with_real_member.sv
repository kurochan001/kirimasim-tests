/*
:name: test_illegal_cast_unpacked_struct_with_real_member
:description: an unpacked structure with a real member cannot be cast to another type, because real is not valid for a packed representation (IEEE 1800-2023 Section 6.24.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.24.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked structure s, whose member r is real, is cast to longint
:expected_stderr_regex: test_illegal_cast_unpacked_struct_with_real_member\.sv:34:
*/
// IEEE 1800-2023 §6.24.1: when unpacked data are converted to the packed
// representation, the data items take the bits in order, like a concatenation,
// and the type of the elements of an unpacked structure or array shall be valid
// for a packed representation for the structure or array to be cast to any
// other type, packed or unpacked.
// The unpacked structure t has two int members, and its cast to longint puts a
// in the upper half; the legal design prints it: 0000000500000006. The unpacked
// structure s has the real member r, 64 bits like longint, and is cast to
// longint.
// Neither Icarus Verilog 13.0 nor the 5.052 release supports these casts or the
// unpacked structure: they report the legal cast or the structures as not
// supported, and their errors do not count.

module test_illegal_cast_unpacked_struct_with_real_member;
  struct { int a; int b; } t = '{5, 6};
  struct { real r; } s = '{1.5};
  longint x;
  initial begin
    x = longint'(t);
    $display("%h", x);
    x = longint'(s);   // illegal: real member of an unpacked structure
  end
endmodule
