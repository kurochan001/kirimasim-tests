/*
:name: test_illegal_scalared_net_without_packed_dimension
:description: a net declaration that uses vectored or scalared needs at least one packed dimension (IEEE 1800-2023 Section 6.7)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the net single is declared scalared without a packed dimension
:expected_stderr_regex: test_illegal_scalared_net_without_packed_dimension\.sv:27:
*/
// IEEE 1800-2023 §6.7 (footnote 16 of Syntax 6-2): when the vectored or
// scalared keyword is used in a net declaration, there shall be at least one
// packed dimension. The vectored and scalared nets with a range are legal,
// also when the range has a single bit, and the legal design prints the
// values driven onto them; the net single is declared scalared without a
// range.
// The 5.052 release accepts the declaration of single.

module test_illegal_scalared_net_without_packed_dimension;
  wire vectored [7:0] bus = 8'h3c;
  tri scalared [3:0] nibble = 4'h9;
  wire scalared [0:0] one_bit = 1'b1;
  initial #1 $display("%h %h %b", bus, nibble, one_bit);
  wire scalared single;   // illegal: scalared without a packed dimension
endmodule
