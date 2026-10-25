/*
:name: test_illegal_checker_sequence_output
:description: The type of a checker output argument cannot be a sequence (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the checker declares an output formal of type sequence
:expected_stderr_regex: test_illegal_checker_sequence_output\.sv:28:
*/
// IEEE 1800-2023 17.2: the legal data types for checker formal arguments are
// those legal for a property, which include the type sequence. The type of an
// output argument, however, shall not be untyped, sequence or property, so the
// sequence output s below is not legal. The instance passes the expression v,
// which is a legal actual for a sequence formal, so the type of the formal is
// the only error. The rest of the design is legal.
// The 5.052 release reports the sequence formal type itself as unsupported,
// which is not this rule, and Icarus Verilog 13.0 does not support checkers at
// all, so neither release produces the expected result.

`timescale 1ns/1ns

checker sequence_output(
    input logic a,
    output sequence s);
endchecker : sequence_output

module test_illegal_checker_sequence_output;
  logic v = 1'b1;

  sequence_output u(.a(v), .s(v));

  initial #1 $finish;
endmodule
