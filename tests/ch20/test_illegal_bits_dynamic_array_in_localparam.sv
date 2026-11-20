/*
:name: test_illegal_bits_dynamic_array_in_localparam
:description: $bits of a dynamic array variable is not valid at elaboration, so it cannot give the value of a localparam (IEEE 1800-2023 Section 20.6.2)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the localparam W needs a constant expression, but $bits(dyn) of the dynamic array dyn is valid at elaboration only for fixed-size data types
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented|internal error|syntax error))[^\n]*test_illegal_bits_dynamic_array_in_localparam\.sv:29:
*/
// IEEE 1800-2023 §20.6.2: the value of $bits is valid at elaboration only
// when its expression contains fixed-size data types. §11.2.1 leaves to
// §20.6 when a data query call such as $bits is a constant system function
// call, so $bits of the dynamic array variable dyn is not a constant
// expression, and the value of a localparam has to be one. The argument is
// a variable, not a type identifier, and no function is enclosed, so the
// only rule the design breaks is the one about elaboration. The same design
// with dyn declared as int dyn[4] is accepted by Icarus Verilog 13.0 and by
// the 5.054 release of Verilator, so nothing else in it is in error.
// Icarus Verilog 13.0 accepts this design. The 5.054 release of Verilator
// stops at line 29 with an unsupported-construct message and an internal
// error, which do not count.

module test_illegal_bits_dynamic_array_in_localparam;
  int dyn[];
  localparam int W = $bits(dyn);   // illegal: not valid at elaboration
  initial $display("%0d", W);
endmodule
