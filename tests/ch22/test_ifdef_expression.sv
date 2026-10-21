/*
:name: test_ifdef_expression
:description: `ifdef, `elsif and `ifndef with an expression of macro names and logical operators, where a defined name counts as 1 whatever its text (IEEE 1800-2023 Section 22.6)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.6 22.5.1 11.4.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ifdef_expression.expected
*/
// IEEE 1800-2023 §22.6: in parentheses after `ifdef, `elsif or `ifndef, an
// expression of identifiers, logical operators (§11.4.7) and parentheses is
// evaluated with each identifier replaced by 1 if it names a defined macro and
// 0 otherwise; `ifndef (e) is `ifdef (!(e)). ALPHA and BETA are defined, BETA
// with the text 0, which does not matter; GAMMA and DELTA are not. So the first
// two blocks are used, the `elsif with 0 -> 0, which is 1, is used instead of
// its `ifdef, and the `ifndef of 1 <-> 0 is used.
// Icarus Verilog 13.0 does not support this construct of IEEE 1800-2023.

`define ALPHA
`define BETA 0

module test_ifdef_expression;
  initial begin
`ifdef (ALPHA && BETA)
    $display("ALPHA && BETA");
`endif
`ifdef (ALPHA && !GAMMA)
    $display("ALPHA && !GAMMA");
`endif
`ifdef (GAMMA || DELTA)
    $display("GAMMA || DELTA");
`elsif (GAMMA -> DELTA)
    $display("GAMMA -> DELTA");
`endif
`ifndef (ALPHA <-> GAMMA)
    $display("not ALPHA <-> GAMMA");
`endif
  end
endmodule
