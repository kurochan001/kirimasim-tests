/*
:name: test_illegal_net_type_reference_without_net_type
:description: a declaration through a type reference to a net needs a net type keyword or var (IEEE 1800-2023 Section 12.7)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.7 6.23
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: w2 is declared with the type reference type(w) without a net type keyword or the var keyword
:expected_stderr_regex: test_illegal_net_type_reference_without_net_type\.sv:27:
*/
// IEEE 1800-2023 §12.7 (footnote 18 of Syntax 12-5), §6.23: a type reference
// used in a net declaration shall be preceded by a net type keyword, and one
// used in a variable declaration by the var keyword. w1 is declared as a net
// with wire type(w), and v as a variable with var type(w), which are legal.
// w2 is declared with type(w) and no keyword before it, which is neither form.
// Icarus Verilog 13.0 reports a syntax error here, but it reports one on the
// legal declarations as well, as it does not support these type references, so
// it does not count; Verilator 5.052 accepts the design.

module test_illegal_net_type_reference_without_net_type;
  wire [3:0] w = 4'd5;
  wire type(w) w1 = w;
  var type(w) v = 4'd6;
  type(w) w2 = w;   // illegal
  initial #1 $display("%0d %0d", w1, v);
endmodule
