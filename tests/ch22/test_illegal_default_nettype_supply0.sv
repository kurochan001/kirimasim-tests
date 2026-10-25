/*
:name: test_illegal_default_nettype_supply0
:description: `default_nettype accepts only wire, tri, tri0, tri1, wand, triand, wor, trior, trireg, uwire and none, so supply0, a net type that is not in that list, is an error (IEEE 1800-2023 Section 22.8)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: supply0 is not one of the values that `default_nettype accepts
:expected_stderr_regex: test_illegal_default_nettype_supply0\.sv:23:
*/
// IEEE 1800-2023 §22.8, Syntax 22-7: the value of `default_nettype is one of
// wire, tri, tri0, tri1, wand, triand, wor, trior, trireg, uwire and none.
// supply0 names a net type (6.7) but is not among them, so the directive is
// illegal. The module itself is legal and declares its nets. Icarus Verilog
// 13.0 and the 5.052 release of Verilator reject the line, but not for this
// reason alone: Icarus Verilog rejects the legal values trireg and uwire with
// the same message, and Verilator reports values other than none and wire as
// unsupported.

`default_nettype supply0 // illegal: supply0 is not a default_nettype value
module test_illegal_default_nettype_supply0;
  wire a = 1'b1;
  wire b;
  assign b = a;
endmodule
`default_nettype wire
