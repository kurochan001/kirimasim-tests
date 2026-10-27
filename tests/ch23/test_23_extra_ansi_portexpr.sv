/*
:name: test_23_extra_ansi_portexpr
:description: An explicitly named ANSI port expression is self-determined and shall be a legal expression for the port kind, so an output port expression that is only an arithmetic value is an error (IEEE 1800-2023 Section 23.2.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.2 23.3.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the output port P of pe uses the arithmetic expression a + b as its port expression, which is not a net or variable that an output can drive
:expected_stderr_regex: test_23_extra_ansi_portexpr\.sv:25:
*/
// IEEE 1800-2023 §23.2.2.2: the self-determined type of an explicitly named
// port expression becomes the port type, the expression is not an
// assignment-like context, and it shall resolve to a legal expression for
// the port kind (§23.3.3). For an output port the internal side is a sink,
// and §23.3.3.3 allows an output to be connected to a net or variable or a
// concatenation of them. The expression a + b is neither, so the output
// port P of pe is illegal.
// Icarus Verilog 13.0 and Verilator 5.052 do not implement explicitly named
// ANSI ports, so their errors at this line come from that lack, not from
// this rule; see the note below.

module pe(output .P(a + b));
  logic [3:0] a, b;
endmodule

module test_23_extra_ansi_portexpr;
  logic [3:0] a = 4'h1, b = 4'h2;
  wire [3:0] p;
  pe u(.P(p));
endmodule
