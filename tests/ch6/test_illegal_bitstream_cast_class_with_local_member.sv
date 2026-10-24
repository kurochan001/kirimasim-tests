/*
:name: test_illegal_bitstream_cast_class_with_local_member
:description: a handle of a class with local or protected members cannot be the source of a bit-stream cast, except the handle this inside the class (IEEE 1800-2023 Section 6.24.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the handle p of the class priv_c, which has the local member a, is the source of a bit-stream cast outside the class
:expected_stderr_regex: test_illegal_bitstream_cast_class_with_local_member\.sv:41:
*/
// IEEE 1800-2023 §6.24.3: an explicit cast can convert between bit-stream types
// (integral, packed and string types, and unpacked arrays, structures, classes
// and dynamically sized arrays of them) by packing the source into a stream of
// bits and unpacking it into the destination, the first element or field taking
// the most significant bits. A class handle with local or protected members
// shall not be a source type, except when it is the current instance this.
// The class priv_c has the local member a and the member b. Its method pack
// casts this to longint, which is legal; the legal design prints what pack
// returns: 0000000100000002. The last statement casts the handle p of priv_c to
// longint outside the class.
// Neither Icarus Verilog 13.0 nor the 5.052 release supports these casts: they
// report the casts of the legal part as not supported, or stop with a failed
// internal assertion, and their errors do not count.

module test_illegal_bitstream_cast_class_with_local_member;
  class test_illegal_bitstream_cast_class_with_local_member_priv_c;
    local int a = 1;
    int b = 2;
    function longint pack();
      return longint'(this);
    endfunction
  endclass
  test_illegal_bitstream_cast_class_with_local_member_priv_c p;
  longint x;
  initial begin
    p = new;
    $display("%h", p.pack());
    x = longint'(p);   // illegal: class with a local member as the source
  end
endmodule
