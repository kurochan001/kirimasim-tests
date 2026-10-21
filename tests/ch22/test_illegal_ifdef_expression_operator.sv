/*
:name: test_illegal_ifdef_expression_operator
:description: The expression of `ifdef can use only logical operators (IEEE 1800-2023 Section 22.6)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.6 11.4.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the `ifdef expression uses an arithmetic operator
:expected_stderr_regex: test_illegal_ifdef_expression_operator\.sv:24:
*/
// IEEE 1800-2023 §22.6: an `ifdef expression may contain identifiers, logical
// operators (§11.4.7) and parentheses; + is not one of them.
// Icarus Verilog 13.0 does not support this construct of IEEE 1800-2023, so the
// error it reports on that line does not count.

`define ALPHA
`define BETA

module test_illegal_ifdef_expression_operator;
  initial begin
`ifdef (ALPHA + BETA)   // illegal: + in an `ifdef expression
    $display("both");
`endif
  end
endmodule
