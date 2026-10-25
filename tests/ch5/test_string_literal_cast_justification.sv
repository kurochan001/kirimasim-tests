/*
:name: test_string_literal_cast_justification
:description: A string literal cast to a packed array type is right justified and one cast to an unpacked array of bytes is left justified, as when it is assigned (IEEE 1800-2023 Section 5.9)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.9 6.24.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_literal_cast_justification.expected
*/
// IEEE 1800-2023 §5.9: a string literal is a packed value of 8 bits per
// character. Assigned to a packed array it is right justified: a wider target
// is padded with zeros on the left and a narrower one loses the leftmost
// characters. Assigned to an unpacked array of bytes it is left justified:
// the first character goes to the leftmost element. A cast of a string
// literal to a packed or unpacked array type (§6.24.1) follows the same rules
// as the assignment.
// The test assigns and casts "abc" to a 32-bit, a 16-bit and an unpacked
// 4-byte type, and prints both results. For the unpacked type only the
// first three elements are printed: left justification puts 'a' (97) in
// element 0, right justification would put it in element 1.
// Icarus Verilog 13.0 rejects the assignment of a string literal to an
// unpacked array, and the release 5.052 of Verilator does not support the
// cast to an unpacked array type.

module test_string_literal_cast_justification;
  typedef bit [31:0] wide_t;
  typedef bit [15:0] narrow_t;
  typedef byte bytes_t[0:3];

  wide_t wa, wc;
  narrow_t na, nc;
  bytes_t ua, uc;

  initial begin
    wa = "abc";
    wc = wide_t'("abc");
    na = "abc";
    nc = narrow_t'("abc");
    ua = "abc";
    uc = bytes_t'("abc");
    $display("wide: assign=%h cast=%h", wa, wc);
    $display("narrow: assign=%h cast=%h", na, nc);
    $display("unpacked: assign=%0d %0d %0d cast=%0d %0d %0d",
             ua[0], ua[1], ua[2], uc[0], uc[1], uc[2]);
  end
endmodule
